import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import 'configuracao_medicacao_screen.dart';
import 'administracao_screen.dart';
import 'historico_screen.dart';
import 'acessibilidade_screen.dart';
import 'parcerias_screen.dart';

/// Tela principal da área administrativa com bottom navigation bar
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({Key? key}) : super(key: key);

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ConfiguracaoMedicacaoScreen(),
    AdministracaoScreen(),
    HistoricoScreen(),
    AcessibilidadeScreen(),
    ParceriasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Administração',
        showBackButton: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: brandGreen,
        unselectedItemColor: Colors.grey,
        selectedFontSize: fontSizeSmall,
        unselectedFontSize: fontSizeSmall,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.medication, size: 28),
            label: 'Medicação',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, size: 28),
            label: 'Config',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 28),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new, size: 28),
            label: 'Acessib.',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business, size: 28),
            label: 'Parceiros',
          ),
        ],
      ),
    );
  }
}

