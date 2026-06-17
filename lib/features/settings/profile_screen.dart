import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import '../../providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final hasProfile = profile.name.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.editProfile,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile header
            GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.editProfile,
              ),
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
                    child: profile.photoPath != null
                        ? ClipOval(
                            child: Image.file(
                              File(profile.photoPath!),
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
            const SizedBox(height: 20),
            Text(
              hasProfile ? profile.name : 'NaruhDimana',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hasProfile ? 'Profil Pengguna' : 'Ingat semua, temukan segalanya',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),

            if (hasProfile) ...[
              const SizedBox(height: 24),
              // Profile info cards
              ProfileInfoCard(
                icon: Icons.cake_outlined,
                label: 'Umur',
                value: profile.age > 0 ? '${profile.age} tahun' : '-',
              ),
              const SizedBox(height: 8),
              ProfileInfoCard(
                icon: profile.gender == 'Laki-laki'
                    ? Icons.male
                    : profile.gender == 'Perempuan'
                        ? Icons.female
                        : Icons.person_outline,
                label: 'Jenis Kelamin',
                value: profile.gender.isNotEmpty ? profile.gender : '-',
              ),
              if (profile.address.isNotEmpty) ...[
                const SizedBox(height: 8),
                ProfileInfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: profile.address,
                ),
              ],
              if (profile.hobbies.isNotEmpty) ...[
                const SizedBox(height: 8),
                ProfileInfoCard(
                  icon: Icons.favorite_outline,
                  label: 'Hobi',
                  value: profile.hobbies,
                ),
              ],
            ],

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),

            // Menu items
            ProfileMenuItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profil',
              subtitle: 'Ubah data diri Anda',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.editProfile,
              ),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.category,
              title: 'Kelola Kategori',
              subtitle: 'Tambah atau hapus kategori kustom',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.manageCategories,
              ),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'v1.0.0+2',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.about,
              ),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.shield_outlined,
              title: 'Kebijakan Privasi',
              subtitle: 'Bagaimana data Anda dilindungi',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.privacyPolicy,
              ),
            ),
            const Divider(height: 1),
            ProfileMenuItem(
              icon: Icons.star_outline,
              title: 'Beri Rating',
              subtitle: 'Dukung kami di Play Store',
              onTap: () {},
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ProfileInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
