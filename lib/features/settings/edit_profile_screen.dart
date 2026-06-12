import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/user_profile.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/image_service.dart';
import '../../core/theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _ageController = TextEditingController();
  final ImageService _imageService = ImageService();

  String _gender = '';
  String? _photoPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController.text = profile.name;
    _addressController.text = profile.address;
    _hobbiesController.text = profile.hobbies;
    _ageController.text = profile.age > 0 ? profile.age.toString() : '';
    _gender = profile.gender;
    _photoPath = profile.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _hobbiesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin kamera diperlukan')),
          );
        }
        return;
      }
    }

    String? path;
    if (source == ImageSource.camera) {
      path = await _imageService.pickFromCamera();
    } else {
      path = await _imageService.pickFromGallery();
    }

    if (path != null && mounted) {
      setState(() => _photoPath = path);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Foto Profil',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.camera_alt)),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.photo_library)),
                title: const Text('Pilih dari Galeri'),
                subtitle: const Text('Dari penyimpanan'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text('Hapus Foto'),
                  subtitle: const Text('Kembali ke default'),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _photoPath = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final profile = UserProfile(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      hobbies: _hobbiesController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _gender,
      photoPath: _photoPath,
    );

    await ref.read(userProfileProvider.notifier).updateProfile(profile);

    if (mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Photo
            GestureDetector(
              onTap: _showImagePicker,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: _photoPath != null
                          ? ClipOval(
                              child: Image.file(
                                File(_photoPath!),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Nama
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Contoh: Awanda Putri',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Umur
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Umur',
                hintText: 'Contoh: 25',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 150) {
                    return 'Masukkan umur yang valid';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Jenis Kelamin
            Text(
              'Jenis Kelamin',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = 'Laki-laki'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _gender == 'Laki-laki'
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: _gender == 'Laki-laki'
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color: _gender == 'Laki-laki'
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Laki-laki',
                            style: TextStyle(
                              color: _gender == 'Laki-laki'
                                  ? Colors.white
                                  : AppTheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = 'Perempuan'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _gender == 'Perempuan'
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: _gender == 'Perempuan'
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color: _gender == 'Perempuan'
                                ? Colors.white
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Perempuan',
                            style: TextStyle(
                              color: _gender == 'Perempuan'
                                  ? Colors.white
                                  : AppTheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Alamat
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat',
                hintText: 'Contoh: Jl. Merdeka No. 123, Jakarta',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Hobi
            TextFormField(
              controller: _hobbiesController,
              decoration: const InputDecoration(
                labelText: 'Hobi',
                hintText: 'Contoh: Membaca, Memasak, Berenang',
                prefixIcon: Icon(Icons.favorite_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Profil',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
