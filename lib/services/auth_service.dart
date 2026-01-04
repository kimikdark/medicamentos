import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../main.dart' show USE_MOCK_DATA;

/// Serviço para gestão de autenticação via Firebase Auth + PIN
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  FirebaseAuth? _authInstance;
  FirebaseFirestore? _firestoreInstance;

  FirebaseAuth get _auth {
    _authInstance ??= FirebaseAuth.instance;
    return _authInstance!;
  }

  FirebaseFirestore get _firestore {
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance!;
  }

  SharedPreferences? _prefs;

  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  /// Inicializa SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();

    // Load current user model if authenticated
    if (!USE_MOCK_DATA && _auth.currentUser != null) {
      await _loadUserModel(_auth.currentUser!.uid);
    }
  }

  /// Stream de mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtém o usuário atual do Firebase Auth
  User? get currentUser => _auth.currentUser;

  /// Verifica se existe um usuário autenticado
  bool get isLoggedIn => _auth.currentUser != null;

  // ===== FIREBASE AUTH METHODS =====

  /// Registra novo usuário com email e senha
  Future<UserModel?> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String pin = '1234',
  }) async {
    if (USE_MOCK_DATA) {
      debugPrint('MOCK: Register user $email');
      return null;
    }

    try {
      // Criar usuário no Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Atualizar display name
      await user.updateDisplayName(displayName);

      // Criar documento do usuário no Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        role: role,
        pin: pin,
      );

      await _firestore
          .collection(collectionUsers)
          .doc(user.uid)
          .set(userModel.toMap());

      _currentUserModel = userModel;
      debugPrint('✅ Usuário registrado: $email (${userModel.role})');

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao registrar: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Erro ao registrar usuário: $e');
      return null;
    }
  }

  /// Login com email e senha
  Future<UserModel?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (USE_MOCK_DATA) {
      debugPrint('MOCK: Login user $email');
      return null;
    }

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Carregar dados do usuário do Firestore
      await _loadUserModel(user.uid);

      // Atualizar último login
      if (_currentUserModel != null) {
        await _updateLastLogin();
      }

      debugPrint('✅ Login realizado: $email');
      return _currentUserModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao fazer login: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Erro ao fazer login: $e');
      return null;
    }
  }

  /// Carrega o modelo do usuário do Firestore
  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _firestore.collection(collectionUsers).doc(uid).get();
      if (doc.exists) {
        _currentUserModel = UserModel.fromMap(doc.data()!);
        debugPrint('UserModel carregado: ${_currentUserModel?.email}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar UserModel: $e');
    }
  }

  /// Atualiza o horário do último login
  Future<void> _updateLastLogin() async {
    if (_currentUserModel == null) return;

    try {
      await _firestore.collection(collectionUsers).doc(_currentUserModel!.uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Erro ao atualizar lastLogin: $e');
    }
  }

  /// Logout
  Future<void> signOut() async {
    if (USE_MOCK_DATA) {
      debugPrint('MOCK: Logout');
      _isAuthenticated = false;
      return;
    }

    try {
      await _auth.signOut();
      _currentUserModel = null;
      _isAuthenticated = false;
      debugPrint('✅ Logout realizado');
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    }
  }

  /// Envia email de recuperação de senha
  Future<bool> sendPasswordResetEmail(String email) async {
    if (USE_MOCK_DATA) {
      debugPrint('MOCK: Send password reset to $email');
      return true;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Email de recuperação enviado para $email');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Erro ao enviar email de recuperação: ${e.code}');
      return false;
    }
  }

  /// Atualiza o PIN do usuário
  Future<bool> updateUserPin(String newPin) async {
    if (_currentUserModel == null) return false;
    if (newPin.length != 4 || int.tryParse(newPin) == null) {
      debugPrint('PIN inválido: deve ter 4 dígitos');
      return false;
    }

    try {
      await _firestore.collection(collectionUsers).doc(_currentUserModel!.uid).update({
        'pin': newPin,
      });

      _currentUserModel = _currentUserModel!.copyWith(pin: newPin);
      debugPrint('✅ PIN atualizado');
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar PIN: $e');
      return false;
    }
  }

  /// Vincula um cuidador a um paciente
  Future<bool> linkCaregiverToPatient(String patientUid) async {
    if (_currentUserModel == null || !_currentUserModel!.isCaregiver) {
      debugPrint('Apenas cuidadores podem se vincular a pacientes');
      return false;
    }

    try {
      // Adiciona o patient aos linkedUsers do caregiver
      await _firestore.collection(collectionUsers).doc(_currentUserModel!.uid).update({
        'linkedUsers': FieldValue.arrayUnion([patientUid]),
      });

      // Adiciona o caregiver aos linkedUsers do patient
      await _firestore.collection(collectionUsers).doc(patientUid).update({
        'linkedUsers': FieldValue.arrayUnion([_currentUserModel!.uid]),
      });

      debugPrint('✅ Cuidador vinculado ao paciente');
      return true;
    } catch (e) {
      debugPrint('Erro ao vincular usuários: $e');
      return false;
    }
  }

  // ===== PIN METHODS (Legacy support) =====

  // ===== PIN METHODS (Legacy support) =====

  /// Verifica se PIN está configurado (legacy - SharedPreferences)
  Future<bool> isPinConfigured() async {
    await initialize();

    // Se tiver usuário autenticado, usa PIN do Firestore
    if (_currentUserModel != null) {
      return _currentUserModel!.pin.isNotEmpty;
    }

    // Senão, verifica SharedPreferences (modo mock ou legacy)
    final pin = _prefs?.getString(keyPin);
    return pin != null && pin.isNotEmpty;
  }

  /// Obtém o PIN atual
  Future<String?> getPin() async {
    await initialize();

    // Prioritiza PIN do usuário autenticado
    if (_currentUserModel != null) {
      return _currentUserModel!.pin;
    }

    // Fallback para SharedPreferences
    return _prefs?.getString(keyPin) ?? defaultPin;
  }

  /// Define novo PIN (legacy - apenas SharedPreferences)
  Future<bool> setPin(String newPin) async {
    if (newPin.length != 4 || int.tryParse(newPin) == null) {
      debugPrint('PIN inválido: deve ter 4 dígitos');
      return false;
    }

    // Se tiver usuário autenticado, atualiza no Firestore
    if (_currentUserModel != null) {
      return await updateUserPin(newPin);
    }

    // Senão, salva no SharedPreferences
    await initialize();
    final success = await _prefs?.setString(keyPin, newPin) ?? false;

    if (success) {
      debugPrint('PIN atualizado com sucesso (SharedPreferences)');
    } else {
      debugPrint('Erro ao atualizar PIN');
    }

    return success;
  }

  /// Verifica se o PIN fornecido está correto
  Future<bool> verifyPin(String inputPin) async {
    final storedPin = await getPin();
    final isValid = inputPin == storedPin;

    if (isValid) {
      debugPrint('PIN verificado com sucesso');
    } else {
      debugPrint('PIN incorreto');
    }

    return isValid;
  }

  /// Reseta PIN para o padrão
  Future<bool> resetPin() async {
    await initialize();
    final success = await _prefs?.setString(keyPin, defaultPin) ?? false;

    if (success) {
      debugPrint('PIN resetado para padrão');
    }

    return success;
  }

  /// Remove PIN (logout)
  Future<bool> clearPin() async {
    await initialize();
    final success = await _prefs?.remove(keyPin) ?? false;

    if (success) {
      debugPrint('PIN removido');
    }

    return success;
  }

  /// Verifica se o usuário está "autenticado" (PIN correto foi fornecido nesta sessão)
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    debugPrint('Status de autenticação: $_isAuthenticated');
  }

  /// Faz logout (legacy - apenas limpa flag local)
  void logout() {
    _isAuthenticated = false;
    debugPrint('Logout local realizado');
  }
}

