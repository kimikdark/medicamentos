import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/medicamento.dart';
import '../models/configuracao.dart';
import '../utils/constants.dart';
import '../main.dart' show USE_MOCK_DATA;
import 'mock_firebase_service.dart';

/// Serviço singleton para gerenciar Firebase
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final MockFirebaseService _mockService = MockFirebaseService();

  bool _initialized = false;
  bool get initialized => _initialized;

  /// Inicializa o Firebase
  Future<void> initialize({FirebaseOptions? options}) async {
    if (_initialized) return;

    if (USE_MOCK_DATA) {
      debugPrint('✅ Firebase Service inicializado em MODO MOCK');
      _initialized = true;
      return;
    }

    try {
      if (options != null) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }

      // Habilitar persistência offline (apenas em plataformas que suportam)
      try {
        _firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        debugPrint('Aviso: Não foi possível configurar persistência: $e');
      }

      _initialized = true;
      debugPrint('Firebase inicializado com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar Firebase: $e');
      // Não fazer rethrow para permitir que a app funcione offline
      _initialized = true; // Marca como inicializado mesmo com erro
    }
  }

  // ===== MEDICAMENTOS =====

  /// Stream de medicamentos em tempo real
  Stream<List<Medicamento>> getMedicamentosStream() {
    if (USE_MOCK_DATA) {
      return _mockService.getMedicamentosStream();
    }
    return _firestore
        .collection(collectionMedicamentos)
        .orderBy('horaToma')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medicamento.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Obtém lista de medicamentos (snapshot único)
  Future<List<Medicamento>> getMedicamentos() async {
    if (USE_MOCK_DATA) {
      return _mockService.getMedicamentos();
    }

    try {
      final snapshot = await _firestore
          .collection(collectionMedicamentos)
          .orderBy('horaToma')
          .get();

      return snapshot.docs
          .map((doc) => Medicamento.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter medicamentos: $e');
      return [];
    }
  }

  /// Adiciona novo medicamento
  Future<String?> adicionarMedicamento(Medicamento medicamento) async {
    if (USE_MOCK_DATA) {
      return _mockService.adicionarMedicamento(medicamento);
    }

    try {
      final docRef = await _firestore
          .collection(collectionMedicamentos)
          .add(medicamento.toMap());

      debugPrint('Medicamento adicionado com ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Erro ao adicionar medicamento: $e');
      return null;
    }
  }

  /// Atualiza medicamento existente
  Future<bool> atualizarMedicamento(Medicamento medicamento) async {
    if (USE_MOCK_DATA) {
      return _mockService.atualizarMedicamento(medicamento);
    }

    if (medicamento.id == null) return false;

    try {
      await _firestore
          .collection(collectionMedicamentos)
          .doc(medicamento.id)
          .update(medicamento.toMap());

      debugPrint('Medicamento ${medicamento.id} atualizado');
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar medicamento: $e');
      return false;
    }
  }

  /// Deleta medicamento
  Future<bool> deletarMedicamento(String medicamentoId) async {
    if (USE_MOCK_DATA) {
      return _mockService.deletarMedicamento(medicamentoId);
    }
    try {
      await _firestore
          .collection(collectionMedicamentos)
          .doc(medicamentoId)
          .delete();

      debugPrint('Medicamento $medicamentoId deletado');
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar medicamento: $e');
      return false;
    }
  }

  /// Atualiza apenas o estado do medicamento
  Future<bool> atualizarEstadoMedicamento(
    String medicamentoId,
    EstadoMedicamento novoEstado,
  ) async {
    if (USE_MOCK_DATA) {
      return _mockService.atualizarEstadoMedicamento(medicamentoId, novoEstado);
    }
    try {
      final updates = {
        'estado': novoEstado.index,
        'dataUltimaMudancaEstado': Timestamp.now(),
      };

      if (novoEstado == EstadoMedicamento.tomado) {
        updates['dataTomada'] = Timestamp.now();
      }

      await _firestore
          .collection(collectionMedicamentos)
          .doc(medicamentoId)
          .update(updates);

      debugPrint('Estado do medicamento $medicamentoId atualizado para $novoEstado');
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar estado: $e');
      return false;
    }
  }

  // ===== CONFIGURAÇÕES =====

  /// Obtém configurações
  Future<Configuracao> getConfiguracoes() async {
    if (USE_MOCK_DATA) {
      return _mockService.getConfiguracoes();
    }
    try {
      final snapshot = await _firestore
          .collection(collectionConfiguracoes)
          .doc('app_config')
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        return Configuracao.fromMap(snapshot.data()!, snapshot.id);
      }

      // Se não existe, cria configuração padrão
      final configPadrao = Configuracao.defaultConfig();
      await salvarConfiguracoes(configPadrao);
      return configPadrao;
    } catch (e) {
      debugPrint('Erro ao obter configurações: $e');
      // Se offline ou erro, retorna configuração padrão sem tentar salvar
      return Configuracao.defaultConfig();
    }
  }

  /// Salva configurações
  Future<bool> salvarConfiguracoes(Configuracao config) async {
    if (USE_MOCK_DATA) {
      return _mockService.salvarConfiguracoes(config);
    }
    try {
      await _firestore
          .collection(collectionConfiguracoes)
          .doc('app_config')
          .set(config.toMap());

      debugPrint('Configurações salvas');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
      return false;
    }
  }

  // ===== HISTÓRICO =====

  /// Adiciona entrada ao histórico
  Future<void> adicionarAoHistorico(Medicamento medicamento) async {
    if (USE_MOCK_DATA) {
      return _mockService.adicionarAoHistorico(medicamento);
    }
    try {
      await _firestore.collection(collectionHistorico).add({
        'medicamentoId': medicamento.id,
        'nome': medicamento.nome,
        'estado': medicamento.estado.index,
        'estadoString': medicamento.estadoString,
        'horaToma': medicamento.horaTomaString,
        'timestamp': Timestamp.now(),
      });

      debugPrint('Entrada adicionada ao histórico');
    } catch (e) {
      debugPrint('Erro ao adicionar ao histórico: $e');
    }
  }

  /// Obtém histórico ordenado
  Future<List<Map<String, dynamic>>> getHistorico({
    bool ordenarCrescente = false,
  }) async {
    if (USE_MOCK_DATA) {
      return _mockService.getHistorico(ordenarCrescente: ordenarCrescente);
    }
    try {
      Query query = _firestore.collection(collectionHistorico);

      if (ordenarCrescente) {
        query = query.orderBy('timestamp', descending: false);
      } else {
        query = query.orderBy('timestamp', descending: true);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (e) {
      debugPrint('Erro ao obter histórico: $e');
      return [];
    }
  }
}
