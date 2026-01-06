import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/animal_entity.dart';
import '../bloc/refugio_bloc.dart';
import '../bloc/refugio_event.dart';
import '../bloc/refugio_state.dart';

class AddAnimalPage extends StatefulWidget {
  final AnimalEntity? animal;

  const AddAnimalPage({super.key, this.animal});

  @override
  State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _species = 'Perro';
  String _age = 'Cachorro';
  String _gender = 'Macho';
  String _size = 'Mediano';

  final List<String> _selectedPersonality = [];
  final List<String> _selectedHealthStatus = [];
  final List<XFile> _newImages = [];
  final List<String> _existingImageUrls = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.animal != null) {
      _initializeData();
    }
  }

  void _initializeData() {
    final animal = widget.animal!;
    _nameController.text = animal.name;
    _breedController.text = animal.breed ?? '';
    _descriptionController.text = animal.description ?? '';
    _notesController.text = animal.notes ?? '';
    _species = animal.species;
    _age = animal.age ?? 'Cachorro';
    _gender = animal.gender ?? 'Macho';
    _size = animal.size ?? 'Mediano';
    if (animal.personality != null) {
      _selectedPersonality.addAll(animal.personality!);
    }
    if (animal.healthStatus != null) {
      _selectedHealthStatus.addAll(animal.healthStatus!);
    }
    if (animal.imageUrls != null) {
      _existingImageUrls.addAll(animal.imageUrls!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_newImages.length + _existingImageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 fotos permitidas')),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newImages.add(image);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_newImages.isEmpty && _existingImageUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes agregar al menos una foto')),
        );
        return;
      }

      if (widget.animal == null) {
        context.read<RefugioBloc>().add(
          CreateAnimalEvent(
            name: _nameController.text,
            species: _species,
            breed: _breedController.text,
            age: _age,
            gender: _gender,
            size: _size,
            description: _descriptionController.text,
            notes: _notesController.text,
            personality: _selectedPersonality,
            healthStatus: _selectedHealthStatus,
            images: _newImages,
          ),
        );
      } else {
        context.read<RefugioBloc>().add(
          UpdateAnimalEvent(
            id: widget.animal!.id,
            name: _nameController.text,
            species: _species,
            breed: _breedController.text,
            age: _age,
            gender: _gender,
            size: _size,
            description: _descriptionController.text,
            notes: _notesController.text,
            personality: _selectedPersonality,
            healthStatus: _selectedHealthStatus,
            newImages: _newImages,
            existingImageUrls: _existingImageUrls,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<RefugioBloc>(),
      child: BlocConsumer<RefugioBloc, RefugioState>(
        listener: (context, state) {
          if (state is AnimalCreated || state is AnimalUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.animal == null
                      ? 'Mascota creada exitosamente'
                      : 'Mascota actualizada exitosamente',
                ),
                backgroundColor: const Color(0xFF14B8A6),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is RefugioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF374151),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              toolbarHeight: 76,
              titleSpacing: 20,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.animal == null ? 'Nueva Mascota' : 'Editar Mascota',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Completa todos los campos requeridos',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
              actions: [
                if (state is RefugioLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: () => _submitForm(context),
                  ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageSection(),
                  const SizedBox(height: 16),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildDescriptionSection(),
                  const SizedBox(height: 16),
                  _buildHealthSection(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is RefugioLoading
                          ? null
                          : () => _submitForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.animal == null
                            ? '✓ Publicar Mascota'
                            : '✓ Guardar Cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Fotos de la Mascota',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Mínimo 1 foto, máximo 5. La primera será principal.',
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._existingImageUrls.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return _buildImagePreview(
                      url: url,
                      onRemove: () => _removeExistingImage(index),
                      isPrincipal: index == 0 && _newImages.isEmpty,
                    );
                  }),
                  ..._newImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return _buildImagePreview(
                      file: file,
                      onRemove: () => _removeNewImage(index),
                      isPrincipal: index == 0 && _existingImageUrls.isEmpty,
                    );
                  }),
                  if (_newImages.length + _existingImageUrls.length < 5)
                    _buildAddPhotoButton(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6FFFA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Color(0xFF14B8A6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_newImages.length + _existingImageUrls.length}/5 fotos agregadas. Las fotos de buena calidad aumentan las adopciones.',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
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

  Widget _buildImagePreview({
    String? url,
    XFile? file,
    required VoidCallback onRemove,
    bool isPrincipal = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isPrincipal
                ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
                : Border.all(color: const Color(0xFFE5E7EB)),
            image: DecorationImage(
              image: url != null
                  ? NetworkImage(url)
                  : (kIsWeb
                            ? NetworkImage(file!.path)
                            : FileImage(File(file!.path)))
                        as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF6B7280),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ),
        if (isPrincipal)
          Positioned(
            bottom: 0,
            left: 0,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF8B5CF6),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: const Text(
                'PRINCIPAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: const Color(0xFF6B7280)),
            const SizedBox(height: 4),
            Text(
              'Agregar',
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Información Básica',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('NOMBRE DE LA MASCOTA', Icons.pets),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Ej: Luna, Rocky, Michi...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            _buildLabel('ESPECIE', Icons.category),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _species,
                  isExpanded: true,
                  items:
                      [
                        'Perro',
                        'Gato',
                        'Conejo',
                        'Hámster',
                        'Ave',
                        'Reptil',
                        'Peces',
                        'Hurón',
                        'Chinchilla',
                        'Cobaya',
                        'Tortuga',
                        'Erizo',
                        'Otro',
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _species = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('RAZA', Icons.search),
            TextFormField(
              controller: _breedController,
              decoration: InputDecoration(
                hintText: 'Ej: Labrador, Mestizo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('EDAD', Icons.calendar_today),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _age,
                            isExpanded: true,
                            items:
                                [
                                  'Cachorro',
                                  'Joven',
                                  'Adulto',
                                  'Senior',
                                  'No especificado',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _age = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('SEXO', Icons.male),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _gender,
                            isExpanded: true,
                            items: ['Macho', 'Hembra', 'No especificado'].map((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _gender = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('TAMAÑO', Icons.height),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _size,
                  isExpanded: true,
                  items: ['Pequeño', 'Mediano', 'Grande'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _size = newValue!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel(
              'CUÉNTANOS SOBRE ESTA MASCOTA',
              Icons.chat_bubble_outline,
            ),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe su personalidad, historia, comportamiento con niños y otras mascotas, nivel de actividad, qué tipo de hogar sería ideal...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sugerencias:',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    'Juguetón',
                    'Tranquilo',
                    'Cariñoso',
                    'Ideal para niños',
                    'Apto departamento',
                    'Sociable',
                    'Tímido',
                    'Protector',
                  ].map((tag) {
                    final isSelected = _selectedPersonality.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedPersonality.add(tag);
                          } else {
                            _selectedPersonality.remove(tag);
                          }
                        });
                      },
                      backgroundColor: const Color(0xFFF5F3FF),
                      selectedColor: const Color(0xFFE9D5FF),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF6B7280),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthSection() {
    return Card(
      elevation: 2,
      color: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: Colors.black87),
                SizedBox(width: 8),
                Text(
                  'Estado de Salud',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHealthCheckbox(
              'Vacunado/a',
              'Tiene todas las vacunas al día',
            ),
            _buildHealthCheckbox(
              'Desparasitado/a',
              'Tratamiento antiparasitario completado',
            ),
            _buildHealthCheckbox(
              'Esterilizado/a',
              'Ha sido castrado/a o esterilizado/a',
            ),
            _buildHealthCheckbox(
              'Microchip',
              'Tiene microchip de identificación',
            ),
            _buildHealthCheckbox(
              'Requiere cuidados especiales',
              'Necesita medicación o atención particular',
            ),
            const SizedBox(height: 16),
            _buildLabel(
              'NOTAS ADICIONALES DE SALUD (OPCIONAL)',
              Icons.note_add,
            ),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Alergias, medicamentos, condiciones crónicas, historial médico relevante...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckbox(String title, String subtitle) {
    final isSelected = _selectedHealthStatus.contains(title);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? const Color(0xFFE6FFFA) : const Color(0xFFFFFFFF),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (value) {
          setState(() {
            if (value == true) {
              _selectedHealthStatus.add(title);
            } else {
              _selectedHealthStatus.remove(title);
            }
          });
        },
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        activeColor: const Color(0xFF14B8A6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
