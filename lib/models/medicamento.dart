import 'package:flutter/material.dart';

class Medicamento {
  String name;
  String dose;
  List<TimeOfDay> times;
  String instructions;
  bool isTaken;

  Medicamento({
    required this.name,
    required this.dose,
    required this.times,
    required this.instructions,
    this.isTaken = false,
  });

  // Helper para converter TimeOfDay para String formatada
  List<String> get timesAsString {
    return times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList();
  }
}
