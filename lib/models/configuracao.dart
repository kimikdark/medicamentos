
/// Modelo para configurações da aplicação
class Configuracao {
  String? id;
  String pin;
  int minutosParaFinalizado;
  int minutosParaNaoTomado;
  List<String> numerosCuidadores;

  // Acessibilidade
  double fatorTamanhoFonte;
  bool altoContraste;
  bool screenReaderAtivo;

  Configuracao({
    this.id,
    required this.pin,
    this.minutosParaFinalizado = 10,
    this.minutosParaNaoTomado = 60,
    this.numerosCuidadores = const [],
    this.fatorTamanhoFonte = 1.0,
    this.altoContraste = false,
    this.screenReaderAtivo = false,
  });

  /// Converte para Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'pin': pin,
      'minutosParaFinalizado': minutosParaFinalizado,
      'minutosParaNaoTomado': minutosParaNaoTomado,
      'numerosCuidadores': numerosCuidadores,
      'fatorTamanhoFonte': fatorTamanhoFonte,
      'altoContraste': altoContraste,
      'screenReaderAtivo': screenReaderAtivo,
    };
  }

  /// Cria Configuracao a partir de Map do Firestore
  factory Configuracao.fromMap(Map<String, dynamic> map, String id) {
    return Configuracao(
      id: id,
      pin: map['pin'] ?? '1234',
      minutosParaFinalizado: map['minutosParaFinalizado'] ?? 10,
      minutosParaNaoTomado: map['minutosParaNaoTomado'] ?? 60,
      numerosCuidadores: map['numerosCuidadores'] != null
          ? List<String>.from(map['numerosCuidadores'])
          : [],
      fatorTamanhoFonte: (map['fatorTamanhoFonte'] ?? 1.0).toDouble(),
      altoContraste: map['altoContraste'] ?? false,
      screenReaderAtivo: map['screenReaderAtivo'] ?? false,
    );
  }

  /// Cria uma cópia com campos modificados
  Configuracao copyWith({
    String? id,
    String? pin,
    int? minutosParaFinalizado,
    int? minutosParaNaoTomado,
    List<String>? numerosCuidadores,
    double? fatorTamanhoFonte,
    bool? altoContraste,
    bool? screenReaderAtivo,
  }) {
    return Configuracao(
      id: id ?? this.id,
      pin: pin ?? this.pin,
      minutosParaFinalizado: minutosParaFinalizado ?? this.minutosParaFinalizado,
      minutosParaNaoTomado: minutosParaNaoTomado ?? this.minutosParaNaoTomado,
      numerosCuidadores: numerosCuidadores ?? this.numerosCuidadores,
      fatorTamanhoFonte: fatorTamanhoFonte ?? this.fatorTamanhoFonte,
      altoContraste: altoContraste ?? this.altoContraste,
      screenReaderAtivo: screenReaderAtivo ?? this.screenReaderAtivo,
    );
  }

  /// Configuração padrão
  factory Configuracao.defaultConfig() {
    return Configuracao(
      pin: '1234',
      minutosParaFinalizado: 10,
      minutosParaNaoTomado: 60,
      numerosCuidadores: [],
      fatorTamanhoFonte: 1.0,
      altoContraste: false,
      screenReaderAtivo: false,
    );
  }
}

