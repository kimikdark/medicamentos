import 'package:flutter/material.dart';
import '../models/medicamento.dart';
import '../utils/constants.dart';

/// Widget de badge colorido que mostra o estado do medicamento
/// Também funciona como botão para mudar estado
class EstadoBadge extends StatelessWidget {
  final EstadoMedicamento estado;
  final VoidCallback? onTap;
  final bool isButton;
  final double fontSize;

  const EstadoBadge({
    Key? key,
    required this.estado,
    this.onTap,
    this.isButton = true,
    this.fontSize = fontSizeMedium,
  }) : super(key: key);

  Color _getEstadoColor() {
    switch (estado) {
      case EstadoMedicamento.porTomar:
        return estadoPorTomarColor;
      case EstadoMedicamento.tomado:
        return estadoTomadoColor;
      case EstadoMedicamento.finalizado:
        return estadoFinalizadoColor;
      case EstadoMedicamento.naoTomado:
        return estadoNaoTomadoColor;
      case EstadoMedicamento.cancelado:
        return estadoCanceladoColor;
    }
  }

  String _getEstadoText() {
    switch (estado) {
      case EstadoMedicamento.porTomar:
        return estadoPorTomarText;
      case EstadoMedicamento.tomado:
        return estadoTomadoText;
      case EstadoMedicamento.finalizado:
        return estadoFinalizadoText;
      case EstadoMedicamento.naoTomado:
        return estadoNaoTomadoText;
      case EstadoMedicamento.cancelado:
        return estadoCanceladoText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getEstadoColor();
    final text = _getEstadoText();

    return GestureDetector(
      onTap: isButton ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: isButton
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
            if (isButton && onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.touch_app,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Variante grande do badge (para uso em detalhes)
class EstadoBadgeLarge extends StatelessWidget {
  final EstadoMedicamento estado;
  final VoidCallback? onTap;

  const EstadoBadgeLarge({
    Key? key,
    required this.estado,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EstadoBadge(
      estado: estado,
      onTap: onTap,
      fontSize: fontSizeLarge,
      isButton: onTap != null,
    );
  }
}

