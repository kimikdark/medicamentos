import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicamento.dart';

/// Serviço para gestão de notificações locais e push
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging? _messaging;

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Inicializar timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Lisbon'));

      // Configurar notificações locais
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Configurar Firebase Messaging
      _messaging = FirebaseMessaging.instance;

      // Solicitar permissões
      await _requestPermissions();

      // Configurar handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      _initialized = true;
      debugPrint('NotificationService inicializado');
    } catch (e) {
      debugPrint('Erro ao inicializar NotificationService: $e');
    }
  }

  /// Solicita permissões de notificação
  Future<void> _requestPermissions() async {
    try {
      if (_messaging != null) {
        final settings = await _messaging!.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        debugPrint('Permissão de notificações: ${settings.authorizationStatus}');
      }

      // Android 13+ requer permissão adicional
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Erro ao solicitar permissões: $e');
    }
  }

  /// Handler para notificações em primeiro plano
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Mensagem recebida em foreground: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'Notificação',
        body: message.notification!.body ?? '',
      );
    }
  }

  /// Handler para quando app é aberto via notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('App aberto via notificação: ${message.notification?.title}');
    // TODO: Navegar para tela específica se necessário
  }

  /// Handler para quando notificação local é clicada
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificação local clicada: ${response.payload}');
    // TODO: Navegar para tela específica baseado no payload
  }

  /// Mostra notificação local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'medicamentos_channel',
      'Lembretes de Medicamentos',
      channelDescription: 'Notificações para lembrar de tomar medicamentos',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Agenda notificação para horário específico de medicamento
  Future<void> agendarNotificacaoMedicamento(Medicamento medicamento) async {
    if (!_initialized) {
      await initialize();
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        medicamento.horaToma.hour,
        medicamento.horaToma.minute,
      );

      // Se o horário já passou hoje, agenda para amanhã
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'medicamentos_channel',
        'Lembretes de Medicamentos',
        channelDescription: 'Notificações para lembrar de tomar medicamentos',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        medicamento.id.hashCode,
        'Hora de tomar medicamento',
        '"${medicamento.nome}" por tomar',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: medicamento.id,
      );

      debugPrint(
          'Notificação agendada para ${medicamento.nome} às ${medicamento.horaTomaString}');
    } catch (e) {
      debugPrint('Erro ao agendar notificação: $e');
    }
  }

  /// Cancela notificação de um medicamento específico
  Future<void> cancelarNotificacao(String medicamentoId) async {
    try {
      await _localNotifications.cancel(medicamentoId.hashCode);
      debugPrint('Notificação cancelada para $medicamentoId');
    } catch (e) {
      debugPrint('Erro ao cancelar notificação: $e');
    }
  }

  /// Cancela todas as notificações
  Future<void> cancelarTodasNotificacoes() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('Todas as notificações canceladas');
    } catch (e) {
      debugPrint('Erro ao cancelar notificações: $e');
    }
  }

  /// Mostra notificação imediata (para teste ou alertas urgentes)
  Future<void> mostrarNotificacao({
    required String titulo,
    required String mensagem,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    await _showLocalNotification(
      title: titulo,
      body: mensagem,
    );
  }

  /// Obtém token FCM (para envio de notificações remotas)
  Future<String?> getToken() async {
    try {
      return await _messaging?.getToken();
    } catch (e) {
      debugPrint('Erro ao obter token FCM: $e');
      return null;
    }
  }
}

