import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_app_bar.dart';

/// Tela de verificação de PIN
class PinVerificationScreen extends StatefulWidget {
  const PinVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends State<PinVerificationScreen> {
  final AuthService _authService = AuthService();
  String _currentPin = '';
  bool _hasError = false;
  // Chave para forçar rebuild do PinCodeTextField
  Key _pinFieldKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Verificação de Segurança',
        showBackButton: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de cadeado
              Container(
                padding: const EdgeInsets.all(largePadding),
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: brandGreen,
                ),
              ),

              const SizedBox(height: largePadding),

              // Título
              const Text(
                'Digite o PIN',
                style: TextStyle(
                  fontSize: fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: smallPadding),

              // Subtítulo
              Text(
                'Digite o PIN de 4 dígitos para acessar a área administrativa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSizeMedium,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: largePadding * 2),

              // Campo de PIN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: largePadding),
                child: PinCodeTextField(
                  key: _pinFieldKey,
                  appContext: context,
                  length: 4,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 70,
                    fieldWidth: 60,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.white,
                    selectedFillColor: Colors.white,
                    activeColor: _hasError ? Colors.red : brandGreen,
                    inactiveColor: Colors.grey,
                    selectedColor: brandGreen,
                    errorBorderColor: Colors.red,
                  ),
                  cursorColor: brandGreen,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  textStyle: const TextStyle(
                    fontSize: fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                  onCompleted: (pin) {
                    _verificarPin(pin);
                  },
                  onChanged: (value) {
                    if (mounted) {
                      setState(() {
                        _currentPin = value;
                        _hasError = false;
                      });
                    }
                  },
                ),
              ),

              if (_hasError) ...[
                const SizedBox(height: defaultPadding),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: smallPadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.error, color: Colors.red, size: 20),
                      SizedBox(width: smallPadding),
                      Text(
                        'PIN incorreto. Tente novamente.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: fontSizeMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: largePadding * 2),

              // Botão de verificar (caso o PIN não esteja completo)
              if (_currentPin.length < 4)
                Text(
                  'Digite os 4 dígitos do PIN',
                  style: TextStyle(
                    fontSize: fontSizeMedium,
                    color: Colors.grey[500],
                  ),
                ),

              const SizedBox(height: largePadding),

              // Dica de PIN padrão (apenas em desenvolvimento)
              if (const bool.fromEnvironment('dart.vm.product') == false)
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        '⚠️ Modo de Desenvolvimento',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'PIN padrão: 1234',
                        style: TextStyle(
                          fontSize: fontSizeSmall,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verificarPin(String pin) async {
    try {
      final valido = await _authService.verifyPin(pin);

      if (valido) {
        _authService.setAuthenticated(true);

        if (mounted) {
          showMessage(context, 'PIN correto! Bem-vindo.');

          // Aguarda um momento antes de voltar
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pop(context, true);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
          });

          // Limpa o campo após erro recriando o widget
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _currentPin = '';
                _hasError = false;
                _pinFieldKey = UniqueKey(); // Força rebuild do campo
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar PIN: $e');
      if (mounted) {
        showMessage(context, 'Erro ao verificar PIN', isError: true);
      }
    }
  }
}

