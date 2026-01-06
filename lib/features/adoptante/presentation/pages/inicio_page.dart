import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/adoptante_bloc.dart';
import '../bloc/adoptante_event.dart';
import '../bloc/adoptante_state.dart';
import 'animal_detail_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({Key? key}) : super(key: key);

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  final Map<String, String> _categoryMap = {
    'Perros': 'Perro',
    'Gatos': 'Gato',
    'Conejos': 'Conejo',
    'Hámster': 'Hámster',
    'Aves': 'Ave',
    'Reptiles': 'Reptil',
    'Peces': 'Peces',
    'Hurones': 'Hurón',
    'Chinchillas': 'Chinchilla',
    'Cobayas': 'Cobaya',
    'Tortugas': 'Tortuga',
    'Erizos': 'Erizo',
    'Otro': 'Otro',
  };

  @override
  void initState() {
    super.initState();
    // Cargar animales cuando la página se inicia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AdoptanteBloc>().add(LoadAnimalsEvent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AdoptanteBloc>()..add(LoadAnimalsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String name = 'Usuario';
                        if (state is AuthAuthenticated) {
                          name = state.user.name ?? 'Usuario';
                        }
                        return Text(
                          'Hola, $name 👋',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Encuentra tu nuevo amigo',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildCategoryItem('Todos', Icons.pets),
                    // Build buttons for all categories from the map
                    ..._categoryMap.keys
                        .map((label) => _buildCategoryItem(label, Icons.pets))
                        .toList(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Grid of Animals
              Expanded(
                child: BlocBuilder<AdoptanteBloc, AdoptanteState>(
                  builder: (context, state) {
                    if (state is AdoptanteLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF97316),
                        ),
                      );
                    }

                    if (state is AdoptanteError) {
                      return Center(child: Text(state.message));
                    }

                    if (state is AnimalsLoaded) {
                      var animals = state.animals;

                      // Filter logic: use the category map for all species
                      if (_selectedCategory != 'Todos') {
                        final speciesToMatch = _categoryMap[_selectedCategory];
                        if (speciesToMatch != null) {
                          animals = animals
                              .where((a) => a.species == speciesToMatch)
                              .toList();
                        }
                      }

                      if (_searchController.text.isNotEmpty) {
                        animals = animals
                            .where(
                              (a) => a.name.toLowerCase().contains(
                                _searchController.text.toLowerCase(),
                              ),
                            )
                            .toList();
                      }

                      if (animals.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pets,
                                size: 64,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Por el momento',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No se encontraron mascotas',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: animals.length,
                        itemBuilder: (context, index) {
                          final animal = animals[index];
                          return GestureDetector(
                            onTap: () {
                              final bloc = context.read<AdoptanteBloc>();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider.value(
                                    value: bloc,
                                    child: AnimalDetailPage(animal: animal),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                ),
                                            image:
                                                (animal.imageUrls != null &&
                                                    animal
                                                        .imageUrls!
                                                        .isNotEmpty)
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                      animal.imageUrls!.first,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            color: Colors.grey.shade200,
                                          ),
                                          child:
                                              (animal.imageUrls == null ||
                                                  animal.imageUrls!.isEmpty)
                                              ? const Center(
                                                  child: Icon(
                                                    Icons.pets,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                              : null,
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite_border,
                                              size: 16,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Info
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          animal.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          animal.breed ?? 'Raza desconocida',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              animal.gender ?? '?',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Color(0xFFF97316),
                                              ),
                                            ),
                                            Text(
                                              animal.age != null
                                                  ? '${animal.age} años'
                                                  : '?',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
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
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
        // Trigger reload if needed or just filter locally as done in builder
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF97316) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isSelected)
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
