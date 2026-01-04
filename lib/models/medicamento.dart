import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Estados possíveis de uma entrada de medicamento
enum EstadoMedicamento {
  porTomar,
  tomado,
  finalizado,
  naoTomado,
  cancelado,
}

/// Tipos de medicamento
enum TipoMedicamento {
  comprimido,
  capsula,
  gotas,
  injetavel,
  xarope,
  pomada,
  spray,
  outro,
}

/// Frequência de repetição
enum FrequenciaRepeticao {
  nenhuma,
  diaria,
  semanal,
  mensal,
}

class Medicamento {
  String? id; // ID do Firestore
  String nome;
  String? dose;
  TimeOfDay horaToma; // Hora principal da toma
  TipoMedicamento tipo;
  EstadoMedicamento estado;
  String? notas;

  // Repetição
  FrequenciaRepeticao frequenciaRepeticao;
  List<int>? diasSemana; // 1-7 para repetição semanal
  int? diaMes; // 1-31 para repetição mensal

  // Timestamps
  DateTime dataCriacao;
  DateTime? dataUltimaMudancaEstado;
  DateTime? dataTomada; // Quando foi marcado como "tomado"

  Medicamento({
    this.id,
    required this.nome,
    this.dose,
    required this.horaToma,
    this.tipo = TipoMedicamento.comprimido,
    this.estado = EstadoMedicamento.porTomar,
    this.notas,
    this.frequenciaRepeticao = FrequenciaRepeticao.nenhuma,
    this.diasSemana,
    this.diaMes,
    DateTime? dataCriacao,
    this.dataUltimaMudancaEstado,
    this.dataTomada,
  }) : dataCriacao = dataCriacao ?? DateTime.now();

  /// Converte TimeOfDay para String formatada HH:mm
  String get horaTomaString {
    return '${horaToma.hour.toString().padLeft(2, '0')}:${horaToma.minute.toString().padLeft(2, '0')}';
  }

  /// Obtém o nome do tipo de medicamento em português
  String get tipoString {
    switch (tipo) {
      case TipoMedicamento.comprimido:
        return 'Comprimido';
      case TipoMedicamento.capsula:
        return 'Cápsula';
      case TipoMedicamento.gotas:
        return 'Gotas';
      case TipoMedicamento.injetavel:
        return 'Injetável';
      case TipoMedicamento.xarope:
        return 'Xarope';
      case TipoMedicamento.pomada:
        return 'Pomada';
      case TipoMedicamento.spray:
        return 'Spray';
      case TipoMedicamento.outro:
        return 'Outro';
    }
  }

  /// Obtém o ícone do tipo de medicamento
  IconData get tipoIcon {
    switch (tipo) {
      case TipoMedicamento.comprimido:
        return Icons.medication;
      case TipoMedicamento.capsula:
        return Icons.medication_liquid;
      case TipoMedicamento.gotas:
        return Icons.water_drop;
      case TipoMedicamento.injetavel:
        return Icons.vaccines;
      case TipoMedicamento.xarope:
        return Icons.local_drink;
      case TipoMedicamento.pomada:
        return Icons.healing;
      case TipoMedicamento.spray:
        return Icons.air;
      case TipoMedicamento.outro:
        return Icons.medical_services;
    }
  }

  /// Obtém o nome do estado em português
  String get estadoString {
    switch (estado) {
      case EstadoMedicamento.porTomar:
        return 'Por Tomar';
      case EstadoMedicamento.tomado:
        return 'Tomado';
      case EstadoMedicamento.finalizado:
        return 'Finalizado';
      case EstadoMedicamento.naoTomado:
        return 'Não Tomado';
      case EstadoMedicamento.cancelado:
        return 'Cancelado';
    }
  }

  /// Obtém a cor do estado
  Color get estadoColor {
    switch (estado) {
      case EstadoMedicamento.porTomar:
        return Colors.green;
      case EstadoMedicamento.tomado:
        return Colors.blue;
      case EstadoMedicamento.finalizado:
        return Colors.grey;
      case EstadoMedicamento.naoTomado:
        return Colors.red;
      case EstadoMedicamento.cancelado:
        return Colors.black;
    }
  }

  /// Converte para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dose': dose,
      'horaToma': '${horaToma.hour}:${horaToma.minute}',
      'tipo': tipo.index,
      'estado': estado.index,
      'notas': notas,
      'frequenciaRepeticao': frequenciaRepeticao.index,
      'diasSemana': diasSemana,
      'diaMes': diaMes,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataUltimaMudancaEstado': dataUltimaMudancaEstado != null
          ? Timestamp.fromDate(dataUltimaMudancaEstado!)
          : null,
      'dataTomada': dataTomada != null
          ? Timestamp.fromDate(dataTomada!)
          : null,
    };
  }

  /// Cria Medicamento a partir de Map do Firestore
  factory Medicamento.fromMap(Map<String, dynamic> map, String id) {
    final horaParts = (map['horaToma'] as String).split(':');
    final hora = TimeOfDay(
      hour: int.parse(horaParts[0]),
      minute: int.parse(horaParts[1]),
    );

    return Medicamento(
      id: id,
      nome: map['nome'] ?? '',
      dose: map['dose'],
      horaToma: hora,
      tipo: TipoMedicamento.values[map['tipo'] ?? 0],
      estado: EstadoMedicamento.values[map['estado'] ?? 0],
      notas: map['notas'],
      frequenciaRepeticao: FrequenciaRepeticao.values[map['frequenciaRepeticao'] ?? 0],
      diasSemana: map['diasSemana'] != null
          ? List<int>.from(map['diasSemana'])
          : null,
      diaMes: map['diaMes'],
      dataCriacao: (map['dataCriacao'] as Timestamp).toDate(),
      dataUltimaMudancaEstado: map['dataUltimaMudancaEstado'] != null
          ? (map['dataUltimaMudancaEstado'] as Timestamp).toDate()
          : null,
      dataTomada: map['dataTomada'] != null
          ? (map['dataTomada'] as Timestamp).toDate()
          : null,
    );
  }

  /// Cria uma cópia do medicamento com campos modificados
  Medicamento copyWith({
    String? id,
    String? nome,
    String? dose,
    TimeOfDay? horaToma,
    TipoMedicamento? tipo,
    EstadoMedicamento? estado,
    String? notas,
    FrequenciaRepeticao? frequenciaRepeticao,
    List<int>? diasSemana,
    int? diaMes,
    DateTime? dataCriacao,
    DateTime? dataUltimaMudancaEstado,
    DateTime? dataTomada,
  }) {
    return Medicamento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      dose: dose ?? this.dose,
      horaToma: horaToma ?? this.horaToma,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      frequenciaRepeticao: frequenciaRepeticao ?? this.frequenciaRepeticao,
      diasSemana: diasSemana ?? this.diasSemana,
      diaMes: diaMes ?? this.diaMes,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataUltimaMudancaEstado: dataUltimaMudancaEstado ?? this.dataUltimaMudancaEstado,
      dataTomada: dataTomada ?? this.dataTomada,
    );
  }
}
