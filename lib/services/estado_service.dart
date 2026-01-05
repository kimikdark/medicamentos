import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/medicamento.dart';
import '../models/configuracao.dart';
import 'firebase_service.dart';
import 'sms_service.dart';

/// Serviço para gerenciar transições automáticas de estados de medicamentos
class EstadoService {
  static final EstadoService _instance = EstadoService._internal();
  factory EstadoService() => _instance;
  EstadoService._internal();

  final FirebaseService _firebaseService = FirebaseService();
  final SmsService _smsService = SmsService();

  Timer? _timer;
  bool _running = false;

  /// Inicia verificação periódica de estados
  void iniciar() {
    if (_running) return;

    _running = true;
    debugPrint('EstadoService iniciado');

    // Verifica a cada minuto
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _verificarTransicoes();
    });

    // Executa primeira verificação imediatamente
    _verificarTransicoes();
  }

  /// Para o serviço
  void parar() {
    _timer?.cancel();
    _timer = null;
    _running = false;
    debugPrint('EstadoService parado');
  }

  /// Verifica e aplica transições de estado necessárias
  Future<void> _verificarTransicoes() async {
    try {
      debugPrint('🔄 Verificando transições de estados...');
      final medicamentos = await _firebaseService.getMedicamentos();
      final config = await _firebaseService.getConfiguracoes();

      debugPrint('📋 ${medicamentos.length} medicamento(s) encontrado(s)');
      debugPrint('⚙️ Config: Finalizado após ${config.minutosParaFinalizado} minutos');

      for (final medicamento in medicamentos) {
        await _verificarMedicamento(medicamento, config);
      }
    } catch (e) {
      debugPrint('Erro ao verificar transições: $e');
    }
  }

  /// Verifica um medicamento específico
  Future<void> _verificarMedicamento(
    Medicamento medicamento,
    Configuracao config,
  ) async {
    final agora = DateTime.now();

    debugPrint('🔍 Verificando: ${medicamento.nome} [${medicamento.estadoString}]');

    // Transição: TOMADO -> FINALIZADO
    // Após minutosParaFinalizado desde quando foi marcado como tomado (dataTomada)
    if (medicamento.estado == EstadoMedicamento.tomado && medicamento.dataTomada != null) {
      final minutosDesdeToamda = agora.difference(medicamento.dataTomada!).inMinutes;

      debugPrint(
          '${medicamento.nome} [TOMADO]: '
          'DataTomada=${medicamento.dataTomada!.hour}:${medicamento.dataTomada!.minute}, '
          'MinutosDesdeToamda=$minutosDesdeToamda, '
          'LimiteParaFinalizado=${config.minutosParaFinalizado}min');

      if (minutosDesdeToamda >= config.minutosParaFinalizado) {
        debugPrint(
            '✅ ${medicamento.nome}: Transição TOMADO -> FINALIZADO (passaram $minutosDesdeToamda minutos desde que foi tomado)');

        await _firebaseService.atualizarEstadoMedicamento(
          medicamento.id!,
          EstadoMedicamento.finalizado,
        );

        await _firebaseService.adicionarAoHistorico(
          medicamento.copyWith(estado: EstadoMedicamento.finalizado),
        );
      }
    }
  }

  /// Envia alerta SMS aos cuidadores
  Future<void> _enviarAlertaCuidadores(
    Medicamento medicamento,
    List<String> numeros,
  ) async {
    try {
      await _smsService.enviarSmsAlerta(
        numeros: numeros,
        medicamento: medicamento,
      );

      debugPrint('Alerta SMS enviado para cuidadores: ${medicamento.nome}');
    } catch (e) {
      debugPrint('Erro ao enviar alerta SMS: $e');
    }
  }

  /// Força verificação manual (útil para testes)
  Future<void> verificarAgora() async {
    debugPrint('Verificação manual de estados iniciada');
    await _verificarTransicoes();
  }

  /// Verifica se um medicamento específico precisa de transição
  Future<void> verificarMedicamentoEspecifico(String medicamentoId) async {
    try {
      final medicamentos = await _firebaseService.getMedicamentos();
      final medicamento = medicamentos.firstWhere((m) => m.id == medicamentoId);
      final config = await _firebaseService.getConfiguracoes();

      await _verificarMedicamento(medicamento, config);
    } catch (e) {
      debugPrint('Erro ao verificar medicamento $medicamentoId: $e');
    }
  }

  /// Retorna status do serviço
  bool get isRunning => _running;
}

