import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/request_entity.dart';
import '../../domain/entities/animal_entity.dart';
import '../bloc/refugio_bloc.dart';
import '../bloc/refugio_event.dart';
import '../bloc/refugio_state.dart';

class RefugioHomePage extends StatefulWidget {
  const RefugioHomePage({Key? key}) : super(key: key);

  @override
  State<RefugioHomePage> createState() => _RefugioHomePageState();
}

class _RefugioHomePageState extends State<RefugioHomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RefugioBloc>()..add(LoadRefugioDashboardEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB), // Background: #F9FAFB
        body: SafeArea(
          child: BlocConsumer<RefugioBloc, RefugioState>(
            listener: (context, state) {
              if (state is RefugioError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              int totalMascotas = 0;
              int pendientes = 0;
              int adoptadas = 0;
              List<RequestEntity> recentRequests = [];
              List<AnimalEntity> recentAnimals = [];
              bool isLoading = true;

              if (state is RefugioDashboardLoaded) {
                totalMascotas = state.totalAnimals;
                pendientes = state.pendingRequests;
                adoptadas = state.adoptedAnimals;
                recentRequests = state.recentRequests;
                recentAnimals = state.recentAnimals;
                isLoading = false;
              } else if (state is RefugioError) {
                isLoading = false;
              }

              // Mostrar máximo 3 solicitudes en UI (limitado sólo en renderizado)
              List<RequestEntity> displayedRequests = [];
              if (recentRequests.isNotEmpty) {
                displayedRequests = recentRequests.length > 3
                    ? recentRequests.sublist(0, 3)
                    : recentRequests;
              }

              return Column(
                children: [
                  // Header (purple) + estadísticas
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF5B21B6), 
                    padding: const EdgeInsets.only(
                      bottom: 20,
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFEDE9FE,
                                ), // Primario suave
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Color(0xFF5B21B6), // Primario oscuro
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, state) {
                                      String displayName = 'Refugio';
                                      if (state is AuthAuthenticated) {
                                        displayName =
                                            state.user.name ?? 'Refugio';
                                      }
                                      return Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  const Text(
                                    'Panel de administración',
                                    style: TextStyle(
                                      color: Color(0xFFEDE9FE),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Estadísticas
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            children: [
                              _buildStatCard(
                                '$totalMascotas',
                                'Mascotas',
                                Icons.pets_rounded,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                '$pendientes',
                                'Pendiente',
                                Icons.schedule_rounded,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                '$adoptadas',
                                'Adoptadas',
                                Icons.check_circle_rounded,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Contenido con fondo blanco
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Botón para agregar ubicación
                                  Card(
                                    color: const Color(
                                      0xFFEDE9FE,
                                    ), // Primario suave
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/agregar_ubicacion',
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF5B21B6,
                                                ), // Primario oscuro
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Ubicación en el Mapa',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    'Agrega o actualiza tu ubicación',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              size: 18,
                                              color: Color(0xFF5B21B6),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Título de solicitudes recientes
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'Solicitudes Recientes',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Lista de solicitudes (mostrar máximo 3)
                                  if (displayedRequests.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.inbox_rounded,
                                              size: 60,
                                              color: Color(0xFFE5E7EB),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No hay solicitudes',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ...displayedRequests.map((request) {
                                      return _buildRequestCard(
                                        context,
                                        request,
                                      );
                                    }).toList(),

                                  const SizedBox(height: 32),

                                  // Título de animales recientemente agregados
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        'Animales Recientemente Agregados',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Lista de animales recientes (mostrar máximo 3)
                                  if (recentAnimals.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.pets_rounded,
                                              size: 60,
                                              color: Color(0xFFE5E7EB),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No hay animales agregados',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    ...recentAnimals.map((animal) {
                                      return _buildAnimalCard(context, animal);
                                    }).toList(),
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFEDE9FE), // Primario suave
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF5B21B6),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF5B21B6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestEntity request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Cards: #FFFFFF
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Foto del animal
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    request.animalImageUrls != null &&
                        request.animalImageUrls!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          request.animalImageUrls!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.pets, color: Color(0xFF6B7280)),
                        ),
                      )
                    : const Icon(Icons.pets, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Solicitud para ${request.animalName ?? 'mascota'}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'De: ${request.adopterName ?? 'Sin nombre'}',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalCard(BuildContext context, AnimalEntity animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Cards: #FFFFFF
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Foto del animal
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: animal.imageUrls != null && animal.imageUrls!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          animal.imageUrls!.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.pets, color: Color(0xFF6B7280)),
                        ),
                      )
                    : const Icon(Icons.pets, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${animal.species ?? 'Especie'} • ${animal.breed ?? 'Raza'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: animal.status == 'available'
                      ? const Color(0xFFEDE9FE)
                      : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  animal.status == 'available'
                      ? 'Disponible'
                      : animal.status ?? 'Activo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: animal.status == 'available'
                        ? const Color(0xFF5B21B6)
                        : const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
