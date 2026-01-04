import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

/// Tela de parcerias com carrossel
class ParceriasScreen extends StatefulWidget {
  const ParceriasScreen({Key? key}) : super(key: key);

  @override
  State<ParceriasScreen> createState() => _ParceriasScreenState();
}

class _ParceriasScreenState extends State<ParceriasScreen> {
  int _currentIndex = 0;

  // Dados fictícios de parceiros
  final List<Parceiro> _parceiros = [
    Parceiro(
      nome: 'Farmácia Central',
      descricao: 'Entregas ao domicílio 24h. Descontos para seniores.',
      url: 'https://www.farmaciacentral.pt',
      imagemUrl: 'https://via.placeholder.com/400x200/4CAF50/ffffff?text=Farmácia+Central',
    ),
    Parceiro(
      nome: 'Clínica Vida Saudável',
      descricao: 'Consultas de medicina geral e especialidades.',
      url: 'https://www.clinicavidasaudavel.pt',
      imagemUrl: 'https://via.placeholder.com/400x200/2196F3/ffffff?text=Clínica+Vida',
    ),
    Parceiro(
      nome: 'MedSupply Loja',
      descricao: 'Equipamentos médicos e produtos de saúde.',
      url: 'https://www.medsupply.pt',
      imagemUrl: 'https://via.placeholder.com/400x200/FF9800/ffffff?text=MedSupply',
    ),
    Parceiro(
      nome: 'Laboratório Análises +',
      descricao: 'Análises clínicas com resultados rápidos.',
      url: 'https://www.labanalises.pt',
      imagemUrl: 'https://via.placeholder.com/400x200/9C27B0/ffffff?text=Lab+Análises',
    ),
    Parceiro(
      nome: 'Cuidados ao Domicílio',
      descricao: 'Enfermagem e apoio domiciliário 24/7.',
      url: 'https://www.cuidadosdomicilio.pt',
      imagemUrl: 'https://via.placeholder.com/400x200/F44336/ffffff?text=Cuidados+Casa',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: defaultPadding),

          // Título
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              'Nossos Parceiros',
              style: TextStyle(
                fontSize: fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: smallPadding),

          // Subtítulo
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              'Serviços de saúde recomendados',
              style: TextStyle(
                fontSize: fontSizeMedium,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: defaultPadding),

          // Carrossel
          CarouselSlider.builder(
            itemCount: _parceiros.length,
            options: CarouselOptions(
              height: 350,
              enlargeCenterPage: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              pauseAutoPlayOnTouch: true,
              aspectRatio: 16 / 9,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            itemBuilder: (context, index, realIndex) {
              final parceiro = _parceiros[index];
              return _buildParceiroCard(parceiro);
            },
          ),

          const SizedBox(height: defaultPadding),

          // Indicadores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _parceiros.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? brandGreen
                      : Colors.grey[300],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: largePadding),

          // Lista de todos os parceiros
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              'Todos os Parceiros',
              style: TextStyle(
                fontSize: fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: smallPadding),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            itemCount: _parceiros.length,
            itemBuilder: (context, index) {
              final parceiro = _parceiros[index];
              return _buildParceiroListItem(parceiro);
            },
          ),

          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }

  Widget _buildParceiroCard(Parceiro parceiro) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _abrirLink(parceiro.url),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagem
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 180,
                color: brandGreen.withOpacity(0.2),
                child: const Center(
                  child: Icon(
                    Icons.business,
                    size: 80,
                    color: brandGreen,
                  ),
                ),
              ),
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parceiro.nome,
                    style: const TextStyle(
                      fontSize: fontSizeLarge,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: smallPadding),
                  Text(
                    parceiro.descricao,
                    style: const TextStyle(
                      fontSize: fontSizeMedium,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Ver mais',
                        style: TextStyle(
                          fontSize: fontSizeMedium,
                          color: brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: brandGreen, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParceiroListItem(Parceiro parceiro) {
    return Card(
      margin: const EdgeInsets.only(bottom: smallPadding),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: brandGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business, color: brandGreen),
        ),
        title: Text(
          parceiro.nome,
          style: const TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          parceiro.descricao,
          style: const TextStyle(fontSize: fontSizeSmall),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _abrirLink(parceiro.url),
      ),
    );
  }

  Future<void> _abrirLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          showMessage(context, 'Não foi possível abrir o link', isError: true);
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir link: $e');
      if (mounted) {
        showMessage(context, 'Erro ao abrir link', isError: true);
      }
    }
  }
}

/// Modelo de dados para parceiro
class Parceiro {
  final String nome;
  final String descricao;
  final String url;
  final String imagemUrl;

  Parceiro({
    required this.nome,
    required this.descricao,
    required this.url,
    required this.imagemUrl,
  });
}

