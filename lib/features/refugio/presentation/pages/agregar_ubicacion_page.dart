import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../bloc/refugio_bloc.dart';
import '../bloc/refugio_event.dart';
import '../bloc/refugio_state.dart';

class AgregarUbicacionRefugioPage extends StatefulWidget {
  const AgregarUbicacionRefugioPage({Key? key}) : super(key: key);

  @override
  State<AgregarUbicacionRefugioPage> createState() =>
      _AgregarUbicacionRefugioPageState();
}

class _AgregarUbicacionRefugioPageState
    extends State<AgregarUbicacionRefugioPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  bool _locationObtained = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permisos de ubicación denegados');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permisos de ubicación denegados permanentemente. Actívalos en configuración.',
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationObtained = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            backgroundColor: const Color(0xFFD1FAE5),
            content: Text(
              'Ubicación obtenida: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
              style: const TextStyle(color: Color(0xFF1F2937)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            backgroundColor: Colors.white,
            content: Text(
              'Error al obtener ubicación: $e',
              style: const TextStyle(color: Color(0xFF1F2937)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _saveLocation(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          backgroundColor: Colors.white,
          content: const Text(
            'Primero obtén tu ubicación actual',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
      return;
    }

    context.read<RefugioBloc>().add(
      UpdateLocationEvent(
        latitude: _latitude!,
        longitude: _longitude!,
        address: _addressController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RefugioBloc>(),
      child: BlocConsumer<RefugioBloc, RefugioState>(
        listener: (context, state) {
          if (state is LocationUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                backgroundColor: const Color(0xFFD1FAE5),
                content: const Text(
                  'Ubicación guardada exitosamente',
                  style: TextStyle(color: Color(0xFF1F2937)),
                ),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is RefugioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                backgroundColor: Colors.white,
                content: Text(
                  state.message,
                  style: const TextStyle(color: Color(0xFF1F2937)),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isBlocLoading = state is RefugioLoading;
          final isTotalLoading = _isLoading || isBlocLoading;

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              title: Text(
                'Agregar Ubicación del Refugio',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: const Color(0xFF5B21B6),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String refugioName = 'Refugio';
                if (authState is AuthAuthenticated) {
                  refugioName = authState.user.name ?? 'Refugio';
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Info card
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFF5B21B6),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Refugio: $refugioName',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Registra la ubicación física de tu refugio para que los adoptantes puedan encontrarte en el mapa.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Location status
                        if (_locationObtained) ...[
                          Card(
                            color: const Color(0xFFD1FAE5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF5B21B6),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Ubicación obtenida',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF5B21B6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Latitud: ${_latitude!.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    'Longitud: ${_longitude!.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Get location button
                        ElevatedButton.icon(
                          onPressed: isTotalLoading
                              ? null
                              : _getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: Text(
                            _locationObtained
                                ? 'Actualizar Ubicación'
                                : 'Obtener Mi Ubicación',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Address field
                        TextFormField(
                          controller: _addressController,
                          enabled: !isTotalLoading,
                          decoration: const InputDecoration(
                            labelText: 'Dirección del Refugio *',
                            hintText: 'Ej: Av. Principal 123, Quito, Ecuador',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide(color: Color(0xFF7C3AED)),
                            ),
                            prefixIcon: Icon(
                              Icons.location_on,
                              color: Color(0xFF5B21B6),
                            ),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'La dirección es requerida';
                            }
                            if (value.trim().length < 10) {
                              return 'Ingresa una dirección completa';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        ElevatedButton(
                          onPressed: isTotalLoading || !_locationObtained
                              ? null
                              : () => _saveLocation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B21B6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isTotalLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Guardar Ubicación',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),

                        // Info text
                        const Text(
                          '* Los adoptantes verán tu refugio en el mapa con tu nombre, teléfono y email registrados en tu perfil.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
