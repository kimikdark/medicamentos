import 'package:flutter/material.dart';
import '../../models/configuracao.dart';
import '../../services/firebase_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Tela de administração (PIN, timers, cuidadores)
class AdministracaoScreen extends StatefulWidget {
  const AdministracaoScreen({Key? key}) : super(key: key);

  @override
  State<AdministracaoScreen> createState() => _AdministracaoScreenState();
}

class _AdministracaoScreenState extends State<AdministracaoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  Configuracao? _config;
  bool _loading = true;

  late TextEditingController _pinController;
  late TextEditingController _minutosFinalizadoController;
  late TextEditingController _minutosNaoTomadoController;
  late TextEditingController _cuidadoresController;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _minutosFinalizadoController = TextEditingController();
    _minutosNaoTomadoController = TextEditingController();
    _cuidadoresController = TextEditingController();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final config = await _firebaseService.getConfiguracoes();
    if (!mounted) return;

    setState(() {
      _config = config;
      _pinController.text = config.pin;
      _minutosFinalizadoController.text = config.minutosParaFinalizado.toString();
      _minutosNaoTomadoController.text = config.minutosParaNaoTomado.toString();
      _cuidadoresController.text = phoneNumbersToString(config.numerosCuidadores);
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _minutosFinalizadoController.dispose();
    _minutosNaoTomadoController.dispose();
    _cuidadoresController.dispose();
    super.dispose();
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
          'Configurações Gerais',
          style: TextStyle(
            fontSize: fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: defaultPadding),

        // PIN
        Card(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Segurança por PIN',
                      style: TextStyle(
                        fontSize: fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _config!.pinEnabled,
                      onChanged: (value) {
                        if (value) {
                          _mostrarDialogConfigurarPin();
                        } else {
                          setState(() {
                            _config = _config!.copyWith(pinEnabled: false);
                          });
                        }
                      },
                      activeTrackColor: brandGreen,
                    ),
                  ],
                ),
                const SizedBox(height: smallPadding),
                Text(
                  _config!.pinEnabled
                      ? 'PIN ativado - acesso à área administrativa protegido'
                      : 'PIN desativado - acesso livre à área administrativa',
                  style: TextStyle(
                    fontSize: fontSizeSmall,
                    color: Colors.grey[600],
                  ),
                ),
                if (_config!.pinEnabled) ...[
                  const SizedBox(height: defaultPadding),
                  OutlinedButton.icon(
                    onPressed: _mostrarDialogConfigurarPin,
                    icon: const Icon(Icons.edit),
                    label: const Text('Alterar PIN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: brandGreen,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: defaultPadding),

        // Timers
        Card(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tempos de Transição',
                  style: TextStyle(
                    fontSize: fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: smallPadding),
                TextField(
                  controller: _minutosFinalizadoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutos até "Finalizado"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.timer),
                    helperText: 'Tempo desde a hora da toma agendada',
                  ),
                  style: const TextStyle(fontSize: fontSizeMedium),
                ),
                const SizedBox(height: defaultPadding),
                TextField(
                  controller: _minutosNaoTomadoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutos até "Não Tomado"',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning),
                    helperText: 'Tempo desde a hora da toma sem confirmação',
                  ),
                  style: const TextStyle(fontSize: fontSizeMedium),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: defaultPadding),

        // Cuidadores
        Card(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Números dos Cuidadores',
                  style: TextStyle(
                    fontSize: fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: smallPadding),
                TextField(
                  controller: _cuidadoresController,
                  keyboardType: TextInputType.phone,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Números (separados por vírgula)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    helperText: 'Ex: 912345678, 918765432',
                  ),
                  style: const TextStyle(fontSize: fontSizeMedium),
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

  Future<void> _mostrarDialogConfigurarPin() async {
    final pinController = TextEditingController(text: _config?.pin ?? '1234');
    final confirmPinController = TextEditingController();

    final resultado = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Configurar PIN',
            style: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Digite um PIN de 4 dígitos para proteger o acesso à área administrativa.',
                  style: TextStyle(fontSize: fontSizeMedium),
                ),
                const SizedBox(height: defaultPadding),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Novo PIN (4 dígitos)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  style: const TextStyle(fontSize: fontSizeMedium),
                ),
                const SizedBox(height: defaultPadding),
                TextField(
                  controller: confirmPinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar PIN',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  style: const TextStyle(fontSize: fontSizeMedium),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = pinController.text;
                final confirmPin = confirmPinController.text;

                if (!isValidPin(pin)) {
                  showMessage(context, 'PIN deve ter 4 dígitos', isError: true);
                  return;
                }

                if (pin != confirmPin) {
                  showMessage(context, 'Os PINs não coincidem', isError: true);
                  return;
                }

                Navigator.of(context).pop(pin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (resultado != null) {
      setState(() {
        _config = _config!.copyWith(
          pin: resultado,
          pinEnabled: true,
        );
        _pinController.text = resultado;
      });

      if (mounted) {
        showMessage(context, 'PIN configurado. Não esqueça de guardar as configurações.');
      }
    }
  }

  Future<void> _salvar() async {
    // Valida PIN
    if (!isValidPin(_pinController.text)) {
      showMessage(context, 'PIN deve ter 4 dígitos', isError: true);
      return;
    }

    // Valida minutos
    final minFinalizado = int.tryParse(_minutosFinalizadoController.text);
    final minNaoTomado = int.tryParse(_minutosNaoTomadoController.text);

    if (minFinalizado == null || minFinalizado < 1) {
      showMessage(context, 'Minutos inválidos', isError: true);
      return;
    }

    if (minNaoTomado == null || minNaoTomado < 1) {
      showMessage(context, 'Minutos inválidos', isError: true);
      return;
    }

    // Parse números de telefone
    final numeros = parsePhoneNumbers(_cuidadoresController.text);

    final novaConfig = _config!.copyWith(
      pin: _pinController.text,
      pinEnabled: _config!.pinEnabled,
      minutosParaFinalizado: minFinalizado,
      minutosParaNaoTomado: minNaoTomado,
      numerosCuidadores: numeros,
    );

    final sucesso = await _firebaseService.salvarConfiguracoes(novaConfig);

    if (sucesso) {
      // Atualiza PIN no AuthService
      await _authService.setPin(novaConfig.pin);

      if (mounted) {
        showMessage(context, 'Configurações salvas com sucesso');
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

