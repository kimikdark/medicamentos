import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

/// Serviço para gestão de autenticação via PIN
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SharedPreferences? _prefs;

  /// Inicializa SharedPreferences
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Verifica se PIN está configurado
  Future<bool> isPinConfigured() async {
    await initialize();
    final pin = _prefs?.getString(keyPin);
    return pin != null && pin.isNotEmpty;
  }

  /// Obtém o PIN atual (para comparação)
  Future<String?> getPin() async {
    await initialize();
    return _prefs?.getString(keyPin) ?? defaultPin;
  }

  /// Define novo PIN
  Future<bool> setPin(String newPin) async {
    if (newPin.length != 4 || int.tryParse(newPin) == null) {
      debugPrint('PIN inválido: deve ter 4 dígitos');
      return false;
    }

    await initialize();
    final success = await _prefs?.setString(keyPin, newPin) ?? false;

    if (success) {
      debugPrint('PIN atualizado com sucesso');
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

  /// Faz logout
  void logout() {
    _isAuthenticated = false;
    debugPrint('Logout realizado');
  }
}

