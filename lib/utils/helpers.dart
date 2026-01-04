import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formata TimeOfDay para string HH:mm
String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

/// Formata DateTime para string dd/MM/yyyy HH:mm
String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// Formata DateTime para apenas data dd/MM/yyyy
String formatDate(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy').format(dateTime);
}

/// Formata DateTime para apenas hora HH:mm
String formatTime(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}

/// Converte TimeOfDay para DateTime hoje
DateTime timeOfDayToDateTime(TimeOfDay time) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, time.hour, time.minute);
}

/// Converte string HH:mm para TimeOfDay
TimeOfDay? stringToTimeOfDay(String timeString) {
  try {
    final parts = timeString.split(':');
    if (parts.length == 2) {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    }
  } catch (e) {
    debugPrint('Erro ao converter string para TimeOfDay: $e');
  }
  return null;
}

/// Valida se uma string é um número de telefone válido (formato simples)
bool isValidPhoneNumber(String phone) {
  // Remove espaços e caracteres especiais
  final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
  // Verifica se tem pelo menos 9 dígitos
  return cleaned.length >= 9;
}

/// Valida se PIN tem 4 dígitos
bool isValidPin(String pin) {
  return pin.length == 4 && int.tryParse(pin) != null;
}

/// Formata lista de números de telefone separados por vírgula
List<String> parsePhoneNumbers(String input) {
  return input
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty && isValidPhoneNumber(e))
      .toList();
}

/// Converte lista de telefones para string separada por vírgula
String phoneNumbersToString(List<String> phones) {
  return phones.join(', ');
}

/// Calcula diferença em minutos entre dois DateTimes
int differenceInMinutes(DateTime start, DateTime end) {
  return end.difference(start).inMinutes;
}

/// Verifica se um horário já passou hoje
bool hasTimePassed(TimeOfDay time) {
  final now = TimeOfDay.now();
  final nowMinutes = now.hour * 60 + now.minute;
  final timeMinutes = time.hour * 60 + time.minute;
  return nowMinutes > timeMinutes;
}

/// Obtém o próximo horário de uma lista de TimeOfDay
TimeOfDay? getNextTime(List<TimeOfDay> times) {
  if (times.isEmpty) return null;

  final now = TimeOfDay.now();
  final nowMinutes = now.hour * 60 + now.minute;

  // Ordena os horários
  final sortedTimes = List<TimeOfDay>.from(times)
    ..sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });

  // Encontra o próximo horário que ainda não passou
  for (final time in sortedTimes) {
    final timeMinutes = time.hour * 60 + time.minute;
    if (timeMinutes > nowMinutes) {
      return time;
    }
  }

  // Se todos passaram, retorna o primeiro (próximo dia)
  return sortedTimes.first;
}

/// Mostra SnackBar com mensagem
void showMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Mostra diálogo de confirmação
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirmar',
  String cancelText = 'Cancelar',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, style: const TextStyle(fontSize: 20)),
      content: Text(message, style: const TextStyle(fontSize: 16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText, style: const TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText, style: const TextStyle(fontSize: 16)),
        ),
      ],
    ),
  );
  return result ?? false;
}

