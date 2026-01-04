import 'package:flutter/material.dart';
import '../../models/medicamento.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Tela de histórico com filtros
class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({Key? key}) : super(key: key);

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, dynamic>> _historico = [];
  List<Map<String, dynamic>> _historicoFiltrado = [];
  bool _loading = true;
  bool _ordenarCrescente = false;
  EstadoMedicamento? _estadoFiltro;
  String _textoBusca = '';

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    if (!mounted) return;
    setState(() => _loading = true);

    final historico = await _firebaseService.getHistorico(
      ordenarCrescente: _ordenarCrescente,
    );

    if (!mounted) return;
    setState(() {
      _historico = historico;
      _aplicarFiltros();
      _loading = false;
    });
  }

  void _aplicarFiltros() {
    var filtrado = List<Map<String, dynamic>>.from(_historico);

    // Filtro por texto
    if (_textoBusca.isNotEmpty) {
      filtrado = filtrado.where((item) {
        final nome = (item['nome'] as String? ?? '').toLowerCase();
        return nome.contains(_textoBusca.toLowerCase());
      }).toList();
    }

    // Filtro por estado
    if (_estadoFiltro != null) {
      filtrado = filtrado.where((item) {
        return item['estado'] == _estadoFiltro!.index;
      }).toList();
    }

    setState(() {
      _historicoFiltrado = filtrado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de filtros
        Container(
          padding: const EdgeInsets.all(defaultPadding),
          color: Colors.grey[100],
          child: Column(
            children: [
              // Campo de busca
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar por nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                style: const TextStyle(fontSize: fontSizeMedium),
                onChanged: (value) {
                  setState(() {
                    _textoBusca = value;
                  });
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: smallPadding),

              // Botões de filtro
              Row(
                children: [
                  // Filtro por estado
                  Expanded(
                    child: PopupMenuButton<EstadoMedicamento?>(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _estadoFiltro == null
                                  ? 'Todos os estados'
                                  : _getEstadoNome(_estadoFiltro!),
                              style: const TextStyle(fontSize: fontSizeSmall),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('Todos os estados'),
                        ),
                        ...EstadoMedicamento.values.map((estado) {
                          return PopupMenuItem(
                            value: estado,
                            child: Text(_getEstadoNome(estado)),
                          );
                        }),
                      ],
                      onSelected: (estado) {
                        setState(() {
                          _estadoFiltro = estado;
                        });
                        _aplicarFiltros();
                      },
                    ),
                  ),

                  const SizedBox(width: smallPadding),

                  // Botão ordenar
                  IconButton(
                    icon: Icon(
                      _ordenarCrescente
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                    ),
                    onPressed: () {
                      setState(() {
                        _ordenarCrescente = !_ordenarCrescente;
                      });
                      _carregarHistorico();
                    },
                    tooltip: _ordenarCrescente
                        ? 'Mais antigos primeiro'
                        : 'Mais recentes primeiro',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Lista de histórico
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _historicoFiltrado.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum registro encontrado',
                            style: TextStyle(
                              fontSize: fontSizeMedium,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(defaultPadding),
                      itemCount: _historicoFiltrado.length,
                      itemBuilder: (context, index) {
                        final item = _historicoFiltrado[index];
                        return _buildHistoricoCard(item);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildHistoricoCard(Map<String, dynamic> item) {
    final nome = item['nome'] as String? ?? '';
    final estadoIndex = item['estado'] as int? ?? 0;
    final estado = EstadoMedicamento.values[estadoIndex];
    final estadoNome = item['estadoString'] as String? ?? '';
    final horaToma = item['horaToma'] as String? ?? '';
    final timestamp = item['timestamp'];

    String dataFormatada = '';
    if (timestamp != null) {
      final data = timestamp.toDate();
      dataFormatada = formatDateTime(data);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: smallPadding),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getEstadoColor(estado).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medication,
            color: _getEstadoColor(estado),
          ),
        ),
        title: Text(
          nome,
          style: const TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Estado: $estadoNome',
              style: TextStyle(
                fontSize: fontSizeSmall,
                color: _getEstadoColor(estado),
              ),
            ),
            if (horaToma.isNotEmpty)
              Text(
                'Hora: $horaToma',
                style: const TextStyle(fontSize: fontSizeSmall),
              ),
            if (dataFormatada.isNotEmpty)
              Text(
                dataFormatada,
                style: TextStyle(
                  fontSize: fontSizeSmall,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getEstadoNome(EstadoMedicamento estado) {
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

  Color _getEstadoColor(EstadoMedicamento estado) {
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
}

