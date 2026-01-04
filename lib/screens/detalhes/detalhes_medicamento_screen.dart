import 'package:flutter/material.dart';
import '../../models/medicamento.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/estado_badge.dart';

/// Tela de detalhes do medicamento
class DetalhesMedicamentoScreen extends StatefulWidget {
  final Medicamento medicamento;

  const DetalhesMedicamentoScreen({
    Key? key,
    required this.medicamento,
  }) : super(key: key);

  @override
  State<DetalhesMedicamentoScreen> createState() =>
      _DetalhesMedicamentoScreenState();
}

class _DetalhesMedicamentoScreenState extends State<DetalhesMedicamentoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Medicamento _medicamento;

  @override
  void initState() {
    super.initState();
    _medicamento = widget.medicamento;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Detalhes do Medicamento',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com ícone e nome
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: brandGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _medicamento.tipoIcon,
                    size: 64,
                    color: brandGreen,
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _medicamento.nome,
                        style: const TextStyle(
                          fontSize: fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_medicamento.dose != null &&
                          _medicamento.dose!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _medicamento.dose!,
                          style: const TextStyle(
                            fontSize: fontSizeLarge,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: largePadding),

            // Estado
            _buildInfoCard(
              titulo: 'Estado Atual',
              child: Center(
                child: EstadoBadgeLarge(estado: _medicamento.estado),
              ),
            ),

            const SizedBox(height: defaultPadding),

            // Hora da toma
            _buildInfoCard(
              titulo: 'Horário',
              icone: Icons.access_time,
              conteudo: _medicamento.horaTomaString,
            ),

            const SizedBox(height: defaultPadding),

            // Tipo
            _buildInfoCard(
              titulo: 'Tipo',
              icone: _medicamento.tipoIcon,
              conteudo: _medicamento.tipoString,
            ),

            const SizedBox(height: defaultPadding),

            // Notas (se disponível)
            if (_medicamento.notas != null &&
                _medicamento.notas!.isNotEmpty) ...[
              _buildInfoCard(
                titulo: 'Notas',
                icone: Icons.note,
                conteudo: _medicamento.notas!,
              ),
              const SizedBox(height: defaultPadding),
            ],

            // Informações de repetição
            if (_medicamento.frequenciaRepeticao !=
                FrequenciaRepeticao.nenhuma) ...[
              _buildInfoCard(
                titulo: 'Repetição',
                icone: Icons.repeat,
                conteudo: _getFrequenciaTexto(),
              ),
              const SizedBox(height: defaultPadding),
            ],

            const SizedBox(height: largePadding),

            // Botão "Tomei" (apenas se estado for "por tomar")
            if (_medicamento.estado == EstadoMedicamento.porTomar)
              SizedBox(
                width: double.infinity,
                height: buttonMinHeight + 10,
                child: ElevatedButton(
                  onPressed: _marcarComoTomado,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'TOMEI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeXLarge,
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

  Widget _buildInfoCard({
    required String titulo,
    IconData? icone,
    String? conteudo,
    Widget? child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: fontSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: smallPadding),
            if (child != null)
              child
            else
              Row(
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 32, color: brandGreen),
                    const SizedBox(width: smallPadding),
                  ],
                  Expanded(
                    child: Text(
                      conteudo ?? '',
                      style: const TextStyle(
                        fontSize: fontSizeLarge,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getFrequenciaTexto() {
    switch (_medicamento.frequenciaRepeticao) {
      case FrequenciaRepeticao.diaria:
        return 'Diária';
      case FrequenciaRepeticao.semanal:
        if (_medicamento.diasSemana != null &&
            _medicamento.diasSemana!.isNotEmpty) {
          final dias = _medicamento.diasSemana!
              .map((d) => _getDiaSemanaTexto(d))
              .join(', ');
          return 'Semanal: $dias';
        }
        return 'Semanal';
      case FrequenciaRepeticao.mensal:
        if (_medicamento.diaMes != null) {
          return 'Mensal: dia ${_medicamento.diaMes}';
        }
        return 'Mensal';
      case FrequenciaRepeticao.nenhuma:
        return 'Sem repetição';
    }
  }

  String _getDiaSemanaTexto(int dia) {
    const dias = [
      'Domingo',
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado'
    ];
    return dias[dia - 1];
  }

  Future<void> _marcarComoTomado() async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Confirmar toma',
      message: 'Confirma que tomou ${_medicamento.nome}?',
      confirmText: 'Sim, tomei',
      cancelText: 'Cancelar',
    );

    if (!confirmar) return;

    try {
      final sucesso = await _firebaseService.atualizarEstadoMedicamento(
        _medicamento.id!,
        EstadoMedicamento.tomado,
      );

      if (sucesso) {
        setState(() {
          _medicamento = _medicamento.copyWith(
            estado: EstadoMedicamento.tomado,
            dataTomada: DateTime.now(),
          );
        });

        if (mounted) {
          showMessage(context, 'Medicamento marcado como tomado');
        }

        // Adiciona ao histórico
        await _firebaseService.adicionarAoHistorico(_medicamento);

        // Volta para tela anterior após 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          showMessage(context, 'Erro ao atualizar medicamento', isError: true);
        }
      }
    } catch (e) {
      debugPrint('Erro ao marcar como tomado: $e');
      if (mounted) {
        showMessage(context, 'Erro ao atualizar medicamento', isError: true);
      }
    }
  }
}

