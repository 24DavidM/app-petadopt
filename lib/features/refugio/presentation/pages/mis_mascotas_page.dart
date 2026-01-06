import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/animal_entity.dart';
import '../bloc/refugio_bloc.dart';
import '../bloc/refugio_event.dart';
import '../bloc/refugio_state.dart';
import 'add_animal_page.dart';

class MisMascotasPage extends StatefulWidget {
  const MisMascotasPage({super.key});

  @override
  State<MisMascotasPage> createState() => _MisMascotasPageState();
}

class _MisMascotasPageState extends State<MisMascotasPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late RefugioBloc _refugioBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Inicializar el Bloc una sola vez
    _refugioBloc = di.sl<RefugioBloc>()..add(LoadMyAnimalsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refugioBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _refugioBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFF5B21B6),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddAnimalPage()),
            );
            if (result == true && context.mounted) {
              _refugioBloc.add(LoadMyAnimalsEvent());
            }
          },
          backgroundColor: const Color(0xFF14B8A6),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Mis Animales',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<RefugioBloc, RefugioState>(
                      builder: (context, state) {
                        final animals = state is MyAnimalsLoaded
                            ? state.animals
                            : [];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${animals.length} animales registrados',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: const Color(0xFF7C3AED),
                  unselectedLabelColor: Colors.white,
                  isScrollable: true,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Todas'),
                    Tab(text: 'Disponibles'),
                    Tab(text: 'En Proceso'),
                    Tab(text: 'Adoptadas'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contenido
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: BlocConsumer<RefugioBloc, RefugioState>(
                    listener: (context, state) {
                      if (state is AnimalDeleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Mascota eliminada correctamente'),
                            backgroundColor: Color(0xFF10B981),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        _refugioBloc.add(LoadMyAnimalsEvent());
                      } else if (state is RefugioError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is RefugioLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is MyAnimalsLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildAnimalsList(context, state.animals, 'all'),
                            _buildAnimalsList(
                              context,
                              state.animals,
                              'available',
                            ),
                            _buildAnimalsList(
                              context,
                              state.animals,
                              'pending',
                            ),
                            _buildAnimalsList(
                              context,
                              state.animals,
                              'adopted',
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: BlocBuilder<RefugioBloc, RefugioState>(
        builder: (context, state) {
          int animalCount = 0;
          if (state is MyAnimalsLoaded) {
            animalCount = state.animals.length;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Mis Mascotas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '$animalCount mascotas registradas',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimalsGrid(BuildContext context, List<AnimalEntity> animals) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: animals.length,
      itemBuilder: (context, index) {
        return _buildAnimalCard(context, animals[index]);
      },
    );
  }

  Widget _buildAnimalCard(BuildContext context, AnimalEntity animal) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddAnimalPage(animal: animal),
          ),
        );
        if (result == true && context.mounted) {
          _refugioBloc.add(LoadMyAnimalsEvent());
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      color: _getBackgroundColor(animal.species),
                      image:
                          animal.imageUrls != null &&
                              animal.imageUrls!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(animal.imageUrls!.first),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: animal.imageUrls == null || animal.imageUrls!.isEmpty
                        ? Center(
                            child: Icon(
                              animal.species == 'Gato'
                                  ? Icons.pets
                                  : Icons.pets_outlined,
                              size: 48,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          animal.status,
                        ).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(animal.status),
                        style: TextStyle(
                          color: _getStatusTextColor(animal.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${animal.breed ?? "Mestizo"} • ${animal.age ?? "Desconocido"}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (animal.healthStatus?.contains('Vacunado/a') ?? false)
                        _buildTag('Vacunado'),
                      if (animal.healthStatus?.contains('Esterilizado/a') ??
                          false)
                        _buildTag('Esterilizado'),
                      if (animal.healthStatus?.contains('Microchip') ?? false)
                        _buildTag('Microchip'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 14,
                        color: Color(0xFFF97316),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${animal.viewsCount ?? 0}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.favorite, size: 14, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        '${animal.likesCount ?? 0}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddAnimalPage(animal: animal),
                              ),
                            );
                            if (result == true && context.mounted) {
                              _refugioBloc.add(LoadMyAnimalsEvent());
                            }
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text(
                            'Editar',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B21B6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: animal.status == 'available'
                              ? () => _showDeleteConfirmation(context, animal)
                              : null,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text(
                            'Eliminar',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: animal.status == 'available'
                                ? const Color(0xFF14B8A6)
                                : Colors.grey[300],
                            foregroundColor: animal.status == 'available'
                                ? Colors.white
                                : Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
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

  void _showDeleteConfirmation(BuildContext context, AnimalEntity animal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Mascota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('¿Estás seguro que deseas eliminar esta mascota?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF14B8A6).withOpacity(0.08),
                  border: Border.all(color: Color(0xFF14B8A6).withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Solo puedes eliminar animales en estado "Disponible"',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF14B8A6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _refugioBloc.add(DeleteAnimalEvent(animal.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Eliminando ${animal.name}...'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF14B8A6),
                  ),
                );
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Color(0xFF14B8A6)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No hay mascotas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera mascota para comenzar',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(String species) {
    switch (species.toLowerCase()) {
      case 'perro':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'gato':
        return const Color(0xFFFCE7F3); // Pink 100
      default:
        return const Color(0xFFE0F2FE); // Sky 100
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFFD1FAE5); // Green 100
      case 'pending':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'adopted':
        return const Color(0xFFDBEAFE); // Blue 100
      default:
        return Colors.grey[200]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'available':
        return const Color(0xFF065F46); // Green 800
      case 'pending':
        return const Color(0xFF92400E); // Amber 800
      case 'adopted':
        return const Color(0xFF1E40AF); // Blue 800
      default:
        return Colors.grey[800]!;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'available':
        return 'Disponible';
      case 'pending':
        return 'En Proceso';
      case 'adopted':
        return 'Adoptado';
      default:
        return status;
    }
  }

  Widget _buildAnimalsList(
    BuildContext context,
    List<AnimalEntity> animals,
    String status,
  ) {
    final filtered = status == 'all'
        ? animals
        : animals.where((a) => a.status == status).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return _buildAnimalsGrid(context, filtered);
  }
}
