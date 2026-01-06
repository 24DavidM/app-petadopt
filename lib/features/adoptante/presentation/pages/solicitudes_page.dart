import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/adoption_request_entity.dart';
import '../bloc/adoptante_bloc.dart';
import '../bloc/adoptante_event.dart';
import '../bloc/adoptante_state.dart';

class SolicitudesPage extends StatefulWidget {
  const SolicitudesPage({super.key});

  @override
  State<SolicitudesPage> createState() => _SolicitudesPageState();
}

class _SolicitudesPageState extends State<SolicitudesPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AdoptanteBloc>()..add(LoadMyRequestsEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: BlocConsumer<AdoptanteBloc, AdoptanteState>(
            listener: (context, state) {
              if (state is RequestCancelled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Solicitud cancelada correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                context.read<AdoptanteBloc>().add(LoadMyRequestsEvent());
              }
              if (state is AdoptanteError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MyRequestsLoaded) {
                final totalRequests = state.requests.length;
                return NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            expandedHeight: 170,
                            floating: true,
                            pinned: true,
                            backgroundColor: const Color(0xFFF97316),
                            elevation: 0,
                            flexibleSpace: FlexibleSpaceBar(
                              background: Builder(
                                builder: (context) {
                                  final topPad = MediaQuery.of(
                                    context,
                                  ).padding.top;
                                  return Container(
                                    color: const Color(0xFFF97316),
                                    padding: EdgeInsets.fromLTRB(
                                      20,
                                      topPad + 6,
                                      20,
                                      10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Mis Solicitudes',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '$totalRequests solicitudes de adopción',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: const Size.fromHeight(50),
                              child: Container(
                                color: const Color(0xFFF97316),
                                child: TabBar(
                                  controller: _tabController,
                                  isScrollable: false,
                                  indicatorColor: Colors.white,
                                  indicatorWeight: 3,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: Colors.white.withValues(
                                    alpha: 0.6,
                                  ),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  unselectedLabelStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                  tabs: const [
                                    Tab(text: 'Todas'),
                                    Tab(text: 'Pendientes'),
                                    Tab(text: 'Aprobadas'),
                                    Tab(text: 'Rechazadas'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ];
                      },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRequestsList(context, state.requests, 'all'),
                      _buildRequestsList(context, state.requests, 'pending'),
                      _buildRequestsList(context, state.requests, 'approved'),
                      _buildRequestsList(context, state.requests, 'rejected'),
                    ],
                  ),
                );
              }

              if (state is AdoptanteLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFF97316)),
                );
              }

              return _buildEmptyState();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<dynamic> allRequests,
    String filter,
  ) {
    final filteredRequests = _filterRequests(allRequests, filter);

    if (filteredRequests.isEmpty) {
      return _buildEmptyStateForFilter(filter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredRequests.length,
      itemBuilder: (context, index) {
        final req = filteredRequests[index] as AdoptionRequestEntity;
        return _buildRequestCard(context, req);
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    AdoptionRequestEntity request,
  ) {
    final status = request.status;
    final createdAt = request.createdAt;
    final petName = request.animalName ?? 'Mascota';

    Color statusColor;
    String statusText;

    // Lógica para determinar el estado de la solicitud
    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = '✓ Aprobada';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = '✕ Rechazada';
        break;
      default:
        statusColor = const Color(0xFFF97316);
        statusText = '⏱ Pendiente';
    }

    // Color de fondo según estado
    Color backgroundColor;
    switch (status) {
      case 'approved':
        backgroundColor = const Color(0xFFE8F5E9);
        break;
      case 'rejected':
        backgroundColor = const Color(0xFFFFEBEE);
        break;
      default:
        backgroundColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Contenedor principal con imagen y info
            Container(
              color: backgroundColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la mascota
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child:
                          (request.animalImageUrls != null &&
                              request.animalImageUrls!.isNotEmpty)
                          ? Image.network(
                              request.animalImageUrls!.first,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: const Color(0xFFF97316),
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.pets,
                                      size: 36,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.pets,
                                size: 36,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Información de la solicitud
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Nombre de la mascota
                        Text(
                          petName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Nombre de la organización/refugio
                        Text(
                          request.shelterName ?? 'Refugio',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Estado y fecha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (createdAt != null)
                              Text(
                                DateFormat('dd MMM').format(createdAt),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, size: 48, color: Color(0xFFF97316)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes solicitudes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Explora y encuentra a tu compañero ideal!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForFilter(String filter) {
    String message = '';
    switch (filter) {
      case 'pending':
        message = 'No tienes solicitudes pendientes';
        break;
      case 'approved':
        message = 'No tienes solicitudes aprobadas';
        break;
      case 'rejected':
        message = 'No tienes solicitudes rechazadas';
        break;
      default:
        message = 'No tienes solicitudes';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<dynamic> _filterRequests(List<dynamic> requests, String filter) {
    if (filter == 'all') return requests;
    return requests.where((r) => r.status == filter).toList();
  }
}
