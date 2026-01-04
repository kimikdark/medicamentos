import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'firebase_options.dart';
import 'services/firebase_service.dart';
import 'services/firebase_init_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/estado_service.dart';
import 'screens/home/home_screen.dart';
import 'utils/constants.dart';

// ⚠️ MODO DE DESENVOLVIMENTO
// true = Usa dados mock (não precisa Firebase)
// false = Usa Firebase real (precisa estar configurado)
const bool USE_MOCK_DATA = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientação (apenas retrato para facilitar uso por idosos)
  // Não aplicar no web
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Inicializar serviços
  try {
    if (USE_MOCK_DATA) {
      debugPrint('🔶 MODO MOCK ATIVO - Usando dados locais (sem Firebase)');
      debugPrint('🔶 Para usar Firebase real, mude USE_MOCK_DATA para false');
    } else {
      debugPrint('🔷 MODO FIREBASE ATIVO - Conectando ao Firebase...');
      await FirebaseService().initialize(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Verificar e inicializar banco de dados se estiver vazio
      final initService = FirebaseInitService();
      final isEmpty = await initService.isDatabaseEmpty();
      if (isEmpty) {
        debugPrint('📦 Banco de dados vazio, criando estrutura inicial...');
        await initService.initializeDatabase();
      } else {
        debugPrint('✓ Banco de dados já contém dados');
      }
    }

    await AuthService().initialize();

    // Notificações e estado service não funcionam no web
    if (!kIsWeb && !USE_MOCK_DATA) {
      await NotificationService().initialize();
      EstadoService().iniciar();
    }
  } catch (e) {
    debugPrint('Erro ao inicializar serviços: $e');
    if (!USE_MOCK_DATA) {
      debugPrint('💡 Dica: Tente mudar USE_MOCK_DATA para true para testar sem Firebase');
    }
  }

  runApp(const MedicamentosApp());
}

class MedicamentosApp extends StatelessWidget {
  const MedicamentosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          primary: brandGreen,
          secondary: brandBlue,
        ),
        useMaterial3: true,

        // Tema de texto base (será multiplicado pelo fator de acessibilidade)
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: fontSizeXLarge),
          displayMedium: TextStyle(fontSize: fontSizeLarge),
          bodyLarge: TextStyle(fontSize: fontSizeMedium),
          bodyMedium: TextStyle(fontSize: fontSizeMedium),
          labelLarge: TextStyle(fontSize: fontSizeMedium),
        ),

        // Tema de botões (grandes para facilitar toque)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(buttonMinWidth, buttonMinHeight),
            textStyle: const TextStyle(fontSize: fontSizeMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: brandGreen,
          foregroundColor: Colors.white,
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
