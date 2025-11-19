import 'package:flutter/material.dart';
import 'package:medicamentos/models/medicamento.dart';

// --- Cores da App ---
const Color brandGreen = Color(0xFF82CF40);
const Color navbarContrastColor = Color(0xFF388E3C);

class TelaFamiliar extends StatefulWidget {
  const TelaFamiliar({super.key});

  @override
  State<TelaFamiliar> createState() => _TelaFamiliarState();
}

// Alterado para incluir o 'SingleTickerProviderStateMixin' para o TabController
class _TelaFamiliarState extends State<TelaFamiliar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Índice para a BottomNavigationBar
  late TabController _gestaoTabController; // Controller para as abas de 'Gestão'

  @override
  void initState() {
    super.initState();
    _gestaoTabController = TabController(length: 2, vsync: this);
    // Adiciona um listener para saber quando a aba muda e atualizar o estado
    _gestaoTabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _gestaoTabController.dispose(); // Libertar o controller
    super.dispose();
  }

  // Lista de exemplo de medicamentos
  final List<Medicamento> _medicamentos = [
    Medicamento(
        name: 'Ben-u-ron', dose: '1g', times: [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 16, minute: 0)], instructions: 'Tomar com comida', isTaken: true),
    Medicamento(name: 'Brufen', dose: '400mg', times: [const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 20, minute: 0)], instructions: 'Tomar após o almoço'),
  ];

  // --- Estados de Acessibilidade ---
  bool _ativarVoz = false;
  double _fatorFonte = 1.0;

  // Navega para o formulário e aguarda o resultado
  void _navegarParaAdicionarEditar(int? index) async {
    final Medicamento? resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaAdicionarEditarMedicamento(medicamento: index == null ? null : _medicamentos[index]),
      ),
    );

    if (resultado != null) {
      setState(() {
        if (index == null) {
          _medicamentos.add(resultado);
        } else {
          _medicamentos[index] = resultado;
        }
      });
    }
  }

  void _apagarMedicamento(int index) {
    setState(() {
      _medicamentos.removeAt(index);
    });
  }

  // Constrói os ecrãs principais baseados na seleção da BottomNavigationBar
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return _buildGestaoTab();
      case 1:
        return _buildHistoricoTab();
      case 2:
        return _buildAjudaTab();
      default:
        return _buildGestaoTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostra o botão apenas se estiver no ecrã 'Gestão' E na aba 'Medicação'
    final bool mostrarBotaoAdicionar = _selectedIndex == 0 && _gestaoTabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Familiar', style: TextStyle(color: Colors.white)),
        backgroundColor: navbarContrastColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(_medicamentos),
        ),
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Gestão'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Ajuda'),
        ],
      ),
      floatingActionButton: mostrarBotaoAdicionar
          ? FloatingActionButton(
              onPressed: () => _navegarParaAdicionarEditar(null),
              backgroundColor: brandGreen,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // --- ECRÃS PRINCIPAIS ---

  // Ecrã de Gestão (com abas internas)
  Widget _buildGestaoTab() {
    return Column(
      children: [
        TabBar(
          controller: _gestaoTabController, // Usar o nosso controller
          labelColor: navbarContrastColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: navbarContrastColor,
          tabs: const [
            Tab(text: 'Medicação'),
            Tab(text: 'Acessibilidade'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _gestaoTabController, // Usar o nosso controller
            children: [
              _buildMedicacaoList(),
              _buildAcessibilidadeSettings(),
            ],
          ),
        ),
      ],
    );
  }

  // Ecrã de Histórico
  Widget _buildHistoricoTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Ecrã de Histórico em construção', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  // Ecrã de Ajuda (com abas internas)
  Widget _buildAjudaTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: navbarContrastColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: navbarContrastColor,
            tabs: [
              Tab(text: 'Gerir Medicamentos'),
              Tab(text: 'Usar a App'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildGuiaGrid(
                  [
                    {'icon': Icons.add_box, 'text': 'Adicione novos medicamentos no botão +.'},
                    {'icon': Icons.edit, 'text': 'Edite um medicamento tocando no lápis.'},
                    {'icon': Icons.delete, 'text': 'Apague um medicamento tocando no caixote do lixo.'},
                    {'icon': Icons.camera_alt, 'text': 'Adicione uma foto para fácil identificação.'},
                  ],
                ),
                _buildGuiaGrid(
                  [
                    {'icon': Icons.family_restroom, 'text': 'Entre no Modo Familiar para configurar.'},
                    {'icon': Icons.touch_app, 'text': 'O idoso só precisa de tocar em "Tomei".'},
                    {'icon': Icons.check_circle, 'text': 'O botão fica verde para confirmar a toma.'},
                    {'icon': Icons.text_fields, 'text': 'Ajuste o tamanho da letra em Acessibilidade.'},
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // --- SUB-WIDGETS ---
  
  // Lista de medicação para a aba "Gestão"
  Widget _buildMedicacaoList() {
     return ListView.builder(
      itemCount: _medicamentos.length,
      itemBuilder: (context, index) {
        final med = _medicamentos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            title: Text(med.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * _fatorFonte)),
            subtitle: Text(med.timesAsString.join(', '), style: TextStyle(fontSize: 14 * _fatorFonte)),
            leading: Icon(med.isTaken ? Icons.check_circle : Icons.radio_button_unchecked, color: brandGreen),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _navegarParaAdicionarEditar(index)),
                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _apagarMedicamento(index)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Ecrã de configurações de acessibilidade
  Widget _buildAcessibilidadeSettings() {
     return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ajustes de Acessibilidade', style: TextStyle(fontSize: 22 * _fatorFonte, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SwitchListTile(
            title: Text('Ativar leitura em voz alta', style: TextStyle(fontSize: 16 * _fatorFonte)),
            value: _ativarVoz,
            onChanged: (bool value) => setState(() => _ativarVoz = value),
          ),
          const SizedBox(height: 20),
          Text('Tamanho da fonte', style: TextStyle(fontSize: 16 * _fatorFonte)),
          Slider(
            value: _fatorFonte,
            min: 0.8,
            max: 1.5,
            divisions: 7,
            label: '${(_fatorFonte * 100).toStringAsFixed(0)}%',
            onChanged: (double value) => setState(() => _fatorFonte = value),
          ),
        ],
      ),
    );
  }

  // Grelha para o guia visual do ecrã de Ajuda
  Widget _buildGuiaGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(items[index]['icon'], size: 50, color: navbarContrastColor),
                const SizedBox(height: 12),
                Text(
                  items[index]['text'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ECRÃ PARA ADICIONAR/EDITAR MEDICAMENTO (sem alterações)
class TelaAdicionarEditarMedicamento extends StatefulWidget {
  final Medicamento? medicamento;

  const TelaAdicionarEditarMedicamento({super.key, this.medicamento});

  @override
  State<TelaAdicionarEditarMedicamento> createState() => _TelaAdicionarEditarMedicamentoState();
}

class _TelaAdicionarEditarMedicamentoState extends State<TelaAdicionarEditarMedicamento> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _doseController;
  late TextEditingController _instrucoesController;
  final List<TimeOfDay> _horarios = [];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.medicamento?.name);
    _doseController = TextEditingController(text: widget.medicamento?.dose);
    _instrucoesController = TextEditingController(text: widget.medicamento?.instructions);
    if (widget.medicamento != null) {
      _horarios.addAll(widget.medicamento!.times);
    }
  }

  Future<void> _escolherHorario() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && !_horarios.contains(picked)) {
      setState(() {
        _horarios.add(picked);
      });
    }
  }

  void _guardarFormulario() {
    if (_formKey.currentState!.validate()) {
      final novoMedicamento = Medicamento(
        name: _nomeController.text,
        dose: _doseController.text,
        instructions: _instrucoesController.text,
        times: _horarios,
      );
      Navigator.pop(context, novoMedicamento);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicamento == null ? 'Adicionar Medicamento' : 'Editar Medicamento', style: const TextStyle(color: Colors.white)),
        backgroundColor: navbarContrastColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome do Medicamento'),
                validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
              ),
              TextFormField(controller: _doseController, decoration: const InputDecoration(labelText: 'Dose (ex: 100mg)')),
              TextFormField(controller: _instrucoesController, decoration: const InputDecoration(labelText: 'Instruções')),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Horários:', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _escolherHorario,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Horário'),
                  ),
                ],
              ),
              Wrap(
                spacing: 8.0,
                children: _horarios
                    .map((time) => Chip(
                          label: Text(time.format(context)),
                          onDeleted: () => setState(() => _horarios.remove(time)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _guardarFormulario,
                style: ElevatedButton.styleFrom(backgroundColor: brandGreen, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Guardar', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
