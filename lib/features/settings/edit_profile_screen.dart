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
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
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
    _ageController.text =
        profile.age > 0 ? profile.age.toString() : '';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Foto Profil',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.camera_alt)),
                title: const Text('Ambil Foto'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.photo_library)),
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

    await ref
        .read(userProfileProvider.notifier)
        .updateProfile(profile);

    if (mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan!'),
          backgroundColor: Color(0xFF059669),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF232936) : AppTheme.surfaceContainerLow;
    final initial = _nameController.text.isNotEmpty
        ? _nameController.text[0].toUpperCase()
        : 'N';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: const Text('Edit Profil'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Avatar with gradient ring ──────────────────
            Center(
              child: GestureDetector(
                onTap: _showImagePicker,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowShadow(
                            AppTheme.primaryColor,
                            alpha: 0.2),
                      ),
                      child: ClipOval(
                        child: _photoPath != null
                            ? Image.file(
                                File(_photoPath!),
                                fit: BoxFit.cover,
                                width: 112,
                                height: 112,
                                errorBuilder: (_, __, ___) =>
                                    _AvatarFallback(
                                        initial: initial),
                              )
                            : _AvatarFallback(initial: initial),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Name field ────────────────────────────────
            _LabeledField(
              label: 'Nama Lengkap',
              hint: 'Contoh: Awanda Putri',
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Age field ─────────────────────────────────
            _LabeledField(
              label: 'Umur',
              hint: 'Contoh: 25',
              controller: _ageController,
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
            const SizedBox(height: 20),

            // ── Gender toggle ─────────────────────────────
            Text('Jenis Kelamin',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.outline,
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _GenderToggle(
                    label: 'Laki-laki',
                    icon: Icons.male_rounded,
                    selected: _gender == 'Laki-laki',
                    onTap: () =>
                        setState(() => _gender = 'Laki-laki'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderToggle(
                    label: 'Perempuan',
                    icon: Icons.female_rounded,
                    selected: _gender == 'Perempuan',
                    onTap: () =>
                        setState(() => _gender = 'Perempuan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Address field ─────────────────────────────
            _LabeledField(
              label: 'Alamat',
              hint: 'Contoh: Jl. Merdeka No. 123, Jakarta',
              controller: _addressController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // ── Hobbies field ─────────────────────────────
            _LabeledField(
              label: 'Hobi',
              hint: 'Contoh: Membaca, Memasak, Berenang',
              controller: _hobbiesController,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
                child: _isSaving
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          ),
                          SizedBox(width: 10),
                          Text('Menyimpan...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 20),
                          SizedBox(width: 8),
                          Text('Simpan Profil',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar fallback ──────────────────────────────────────────
class _AvatarFallback extends StatelessWidget {
  final String initial;

  const _AvatarFallback({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Gender toggle ────────────────────────────────────────────
class _GenderToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderToggle({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.shortDuration,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: selected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : Border.all(
                  color: AppTheme.dividerColor),
          boxShadow: selected
              ? AppTheme.softShadow(alpha: 0.15)
              : AppTheme.softShadow(alpha: 0.03),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? Colors.white : AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Labeled field ────────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final int maxLines;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          textCapitalization: textCapitalization,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor:
                isDark ? const Color(0xFF1E293B) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
