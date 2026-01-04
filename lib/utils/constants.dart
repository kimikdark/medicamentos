import 'package:flutter/material.dart';

// ===== CORES DA APLICAÇÃO =====
const Color brandGreen = Color(0xFF82CF40);
const Color brandBlue = Color(0xFF2D9CDB);
const Color brandWhite = Colors.white;
const Color navbarContrastColor = Color(0xFF388E3C);

// Cores dos Estados de Medicamento
const Color estadoTomadoColor = Colors.blue;
const Color estadoPorTomarColor = Colors.green;
const Color estadoFinalizadoColor = Colors.grey;
const Color estadoNaoTomadoColor = Colors.red;
const Color estadoCanceladoColor = Colors.black;

// ===== TAMANHOS E ESPAÇAMENTOS =====
const double defaultPadding = 16.0;
const double largePadding = 24.0;
const double smallPadding = 8.0;

// Tamanhos de Fonte (Base para acessibilidade)
const double fontSizeSmall = 14.0;
const double fontSizeMedium = 18.0;
const double fontSizeLarge = 24.0;
const double fontSizeXLarge = 32.0;

// Tamanhos de Botões (para idosos - mínimo recomendado)
const double buttonMinHeight = 56.0;
const double buttonMinWidth = 120.0;
const double iconSizeLarge = 48.0;

// ===== DURAÇÕES E TIMEOUTS =====
// Tempo até transição "tomado" -> "finalizado" (em minutos)
const int defaultMinutosParaFinalizado = 10;

// Tempo até transição "por tomar" -> "não tomado" (em minutos)
const int defaultMinutosParaNaoTomado = 60;

// ===== STRINGS DA APLICAÇÃO =====
const String appName = 'app to drugs';
const String appTitle = 'App to Drugs';

// Textos de Estados
const String estadoTomadoText = 'Tomado';
const String estadoPorTomarText = 'Por Tomar';
const String estadoFinalizadoText = 'Finalizado';
const String estadoNaoTomadoText = 'Não Tomado';
const String estadoCanceladoText = 'Cancelado';

// ===== KEYS PARA SHARED PREFERENCES =====
const String keyPin = 'app_pin';
const String keyMinutosParaFinalizado = 'minutos_para_finalizado';
const String keyMinutosParaNaoTomado = 'minutos_para_nao_tomado';
const String keyNumerosCuidadores = 'numeros_cuidadores';
const String keyTamanhoFonte = 'tamanho_fonte';
const String keyAltoContraste = 'alto_contraste';
const String keyScreenReader = 'screen_reader';

// ===== VALORES DEFAULT =====
const String defaultPin = '1234';
const double defaultFatorFonte = 1.0;
const double minFatorFonte = 0.8;
const double maxFatorFonte = 2.0;

// ===== COLLECTIONS FIRESTORE =====
const String collectionMedicamentos = 'medicamentos';
const String collectionConfiguracoes = 'configuracoes';
const String collectionHistorico = 'historico';
const String collectionUsers = 'users';

// ===== ÍCONES DE TIPOS DE MEDICAMENTO =====
const Map<String, IconData> tipoMedicamentoIcons = {
  'comprimido': Icons.medication,
  'capsula': Icons.medication_liquid,
  'gotas': Icons.water_drop,
  'injetavel': Icons.vaccines,
  'xarope': Icons.local_drink,
  'pomada': Icons.healing,
  'spray': Icons.air,
  'outro': Icons.medical_services,
};

