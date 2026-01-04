import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../models/medicamento.dart';
import '../models/configuracao.dart';
import '../utils/constants.dart';

/// Serviço para inicializar Firestore com dados de exemplo
class FirebaseInitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Verifica se o Firestore já tem dados
  Future<bool> isDatabaseEmpty() async {
    try {
      final medicamentosSnapshot = await _firestore
          .collection(collectionMedicamentos)
          .limit(1)
          .get();

      final configSnapshot = await _firestore
          .collection(collectionConfiguracoes)
          .limit(1)
          .get();

      return medicamentosSnapshot.docs.isEmpty && configSnapshot.docs.isEmpty;
    } catch (e) {
      debugPrint('Erro ao verificar banco de dados: $e');
      return false;
    }
  }

  /// Inicializa o banco de dados com configurações padrão
  Future<void> initializeDatabase() async {
    try {
      debugPrint('🔷 Inicializando Firestore com dados padrão...');

      // Criar configuração padrão
      await _createDefaultConfig();

      // Criar alguns medicamentos de exemplo
      await _createSampleMedicamentos();

      debugPrint('✅ Firestore inicializado com sucesso!');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar Firestore: $e');
      rethrow;
    }
  }

  /// Cria configuração padrão
  Future<void> _createDefaultConfig() async {
    final config = Configuracao(
      id: 'default',
      pin: '1234',
      minutosParaNaoTomado: 60, // 1 hora
      minutosParaFinalizado: 10, // 10 minutos
      numerosCuidadores: [],
      fatorTamanhoFonte: 1.0,
      altoContraste: false,
      screenReaderAtivo: false,
    );

    await _firestore
        .collection(collectionConfiguracoes)
        .doc('default')
        .set(config.toMap());

    debugPrint('✓ Configuração padrão criada (PIN: 1234)');
  }

  /// Cria medicamentos de exemplo
  Future<void> _createSampleMedicamentos() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Criar 3 medicamentos de exemplo para diferentes horários
    final medicamentos = [
      Medicamento(
        id: '',
        nome: 'Paracetamol',
        tipo: TipoMedicamento.comprimido,
        horaToma: TimeOfDay(hour: 9, minute: 0),
        estado: EstadoMedicamento.porTomar,
        notas: 'Tomar após o pequeno-almoço',
        frequenciaRepeticao: FrequenciaRepeticao.diaria,
        dataCriacao: now,
      ),
      Medicamento(
        id: '',
        nome: 'Insulina',
        tipo: TipoMedicamento.injetavel,
        horaToma: TimeOfDay(hour: 12, minute: 0),
        estado: EstadoMedicamento.porTomar,
        notas: 'Antes do almoço',
        frequenciaRepeticao: FrequenciaRepeticao.diaria,
        dataCriacao: now,
      ),
      Medicamento(
        id: '',
        nome: 'Vitamina D',
        tipo: TipoMedicamento.gotas,
        horaToma: TimeOfDay(hour: 20, minute: 0),
        estado: EstadoMedicamento.porTomar,
        notas: '5 gotas',
        frequenciaRepeticao: FrequenciaRepeticao.diaria,
        dataCriacao: now,
      ),
    ];

    for (final medicamento in medicamentos) {
      final docRef = await _firestore
          .collection(collectionMedicamentos)
          .add(medicamento.toMap());

      debugPrint('✓ Medicamento "${medicamento.nome}" criado (ID: ${docRef.id})');
    }
  }

  /// Remove todos os dados do Firestore (use com cuidado!)
  Future<void> clearAllData() async {
    try {
      debugPrint('⚠️ Removendo todos os dados do Firestore...');

      // Remover medicamentos
      final medicamentosSnapshot = await _firestore
          .collection(collectionMedicamentos)
          .get();

      for (final doc in medicamentosSnapshot.docs) {
        await doc.reference.delete();
      }

      // Remover configurações
      final configSnapshot = await _firestore
          .collection(collectionConfiguracoes)
          .get();

      for (final doc in configSnapshot.docs) {
        await doc.reference.delete();
      }

      // Remover histórico
      final historicoSnapshot = await _firestore
          .collection(collectionHistorico)
          .get();

      for (final doc in historicoSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('✅ Todos os dados removidos');
    } catch (e) {
      debugPrint('❌ Erro ao remover dados: $e');
      rethrow;
    }
  }

  /// Cria índices necessários no Firestore
  /// NOTA: Os índices são criados automaticamente quando você faz queries compostas
  /// Mas você pode criar manualmente via Firebase Console se necessário
  Future<void> createIndexes() async {
    debugPrint('ℹ️ Para criar índices compostos, acesse:');
    debugPrint('  Firebase Console > Firestore Database > Indexes');
    debugPrint('  Ou use o arquivo firestore.indexes.json');
  }
}
