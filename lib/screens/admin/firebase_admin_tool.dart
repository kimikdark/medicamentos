import 'package:flutter/material.dart';
import '../services/firebase_init_service.dart';

/// Ferramenta administrativa para gerenciar o Firestore
/// Apenas para desenvolvimento/debug
class FirebaseAdminTool extends StatefulWidget {
  const FirebaseAdminTool({Key? key}) : super(key: key);

  @override
  State<FirebaseAdminTool> createState() => _FirebaseAdminToolState();
}

class _FirebaseAdminToolState extends State<FirebaseAdminTool> {
  final _initService = FirebaseInitService();
  bool _loading = false;
  String _message = '';

  Future<void> _checkDatabase() async {
    setState(() {
      _loading = true;
      _message = 'Verificando...';
    });

    try {
      final isEmpty = await _initService.isDatabaseEmpty();
      setState(() {
        _message = isEmpty
            ? '📦 Banco de dados está vazio'
            : '✅ Banco de dados contém dados';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Erro: $e';
        _loading = false;
      });
    }
  }

  Future<void> _initializeDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Criar estrutura inicial com dados de exemplo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _message = 'Criando estrutura...';
    });

    try {
      await _initService.initializeDatabase();
      setState(() {
        _message = '✅ Banco de dados inicializado com sucesso!';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Erro: $e';
        _loading = false;
      });
    }
  }

  Future<void> _clearDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ATENÇÃO'),
        content: const Text(
          'Isso irá REMOVER TODOS OS DADOS do Firestore!\n\n'
          'Esta ação é IRREVERSÍVEL.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('APAGAR TUDO'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _loading = true;
      _message = 'Removendo todos os dados...';
    });

    try {
      await _initService.clearAllData();
      setState(() {
        _message = '✅ Todos os dados foram removidos';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _message = '❌ Erro: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Firebase Admin Tool'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '⚠️ FERRAMENTA DE DESENVOLVIMENTO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Use esta ferramenta para gerenciar o Firestore durante o desenvolvimento.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            if (_message.isNotEmpty) ...[
              Card(
                color: _message.startsWith('❌')
                    ? Colors.red[50]
                    : Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _message,
                    style: TextStyle(
                      fontSize: 16,
                      color: _message.startsWith('❌')
                          ? Colors.red[900]
                          : Colors.green[900],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _checkDatabase,
                icon: const Icon(Icons.search),
                label: const Text('Verificar Banco de Dados'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _initializeDatabase,
                icon: const Icon(Icons.add_circle),
                label: const Text('Criar Estrutura Inicial'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _clearDatabase,
                icon: const Icon(Icons.delete_forever),
                label: const Text('APAGAR TODOS OS DADOS'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            const Spacer(),

            const Divider(),
            const SizedBox(height: 8),

            const Text(
              'Informações:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Projeto: velhos-medicamentos'),
            const Text('• PIN padrão: 1234'),
            const Text('• Coleções: medicamentos, configuracoes, historico'),

            const SizedBox(height: 16),

            TextButton.icon(
              onPressed: () {
                // Abrir console do Firebase
                debugPrint('Console: https://console.firebase.google.com/project/velhos-medicamentos/firestore');
              },
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Ver no Firebase Console'),
            ),
          ],
        ),
      ),
    );
  }
}

