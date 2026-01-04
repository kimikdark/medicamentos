import 'package:flutter/material.dart';
import '../models/medicamento.dart';
import '../utils/constants.dart';
import 'estado_badge.dart';

/// Card de medicamento para a lista principal
class MedicamentoCard extends StatelessWidget {
  final Medicamento medicamento;
  final VoidCallback onTap;
  final VoidCallback onBadgeTap;

  const MedicamentoCard({
    Key? key,
    required this.medicamento,
    required this.onTap,
    required this.onBadgeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: smallPadding,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Row(
            children: [
              // Ícone do tipo de medicamento
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  medicamento.tipoIcon,
                  size: iconSizeLarge,
                  color: brandGreen,
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Informações do medicamento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do medicamento
                    Text(
                      medicamento.nome,
                      style: const TextStyle(
                        fontSize: fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Hora da toma
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicamento.horaTomaString,
                          style: const TextStyle(
                            fontSize: fontSizeMedium,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    // Dose (se disponível)
                    if (medicamento.dose != null &&
                        medicamento.dose!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        medicamento.dose!,
                        style: const TextStyle(
                          fontSize: fontSizeSmall,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: defaultPadding),

              // Badge de estado
              EstadoBadge(
                estado: medicamento.estado,
                onTap: medicamento.estado == EstadoMedicamento.porTomar
                    ? onBadgeTap
                    : null,
                isButton: medicamento.estado == EstadoMedicamento.porTomar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card simplificado para listas administrativas
class MedicamentoCardSimples extends StatelessWidget {
  final Medicamento medicamento;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MedicamentoCardSimples({
    Key? key,
    required this.medicamento,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: smallPadding,
      ),
      child: ListTile(
        leading: Icon(
          medicamento.tipoIcon,
          size: 32,
          color: brandGreen,
        ),
        title: Text(
          medicamento.nome,
          style: const TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Hora: ${medicamento.horaTomaString} | ${medicamento.estadoString}',
          style: const TextStyle(fontSize: fontSizeSmall),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: brandBlue),
                onPressed: onEdit,
                iconSize: 28,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                iconSize: 28,
              ),
          ],
        ),
      ),
    );
  }
}

