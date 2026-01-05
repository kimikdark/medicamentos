import 'package:flutter/material.dart';
import '../models/medicamento.dart';
import '../models/configuracao.dart';

/// Serviço mock para desenvolvimento sem Firebase
/// Use este service temporariamente enquanto configura o Firebase real
class MockFirebaseService {
  static final MockFirebaseService _instance = MockFirebaseService._internal();
  factory MockFirebaseService() => _instance;
  MockFirebaseService._internal();

  // Dados mock
  final List<Medicamento> _medicamentos = [
    Medicamento(
      id: '1',
      nome: 'Ben-u-ron',
      dose: '1g',
      horaToma: const TimeOfDay(hour: 8, minute: 0),
      tipo: TipoMedicamento.comprimido,
      estado: EstadoMedicamento.porTomar,
      notas: 'Tomar com água após o pequeno-almoço',
    ),
    Medicamento(
      id: '2',
      nome: 'Brufen',
      dose: '400mg',
      horaToma: const TimeOfDay(hour: 12, minute: 0),
      tipo: TipoMedicamento.comprimido,
      estado: EstadoMedicamento.porTomar,
      notas: 'Tomar após o almoço',
    ),
    Medicamento(
      id: '3',
      nome: 'Gotas para os olhos',
      dose: '2 gotas',
      horaToma: const TimeOfDay(hour: 20, minute: 0),
      tipo: TipoMedicamento.gotas,
      estado: EstadoMedicamento.porTomar,
    ),
  ];

  Configuracao? _config;

  /// Retorna stream de medicamentos (simulado)
  Stream<List<Medicamento>> getMedicamentosStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      yield List<Medicamento>.from(_medicamentos);
    }
  }

  /// Retorna lista de medicamentos
  Future<List<Medicamento>> getMedicamentos() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simula latência
    return List<Medicamento>.from(_medicamentos);
  }

  /// Adiciona medicamento
  Future<String?> adicionarMedicamento(Medicamento medicamento) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _medicamentos.add(medicamento.copyWith(id: id));
    debugPrint('[MOCK] Medicamento adicionado: ${medicamento.nome}');
    return id;
  }

  /// Atualiza medicamento
  Future<bool> atualizarMedicamento(Medicamento medicamento) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _medicamentos.indexWhere((m) => m.id == medicamento.id);
    if (index != -1) {
      _medicamentos[index] = medicamento;
      debugPrint('[MOCK] Medicamento atualizado: ${medicamento.nome}');
      return true;
    }
    return false;
  }

  /// Deleta medicamento
  Future<bool> deletarMedicamento(String medicamentoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lengthBefore = _medicamentos.length;
    _medicamentos.removeWhere((m) => m.id == medicamentoId);
    final removed = _medicamentos.length < lengthBefore;
    debugPrint('[MOCK] Medicamento deletado: $medicamentoId');
    return removed;
  }

  /// Atualiza estado do medicamento
  Future<bool> atualizarEstadoMedicamento(
    String medicamentoId,
    EstadoMedicamento novoEstado,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _medicamentos.indexWhere((m) => m.id == medicamentoId);
    if (index != -1) {
      _medicamentos[index] = _medicamentos[index].copyWith(
        estado: novoEstado,
        dataUltimaMudancaEstado: DateTime.now(),
      );
      debugPrint('[MOCK] Estado atualizado: ${_medicamentos[index].nome} → ${novoEstado.name}');
      return true;
    }
    return false;
  }

  /// Retorna configurações
  Future<Configuracao> getConfiguracoes() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _config ??= Configuracao.defaultConfig();
    debugPrint('[MOCK] Configurações carregadas');
    return _config!;
  }

  /// Salva configurações
  Future<bool> salvarConfiguracoes(Configuracao config) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _config = config;
    debugPrint('[MOCK] Configurações salvas');
    return true;
  }

  /// Adiciona ao histórico (mock - não faz nada)
  Future<void> adicionarAoHistorico(Medicamento medicamento) async {
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('[MOCK] Adicionado ao histórico: ${medicamento.nome}');
  }

  /// Retorna histórico mock
  Future<List<Map<String, dynamic>>> getHistorico({
    bool ordenarCrescente = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final historico = _medicamentos.map((m) => {
      'id': m.id,
      'medicamentoId': m.id,
      'nome': m.nome,
      'dose': m.dose,
      'estado': m.estado.index,
      'estadoString': m.estadoString,
      'horaToma': m.horaTomaString,
      'notas': m.notas,
      'timestamp': DateTime.now(),
    }).toList();

    if (ordenarCrescente) {
      historico.sort((a, b) => (a['timestamp'] as DateTime).compareTo(b['timestamp'] as DateTime));
    } else {
      historico.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    }

    debugPrint('[MOCK] Histórico carregado: ${historico.length} itens');
    return historico;
  }
}

