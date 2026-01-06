import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/animal_entity.dart';
import '../bloc/adoptante_bloc.dart';
import '../bloc/adoptante_event.dart';
import '../bloc/adoptante_state.dart';
import '../bloc/animal_detail_bloc.dart';
import '../bloc/animal_detail_event.dart';
import '../bloc/animal_detail_state.dart';

class AnimalDetailPage extends StatefulWidget {
  final AnimalEntity animal;

  const AnimalDetailPage({Key? key, required this.animal}) : super(key: key);

  @override
  State<AnimalDetailPage> createState() => _AnimalDetailPageState();
}

class _AnimalDetailPageState extends State<AnimalDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  String? _shelterDistance;

  AnimalEntity get animal => widget.animal;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _computeDistanceIfPossible(
    double shelterLat,
    double shelterLon,
  ) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() => _shelterDistance = 'Distancia no disponible');
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final km = _haversineDistance(
        position.latitude,
        position.longitude,
        shelterLat,
        shelterLon,
      );
      String formatted;
      if (km < 1) {
        formatted = '<1 km';
      } else if (km < 10) {
        formatted = '${km.toStringAsFixed(1)} km';
      } else {
        formatted = '${km.toStringAsFixed(0)} km';
      }

      if (mounted) setState(() => _shelterDistance = formatted);
    } catch (e) {
      if (mounted) setState(() => _shelterDistance = 'Distancia no disponible');
    }
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371.0; // Earth radius in km
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AnimalDetailBloc>()
        ..add(LoadShelterDetailsEvent(animal.shelterId))
        ..add(CheckFavoriteStatusEvent(animal.id)),
      child: BlocConsumer<AnimalDetailBloc, AnimalDetailState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.shelter != null) {
            _computeDistanceIfPossible(
              state.shelter!.location.latitude,
              state.shelter!.location.longitude,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFB),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Carousel
                      _buildImageCarousel(context, state),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            _buildHeader(),
                            const SizedBox(height: 28),

                            // Info Cards
                            _buildInfoCards(),
                            const SizedBox(height: 28),

                            // Shelter Info
                            _buildShelterInfo(state, context),
                            const SizedBox(height: 28),

                            // Description
                            _buildSectionTitle('Sobre ${animal.name}'),
                            const SizedBox(height: 12),
                            Text(
                              animal.description ??
                                  '${animal.name} es una mascota adorable que busca un hogar lleno de amor.',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Personality
                            if (animal.personality != null &&
                                animal.personality!.isNotEmpty)
                              _buildPersonality(),

                            // Health Status
                            if (animal.healthStatus != null &&
                                animal.healthStatus!.isNotEmpty)
                              _buildHealthStatus(),

                            // Notes
                            if (animal.notes != null &&
                                animal.notes!.isNotEmpty)
                              _buildNotes(),

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Back Button
                Positioned(top: 50, left: 20, child: _buildBackButton(context)),

                // Favorite Button
                Positioned(
                  top: 50,
                  right: 20,
                  child: _buildFavoriteButton(context, state),
                ),

                // Bottom Button
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: _buildAdoptButton(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageCarousel(BuildContext context, AnimalDetailState state) {
    return Stack(
      children: [
        SizedBox(
          height: 420,
          width: double.infinity,
          child: (animal.imageUrls != null && animal.imageUrls!.isNotEmpty)
              ? PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemCount: animal.imageUrls!.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      animal.imageUrls![index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                    );
                  },
                )
              : _buildImagePlaceholder(),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.06)],
              ),
            ),
          ),
        ),
        if (animal.imageUrls != null && animal.imageUrls!.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                animal.imageUrls!.length,
                (index) => Container(
                  width: index == _currentImageIndex ? 28 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? const Color(0xFFF97316)
                        : Colors.white.withOpacity(0.6),
                    boxShadow: [
                      if (index == _currentImageIndex)
                        BoxShadow(
                          color: const Color(0xFFF97316).withOpacity(0.18),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFFF97316).withOpacity(0.06),
      child: const Center(
        child: Icon(Icons.pets, size: 100, color: Color(0xFFF97316)),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFFF97316), size: 24),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, AnimalDetailState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            state.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: state.isFavorite
                ? const Color(0xFFF97316)
                : Colors.grey[400],
            size: 24,
          ),
        ),
        onPressed: () {
          context.read<AnimalDetailBloc>().add(ToggleFavoriteEvent(animal.id));
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                animal.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                animal.breed ?? 'Raza desconocida',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEFFAF0),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Text(
            'Disponible',
            style: TextStyle(
              color: Color(0xFF16A34A),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoCard(
          animal.age != null ? '${animal.age}' : '?',
          'Edad',
          Icons.cake,
        ),
        _buildInfoCard(
          animal.gender ?? '?',
          'Sexo',
          animal.gender == 'Macho' ? Icons.male : Icons.female,
        ),
        _buildInfoCard(animal.size ?? '?', 'Tamaño', Icons.straighten),
      ],
    );
  }

  Widget _buildShelterInfo(AnimalDetailState state, BuildContext context) {
    final shelterName = state.shelter?.shelterName ?? 'Cargando...';
    final shelterAddress = state.shelter?.address ?? '...';
    final shelterPhone = state.shelter?.phone;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.store_mall_directory_rounded,
              color: Color(0xFFF97316),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelterName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shelterAddress,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (_shelterDistance != null)
                      Text(
                        _shelterDistance!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Color(0xFF0F172A), size: 22),
              onPressed: () {
                if (shelterPhone != null && shelterPhone.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Llamar a: $shelterPhone'),
                      backgroundColor: const Color(0xFFFFA726),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teléfono no disponible'),
                      backgroundColor: Colors.grey,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildPersonality() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personalidad'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: animal.personality!
              .map(
                (trait) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '📌 $trait',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHealthStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Estado de Salud'),
        const SizedBox(height: 14),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: animal.healthStatus!.length,
          itemBuilder: (context, index) {
            final colors = [
              const Color(0xFF10B981).withOpacity(0.95),
              const Color(0xFF06B6D4).withOpacity(0.95),
              const Color(0xFF8B5CF6).withOpacity(0.95),
              const Color(0xFFEC4899).withOpacity(0.95),
            ];
            final color = colors[index % colors.length];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.28), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.95),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    animal.healthStatus![index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Notas Importantes'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF97316),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outlined,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  animal.notes ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildAdoptButton(BuildContext context) {
    return BlocListener<AdoptanteBloc, AdoptanteState>(
      listener: (context, state) {
        if (state is AdoptionRequestCreated) {
          // Mostrar SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Solicitud enviada correctamente'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
          // Volver a la pantalla anterior y recargar animales
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              // Recargar animales antes de volver
              context.read<AdoptanteBloc>().add(LoadAnimalsEvent());
              Navigator.pop(context);
            }
          });
        }
      },
      child: ElevatedButton(
        onPressed: () {
          context.read<AdoptanteBloc>().add(
            CreateAdoptionRequestEvent(animalId: animal.id, notes: ''),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF97316),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 20),
            SizedBox(width: 10),
            Text(
              'Solicitar Adopción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.grey[600], size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
