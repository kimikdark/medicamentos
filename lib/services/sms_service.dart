import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/medicamento.dart';

/// Serviço para envio de SMS aos cuidadores
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  /// Envia SMS para lista de números
  /// Nota: url_launcher abre o app de SMS nativo com a mensagem pré-preenchida
  /// O usuário precisa confirmar o envio manualmente
  Future<bool> enviarSmsAlerta({
    required List<String> numeros,
    required Medicamento medicamento,
  }) async {
    if (numeros.isEmpty) {
      debugPrint('Nenhum número de cuidador configurado');
      return false;
    }

    final mensagem = 'A toma da medicação "${medicamento.nome}" não foi confirmada às ${medicamento.horaTomaString}.';

    try {
      // Envia para cada número (Android suporta múltiplos destinatários)
      final numerosString = numeros.join(',');

      // URL scheme para SMS
      final uri = Uri(
        scheme: 'sms',
        path: numerosString,
        queryParameters: {'body': mensagem},
      );

      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(uri);

        if (success) {
          debugPrint('App SMS aberto para enviar alerta: $mensagem');
          return true;
        } else {
          debugPrint('Falha ao abrir app SMS');
          return false;
        }
      } else {
        debugPrint('Não é possível abrir app SMS');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao enviar SMS: $e');
      return false;
    }
  }

  /// Envia SMS genérico
  Future<bool> enviarSms({
    required String numero,
    required String mensagem,
  }) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: numero,
        queryParameters: {'body': mensagem},
      );

      if (await canLaunchUrl(uri)) {
        final success = await launchUrl(uri);

        if (success) {
          debugPrint('App SMS aberto');
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Erro ao enviar SMS: $e');
      return false;
    }
  }

  /// Valida formato de número de telefone (básico)
  bool validarNumero(String numero) {
    // Remove espaços e caracteres especiais
    final cleaned = numero.replaceAll(RegExp(r'[^\d+]'), '');

    // Verifica se tem pelo menos 9 dígitos
    return cleaned.length >= 9;
  }

  /// Formata número de telefone para exibição
  String formatarNumero(String numero) {
    // Remove caracteres não numéricos exceto +
    final cleaned = numero.replaceAll(RegExp(r'[^\d+]'), '');

    // Adiciona espaços para melhor legibilidade
    if (cleaned.startsWith('+351') && cleaned.length == 13) {
      // Formato português: +351 XXX XXX XXX
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 10)} ${cleaned.substring(10)}';
    } else if (cleaned.length == 9) {
      // Formato local: XXX XXX XXX
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }

    return numero;
  }

  /// Testa se o dispositivo suporta envio de SMS
  Future<bool> isSmsSupported() async {
    try {
      final uri = Uri(scheme: 'sms', path: '');
      return await canLaunchUrl(uri);
    } catch (e) {
      debugPrint('Erro ao verificar suporte SMS: $e');
      return false;
    }
  }
}

