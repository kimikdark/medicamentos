import 'package:flutter/material.dart';
import '../../models/medicamento.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';

/// Formulário para criar/editar medicamento
class MedicamentoFormScreen extends StatefulWidget {
  final Medicamento? medicamento;

  const MedicamentoFormScreen({
    Key? key,
    this.medicamento,
  }) : super(key: key);

  @override
  State<MedicamentoFormScreen> createState() => _MedicamentoFormScreenState();
}

class _MedicamentoFormScreenState extends State<MedicamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _doseController;
  late TextEditingController _notasController;

  TimeOfDay? _horaSelecionada;
  TipoMedicamento _tipoSelecionado = TipoMedicamento.comprimido;
  FrequenciaRepeticao _frequenciaSelecionada = FrequenciaRepeticao.nenhuma;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.medicamento?.nome);
    _doseController = TextEditingController(text: widget.medicamento?.dose);
    _notasController = TextEditingController(text: widget.medicamento?.notas);

    if (widget.medicamento != null) {
      _horaSelecionada = widget.medicamento!.horaToma;
      _tipoSelecionado = widget.medicamento!.tipo;
      _frequenciaSelecionada = widget.medicamento!.frequenciaRepeticao;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _doseController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.medicamento == null
            ? 'Novo Medicamento'
            : 'Editar Medicamento',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            // Nome (obrigatório)
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Medicamento *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
              style: const TextStyle(fontSize: fontSizeMedium),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              },
            ),

            const SizedBox(height: defaultPadding),

            // Hora (obrigatório)
            InkWell(
              onTap: _selecionarHora,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Hora da Toma *',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                  errorText: _horaSelecionada == null ? 'Selecione a hora' : null,
                ),
                child: Text(
                  _horaSelecionada != null
                      ? formatTimeOfDay(_horaSelecionada!)
                      : 'Toque para selecionar',
                  style: const TextStyle(fontSize: fontSizeMedium),
                ),
              ),
            ),

            const SizedBox(height: defaultPadding),

            // Dose (opcional)
            TextFormField(
              controller: _doseController,
              decoration: const InputDecoration(
                labelText: 'Dose (ex: 500mg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
              style: const TextStyle(fontSize: fontSizeMedium),
            ),

            const SizedBox(height: defaultPadding),

            // Tipo
            DropdownButtonFormField<TipoMedicamento>(
              value: _tipoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Medicamento',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              style: const TextStyle(fontSize: fontSizeMedium, color: Colors.black),
              items: TipoMedicamento.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(_getTipoIcon(tipo), size: 24),
                      const SizedBox(width: 8),
                      Text(_getTipoNome(tipo)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tipoSelecionado = value;
                  });
                }
              },
            ),

            const SizedBox(height: defaultPadding),

            // Notas (opcional)
            TextFormField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              style: const TextStyle(fontSize: fontSizeMedium),
              maxLines: 3,
            ),

            const SizedBox(height: defaultPadding),

            // Repetição
            DropdownButtonFormField<FrequenciaRepeticao>(
              value: _frequenciaSelecionada,
              decoration: const InputDecoration(
                labelText: 'Repetição',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              style: const TextStyle(fontSize: fontSizeMedium, color: Colors.black),
              items: FrequenciaRepeticao.values.map((freq) {
                return DropdownMenuItem(
                  value: freq,
                  child: Text(_getFrequenciaNome(freq)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _frequenciaSelecionada = value;
                  });
                }
              },
            ),

            const SizedBox(height: largePadding),

            // Botão salvar
            SizedBox(
              height: buttonMinHeight,
              child: ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                ),
                child: const Text(
                  'GUARDAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (hora != null) {
      setState(() {
        _horaSelecionada = hora;
      });
    }
  }

  void _salvar() {
    if (!_formKey.currentState!.validate() || _horaSelecionada == null) {
      showMessage(context, 'Preencha todos os campos obrigatórios', isError: true);
      return;
    }

    final medicamento = Medicamento(
      id: widget.medicamento?.id,
      nome: _nomeController.text.trim(),
      dose: _doseController.text.trim().isEmpty ? null : _doseController.text.trim(),
      horaToma: _horaSelecionada!,
      tipo: _tipoSelecionado,
      notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
      frequenciaRepeticao: _frequenciaSelecionada,
      estado: widget.medicamento?.estado ?? EstadoMedicamento.porTomar,
      dataCriacao: widget.medicamento?.dataCriacao,
    );

    Navigator.pop(context, medicamento);
  }

  IconData _getTipoIcon(TipoMedicamento tipo) {
    final medicamento = Medicamento(nome: '', horaToma: TimeOfDay.now(), tipo: tipo);
    return medicamento.tipoIcon;
  }

  String _getTipoNome(TipoMedicamento tipo) {
    final medicamento = Medicamento(nome: '', horaToma: TimeOfDay.now(), tipo: tipo);
    return medicamento.tipoString;
  }

  String _getFrequenciaNome(FrequenciaRepeticao freq) {
    switch (freq) {
      case FrequenciaRepeticao.nenhuma:
        return 'Nenhuma';
      case FrequenciaRepeticao.diaria:
        return 'Diária';
      case FrequenciaRepeticao.semanal:
        return 'Semanal';
      case FrequenciaRepeticao.mensal:
        return 'Mensal';
    }
  }
}

