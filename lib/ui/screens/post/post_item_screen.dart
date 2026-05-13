import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/supabase_provider.dart';
import '../../../data/services/supabase_service.dart';
import '../../widgets/glass_box.dart';
import 'poster_screen.dart';

enum PostType { lost, found }

class PostItemScreen extends ConsumerStatefulWidget {
  final PostType type;
  const PostItemScreen({super.key, required this.type});

  @override
  ConsumerState<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends ConsumerState<PostItemScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = "Electrónicos";
  final List<Uint8List> _images = [];
  bool _isSubmitting = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    // Supporting multiple formats (PNG, JPG, HEIC, etc.) and multiple files
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes();
        setState(() {
          _images.add(bytes);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, adicione um título.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    String imageUrl = "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?q=80&w=400";
    
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      
      if (_images.isNotEmpty) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadedUrl = await supabaseService.uploadItemImage(_images.first, fileName);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      final typeString = widget.type == PostType.lost ? 'lost' : 'found';
      final newItem = {
        'title': _titleController.text,
        'description': _descController.text,
        'category': _category,
        'type': typeString,
        'image_url': imageUrl,
      };

      await supabaseService.createItem(newItem);
      ref.invalidate(itemsProvider(typeString));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PosterScreen(item: newItem)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Publicado com sucesso! Cartaz gerado.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao publicar: $e")),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == PostType.lost ? "Perdi Algo" : "Encontrei Algo",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Multiple Photo Upload Area
              _buildPhotoSection(),
              const SizedBox(height: 24),
              
              _buildFieldLabel("Título do Objeto"),
              _buildTextField(controller: _titleController, hint: "Ex: iPhone 13 Pro Max"),
              
              const SizedBox(height: 16),
              _buildFieldLabel("Categoria"),
              _buildCategorySelector(),
              
              const SizedBox(height: 16),
              _buildFieldLabel("Descrição Detalhada"),
              _buildTextField(controller: _descController, hint: "Descreva o objeto, marcas de uso, etc.", maxLines: 4),
              
              const SizedBox(height: 16),
              _buildFieldLabel("Recompensa (Opcional)"),
              _buildTextField(
                controller: TextEditingController(), 
                hint: "Ex: 20€", 
                icon: Icons.monetization_on_rounded,
              ),
              
              const SizedBox(height: 16),
              _buildFieldLabel("Localização (Simulada)"),
              GlassBox(
                child: ListTile(
                  leading: const Icon(Icons.location_on_rounded, color: AppColors.accent),
                  title: const Text("Parque da Cidade (Simulado)"),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
              ),
              
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.type == PostType.lost ? AppColors.error : AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.type == PostType.lost ? "Publicar Perda" : "Publicar Achado",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Fotos do Objeto (${_images.length}/5)"),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: AppColors.accent, size: 32),
                      SizedBox(height: 8),
                      Text("Adicionar", style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              // Image List
              ..._images.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: MemoryImage(entry.value),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 17,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(entry.key)),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black.withOpacity(0.5),
                          child: const Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Aceita: JPG, PNG, WEBP, HEIC",
          style: TextStyle(color: AppColors.grey, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1, IconData? icon}) {
    return GlassBox(
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: AppColors.accent, size: 20) : null,
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.5)),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return GlassBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _category,
          dropdownColor: AppColors.surface,
          items: ["Electrónicos", "Documentos", "Vestuário", "Animais", "Outros"]
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(e, style: const TextStyle(color: Colors.white)),
                    ),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _category = val);
          },
        ),
      ),
    );
  }
}
