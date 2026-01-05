import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../models/medicamento.dart';
import '../../services/firebase_service.dart';
import '../../services/estado_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/medicamento_card.dart';
import '../../widgets/custom_app_bar.dart';
import '../admin/pin_verification_screen.dart';
import '../admin/admin_main_screen.dart';
import '../auth/profile_screen.dart';
import '../detalhes/detalhes_medicamento_screen.dart';
import '../../main.dart' show USE_MOCK_DATA;

/// Tela principal da aplicação
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(
        onAdminTap: _navegarParaAdmin,
        onProfileTap: USE_MOCK_DATA ? null : _navegarParaPerfil,
      ),
      body: StreamBuilder<List<Medicamento>>(
        stream: _firebaseService.getMedicamentosStream(),
        builder: (context, snapshot) {
          // Mostra loading apenas no primeiro carregamento
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final errorMessage = snapshot.error.toString();
            final isOffline = errorMessage.contains('offline') ||
                             errorMessage.contains('unavailable');

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOffline ? Icons.cloud_off : Icons.error,
                    size: 64,
                    color: isOffline ? Colors.orange : Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isOffline
                        ? 'Modo Offline'
                        : 'Erro ao carregar medicamentos',
                    style: const TextStyle(fontSize: fontSizeMedium),
                  ),
                  const SizedBox(height: 8),
                  if (isOffline)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Os dados serão sincronizados quando a conexão for restabelecida',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: fontSizeSmall, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final todosMedicamentos = snapshot.data ?? [];

          // Filtra apenas "por tomar" e "tomado"
          final medicamentosFiltrados = todosMedicamentos
              .where((m) =>
                  m.estado == EstadoMedicamento.porTomar ||
                  m.estado == EstadoMedicamento.tomado)
              .toList();

          // Ordena por hora de toma
          medicamentosFiltrados.sort((a, b) {
            final aMinutos = a.horaToma.hour * 60 + a.horaToma.minute;
            final bMinutos = b.horaToma.hour * 60 + b.horaToma.minute;
            return aMinutos.compareTo(bMinutos);
          });

          if (medicamentosFiltrados.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum medicamento pendente',
                    style: TextStyle(
                      fontSize: fontSizeLarge,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure medicamentos na área de administração',
                    style: TextStyle(
                      fontSize: fontSizeMedium,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            itemCount: medicamentosFiltrados.length,
            itemBuilder: (context, index) {
              final medicamento = medicamentosFiltrados[index];

              return MedicamentoCard(
                medicamento: medicamento,
                onTap: () => _navegarParaDetalhes(medicamento),
                onBadgeTap: () => _marcarComoTomado(medicamento),
              );
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão de debug (apenas em modo debug)
          if (kDebugMode) ...[
            FloatingActionButton(
              heroTag: 'debugBtn',
              onPressed: _forcarVerificacaoEstados,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.refresh, size: 24),
            ),
            const SizedBox(height: 10),
          ],
          // Botão principal
          FloatingActionButton.extended(
            heroTag: 'addBtn',
            onPressed: _criarEntradaFinalizada,
            backgroundColor: brandGreen,
            icon: const Icon(Icons.add, size: 32),
            label: const Text(
              'Adicionar',
              style: TextStyle(fontSize: fontSizeMedium),
            ),
          ),
        ],
      ),
    );
  }

  /// Navega para tela de detalhes
  void _navegarParaDetalhes(Medicamento medicamento) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesMedicamentoScreen(
          medicamento: medicamento,
        ),
      ),
    );
  }

  /// Marca medicamento como tomado
  Future<void> _marcarComoTomado(Medicamento medicamento) async {
    try {
      final sucesso = await _firebaseService.atualizarEstadoMedicamento(
        medicamento.id!,
        EstadoMedicamento.tomado,
      );

      if (sucesso) {
        if (mounted) {
          showMessage(context, '${medicamento.nome} marcado como tomado');
        }

        // Adiciona ao histórico
        await _firebaseService.adicionarAoHistorico(
          medicamento.copyWith(estado: EstadoMedicamento.tomado),
        );
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

  /// Cria entrada já finalizada (botão +)
  Future<void> _criarEntradaFinalizada() async {
    final nomeController = TextEditingController();
    final dosagemController = TextEditingController();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Medicamento Tomado', style: TextStyle(fontSize: fontSizeLarge)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Digite o nome do medicamento que já foi tomado:',
              style: TextStyle(fontSize: fontSizeMedium),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do medicamento',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: fontSizeMedium),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dosagemController,
              decoration: const InputDecoration(
                labelText: 'Dosagem (opcional)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 500mg, 2 comprimidos',
              ),
              style: const TextStyle(fontSize: fontSizeMedium),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(fontSize: fontSizeMedium)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Adicionar', style: TextStyle(fontSize: fontSizeMedium)),
          ),
        ],
      ),
    );

    if (resultado == true && nomeController.text.isNotEmpty) {
      final novoMedicamento = Medicamento(
        nome: nomeController.text,
        dose: dosagemController.text.isNotEmpty ? dosagemController.text : null,
        horaToma: TimeOfDay.now(),
        estado: EstadoMedicamento.finalizado,
        dataTomada: DateTime.now(),
      );

      final id = await _firebaseService.adicionarMedicamento(novoMedicamento);

      if (id != null) {
        if (mounted) {
          showMessage(context, 'Medicamento adicionado ao histórico');
        }

        await _firebaseService.adicionarAoHistorico(novoMedicamento);
      } else {
        if (mounted) {
          showMessage(context, 'Erro ao adicionar medicamento', isError: true);
        }
      }
    }
  }

  /// Navega para área administrativa
  Future<void> _navegarParaAdmin() async {
    // Verifica se PIN está habilitado
    final config = await _firebaseService.getConfiguracoes();

    bool autenticado = false;

    if (config.pinEnabled) {
      // Verifica PIN
      final resultado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => const PinVerificationScreen(),
        ),
      );
      autenticado = resultado == true;
    } else {
      // PIN desabilitado, acesso direto
      autenticado = true;
    }

    if (autenticado) {
      // Navega para a área administrativa
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMainScreen(),
          ),
        );
      }
    }
  }

  /// Navega para tela de perfil do usuário
  void _navegarParaPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  /// Força verificação de estados (DEBUG)
  Future<void> _forcarVerificacaoEstados() async {
    if (kDebugMode) {
      debugPrint('🔧 DEBUG: Forçando verificação de estados...');
      await EstadoService().verificarAgora();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verificação de estados executada! Veja o console.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
      debugPrint('🔧 DEBUG: Verificação concluída');
    }
  }
}

