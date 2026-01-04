import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../main.dart' show USE_MOCK_DATA;

/// Tela de Perfil do Usuário
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_authService.currentUserModel != null) {
      _pinController.text = _authService.currentUserModel!.pin;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      await _authService.signOut();
      // Não precisa navegar - o AuthWrapper vai detectar e mostrar LoginScreen
    }
  }

  Future<void> _handleUpdatePin() async {
    final newPin = _pinController.text;

    if (newPin.length != 4 || int.tryParse(newPin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN deve ter 4 dígitos numéricos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _authService.updateUserPin(newPin);

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'PIN atualizado com sucesso!' : 'Erro ao atualizar PIN',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = _authService.currentUserModel;

    if (USE_MOCK_DATA) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Perfil',
          showBackButton: true,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(largePadding),
            child: Text(
              'Perfil de usuário não disponível em modo MOCK.\n\nConfigure o Firebase para usar autenticação real.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSizeMedium),
            ),
          ),
        ),
      );
    }

    if (userModel == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuário não autenticado'),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Perfil',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(largePadding),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundColor: brandGreen.withOpacity(0.2),
              child: userModel.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        userModel.photoUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: brandGreen,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: brandGreen,
                    ),
            ),

            const SizedBox(height: defaultPadding),

            // Nome
            Text(
              userModel.displayName ?? 'Sem nome',
              style: const TextStyle(
                fontSize: fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: smallPadding),

            // Email
            Text(
              userModel.email,
              style: const TextStyle(
                fontSize: fontSizeMedium,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: smallPadding),

            // Badge de tipo de usuário
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: smallPadding,
              ),
              decoration: BoxDecoration(
                color: userModel.isCaregiver ? brandBlue : brandGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userModel.isCaregiver ? 'CUIDADOR' : 'PACIENTE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: largePadding * 2),

            // Informações da conta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informações da Conta',
                      style: TextStyle(
                        fontSize: fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),

                    _buildInfoRow('UID', userModel.uid),
                    const SizedBox(height: smallPadding),
                    _buildInfoRow('Tipo', userModel.isCaregiver ? 'Cuidador' : 'Paciente'),
                    const SizedBox(height: smallPadding),
                    _buildInfoRow(
                      'Membro desde',
                      '${userModel.createdAt.day}/${userModel.createdAt.month}/${userModel.createdAt.year}',
                    ),
                    const SizedBox(height: smallPadding),
                    _buildInfoRow(
                      'Último acesso',
                      '${userModel.lastLogin.day}/${userModel.lastLogin.month}/${userModel.lastLogin.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: defaultPadding),

            // Configuração de PIN
            Card(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PIN de Acesso Rápido',
                      style: TextStyle(
                        fontSize: fontSizeMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: smallPadding),
                    const Text(
                      'PIN para acesso rápido à área administrativa',
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: 'PIN (4 dígitos)',
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleUpdatePin,
                          child: const Text('Atualizar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: largePadding * 2),

            // Botão de Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'SAIR DA CONTA',
                  style: TextStyle(
                    fontSize: fontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, buttonMinHeight),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: fontSizeSmall,
            color: Colors.grey,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

