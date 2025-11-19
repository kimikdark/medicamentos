import 'package:flutter/material.dart';
import 'package:medicamentos/models/medicamento.dart';

class TelaDetalhesMedicamento extends StatelessWidget {
  final Medicamento medicamento;

  const TelaDetalhesMedicamento({super.key, required this.medicamento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove o botão de voltar padrão
        title: Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar', style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(150, 50),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medicamento.name} ${medicamento.dose}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const Text('Horários de hoje:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...medicamento.timesAsString.map((time) => Text(time, style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 24),
            const Text('Instruções:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(medicamento.instructions, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
