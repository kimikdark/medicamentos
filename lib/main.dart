import 'package:flutter/material.dart';
import 'package:medicamentos/tela_familiar.dart';
import 'package:medicamentos/models/medicamento.dart';
import 'package:medicamentos/tela_detalhes_medicamento.dart';

void main() {
  runApp(const MyApp());
}

// --- Cores da App ---
const Color brandGreen = Color(0xFF82CF40);
const Color brandBlue = Color(0xFF2D9CDB);
const Color brandWhite = Colors.white;
const Color navbarContrastColor = Color(0xFF388E3C);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Medicação',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          primary: brandGreen,
          secondary: brandBlue,
          background: brandWhite,
        ),
        useMaterial3: true,
      ),
      home: const TelaPrincipal(title: 'A Minha Medicação'),
    );
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key, required this.title});

  final String title;

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  // A lista agora é partilhada e atualizada a partir da tela familiar
  List<Medicamento> _medicamentos = [
    Medicamento(
      name: 'Ben-u-ron',
      dose: '1g',
      times: [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 16, minute: 0)],
      instructions: 'Tomar após o pequeno-almoço',
    ),
    Medicamento(
      name: 'Brufen',
      dose: '400mg',
      times: [const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 20, minute: 0)],
      instructions: 'Tomar após o almoço',
    ),
  ];

  void _tomarMedicamento(int index) {
    setState(() {
      _medicamentos[index].isTaken = true;
    });
  }

  void _navegarParaDetalhes(Medicamento medicamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaDetalhesMedicamento(medicamento: medicamento),
      ),
    );
  }

  // Navega para a tela familiar e atualiza a lista de medicamentos ao voltar
  void _navegarParaModoFamiliar() async {
    final List<Medicamento>? listaAtualizada = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaFamiliar()),
    );

    if (listaAtualizada != null) {
      setState(() {
        _medicamentos = listaAtualizada;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navbarContrastColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('imagens/logo.png'),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.family_restroom, color: Colors.white, size: 30),
            onPressed: _navegarParaModoFamiliar,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _medicamentos.length,
        itemBuilder: (context, index) {
          final medicamento = _medicamentos[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(medicamento.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              subtitle: Text('Próxima toma: ${medicamento.timesAsString.first}', style: const TextStyle(fontSize: 18)),
              trailing: ElevatedButton(
                onPressed: medicamento.isTaken ? null : () => _tomarMedicamento(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  disabledBackgroundColor: navbarContrastColor,
                ),
                child: Text(medicamento.isTaken ? '✓ Tomado' : 'Tomei', style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
              onTap: () => _navegarParaDetalhes(medicamento),
            ),
          );
        },
      ),
    );
  }
}
