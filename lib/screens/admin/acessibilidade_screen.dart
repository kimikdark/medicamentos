import 'package:flutter/material.dart';
import '../../models/configuracao.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Tela de configurações de acessibilidade
class AcessibilidadeScreen extends StatefulWidget {
  const AcessibilidadeScreen({Key? key}) : super(key: key);

  @override
  State<AcessibilidadeScreen> createState() => _AcessibilidadeScreenState();
}

class _AcessibilidadeScreenState extends State<AcessibilidadeScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Configuracao? _config;
  bool _loading = true;

  bool _screenReaderAtivo = false;
  bool _altoContraste = false;
  double _fatorTamanhoFonte = 1.0;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final config = await _firebaseService.getConfiguracoes();
    if (!mounted) return;

    setState(() {
      _config = config;
      _screenReaderAtivo = config.screenReaderAtivo;
      _altoContraste = config.altoContraste;
      _fatorTamanhoFonte = config.fatorTamanhoFonte;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_config == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar configurações',
              style: TextStyle(fontSize: fontSizeMedium),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _carregarConfiguracoes,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        const Text(
          'Configurações de Acessibilidade',
          style: TextStyle(
            fontSize: fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: defaultPadding),

        // Screen Reader
        Card(
          child: SwitchListTile(
            title: const Text(
              'Screen Reader',
              style: TextStyle(
                fontSize: fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Ativa leitura de texto em voz alta',
              style: TextStyle(fontSize: fontSizeSmall),
            ),
            value: _screenReaderAtivo,
            onChanged: (value) {
              setState(() {
                _screenReaderAtivo = value;
              });
            },
            secondary: const Icon(Icons.record_voice_over, size: 32),
          ),
        ),

        const SizedBox(height: defaultPadding),

        // Alto Contraste
        Card(
          child: SwitchListTile(
            title: const Text(
              'Alto Contraste',
              style: TextStyle(
                fontSize: fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              'Aumenta contraste para melhor visibilidade',
              style: TextStyle(fontSize: fontSizeSmall),
            ),
            value: _altoContraste,
            onChanged: (value) {
              setState(() {
                _altoContraste = value;
              });
            },
            secondary: const Icon(Icons.contrast, size: 32),
          ),
        ),

        const SizedBox(height: defaultPadding),

        // Tamanho do texto
        Card(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.text_fields, size: 32),
                    SizedBox(width: defaultPadding),
                    Text(
                      'Tamanho do Texto',
                      style: TextStyle(
                        fontSize: fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: defaultPadding),

                // Preview do texto
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Exemplo de texto com tamanho ${(_fatorTamanhoFonte * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: fontSizeMedium * _fatorTamanhoFonte,
                    ),
                  ),
                ),

                const SizedBox(height: defaultPadding),

                // Slider
                Row(
                  children: [
                    const Text('A', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: _fatorTamanhoFonte,
                        min: minFatorFonte,
                        max: maxFatorFonte,
                        divisions: 12,
                        label: '${(_fatorTamanhoFonte * 100).toInt()}%',
                        onChanged: (value) {
                          setState(() {
                            _fatorTamanhoFonte = value;
                          });
                        },
                      ),
                    ),
                    const Text('A', style: TextStyle(fontSize: 24)),
                  ],
                ),

                Center(
                  child: Text(
                    '${(_fatorTamanhoFonte * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: largePadding),

        // Informações adicionais
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              children: const [
                Icon(Icons.info_outline, size: 32, color: Colors.blue),
                SizedBox(height: smallPadding),
                Text(
                  'Dica de Acessibilidade',
                  style: TextStyle(
                    fontSize: fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: smallPadding),
                Text(
                  'Use botões grandes e texto legível para facilitar o uso por pessoas idosas ou com dificuldades visuais.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: fontSizeSmall),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: largePadding),

        // Botão salvar
        SizedBox(
          width: double.infinity,
          height: buttonMinHeight,
          child: ElevatedButton(
            onPressed: _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
            ),
            child: const Text(
              'GUARDAR CONFIGURAÇÕES',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: defaultPadding), // Espaço extra no final
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    final novaConfig = _config!.copyWith(
      screenReaderAtivo: _screenReaderAtivo,
      altoContraste: _altoContraste,
      fatorTamanhoFonte: _fatorTamanhoFonte,
    );

    final sucesso = await _firebaseService.salvarConfiguracoes(novaConfig);

    if (sucesso) {
      if (mounted) {
        showMessage(context, 'Configurações de acessibilidade salvas');

        // Aviso sobre reiniciar app para aplicar mudanças
        if (_fatorTamanhoFonte != _config!.fatorTamanhoFonte) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Atenção', style: TextStyle(fontSize: fontSizeLarge)),
              content: const Text(
                'Reinicie a aplicação para aplicar completamente as mudanças de tamanho de texto.',
                style: TextStyle(fontSize: fontSizeMedium),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(fontSize: fontSizeMedium)),
                ),
              ],
            ),
          );
        }
      }

      setState(() {
        _config = novaConfig;
      });
    } else {
      if (mounted) {
        showMessage(context, 'Erro ao salvar configurações', isError: true);
      }
    }
  }
}

