import 'package:flutter/material.dart';
import '../../models/medicamento.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/medicamento_card.dart';
import '../formulario/medicamento_form_screen.dart';

/// Tela de configuração de medicamentos (CRUD)
class ConfiguracaoMedicacaoScreen extends StatefulWidget {
  const ConfiguracaoMedicacaoScreen({Key? key}) : super(key: key);

  @override
  State<ConfiguracaoMedicacaoScreen> createState() =>
      _ConfiguracaoMedicacaoScreenState();
}

class _ConfiguracaoMedicacaoScreenState
    extends State<ConfiguracaoMedicacaoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Medicamento>>(
        stream: _firebaseService.getMedicamentosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar medicamentos',
                style: const TextStyle(fontSize: fontSizeMedium),
              ),
            );
          }

          final medicamentos = snapshot.data ?? [];

          // Filtra apenas "por tomar" para administração
          final medicamentosPorTomar = medicamentos
              .where((m) => m.estado == EstadoMedicamento.porTomar)
              .toList();

          if (medicamentosPorTomar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum medicamento configurado',
                    style: TextStyle(
                      fontSize: fontSizeLarge,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar',
                    style: TextStyle(
                      fontSize: fontSizeMedium,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            itemCount: medicamentosPorTomar.length,
            itemBuilder: (context, index) {
              final medicamento = medicamentosPorTomar[index];

              return MedicamentoCardSimples(
                medicamento: medicamento,
                onEdit: () => _editarMedicamento(medicamento),
                onDelete: () => _deletarMedicamento(medicamento),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarMedicamento,
        icon: const Icon(Icons.add, size: 32),
        label: const Text(
          'Adicionar',
          style: TextStyle(fontSize: fontSizeMedium),
        ),
      ),
    );
  }

  Future<void> _adicionarMedicamento() async {
    final resultado = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicamentoFormScreen(),
      ),
    );

    if (resultado != null) {
      final id = await _firebaseService.adicionarMedicamento(resultado);

      if (id != null) {
        // Agenda notificação
        await _notificationService.agendarNotificacaoMedicamento(
          resultado.copyWith(id: id),
        );

        if (mounted) {
          showMessage(context, 'Medicamento adicionado com sucesso');
        }
      } else {
        if (mounted) {
          showMessage(context, 'Erro ao adicionar medicamento', isError: true);
        }
      }
    }
  }

  Future<void> _editarMedicamento(Medicamento medicamento) async {
    final resultado = await Navigator.push<Medicamento>(
      context,
      MaterialPageRoute(
        builder: (context) => MedicamentoFormScreen(medicamento: medicamento),
      ),
    );

    if (resultado != null) {
      final sucesso = await _firebaseService.atualizarMedicamento(resultado);

      if (sucesso) {
        // Reage notificação
        await _notificationService.cancelarNotificacao(resultado.id!);
        await _notificationService.agendarNotificacaoMedicamento(resultado);

        if (mounted) {
          showMessage(context, 'Medicamento atualizado com sucesso');
        }
      } else {
        if (mounted) {
          showMessage(context, 'Erro ao atualizar medicamento', isError: true);
        }
      }
    }
  }

  Future<void> _deletarMedicamento(Medicamento medicamento) async {
    final confirmar = await showConfirmDialog(
      context,
      title: 'Confirmar exclusão',
      message: 'Deseja realmente apagar ${medicamento.nome}?',
      confirmText: 'Apagar',
      cancelText: 'Cancelar',
    );

    if (!confirmar) return;

    final sucesso = await _firebaseService.deletarMedicamento(medicamento.id!);

    if (sucesso) {
      // Cancela notificação
      await _notificationService.cancelarNotificacao(medicamento.id!);

      if (mounted) {
        showMessage(context, 'Medicamento apagado');
      }
    } else {
      if (mounted) {
        showMessage(context, 'Erro ao apagar medicamento', isError: true);
      }
    }
  }
}

