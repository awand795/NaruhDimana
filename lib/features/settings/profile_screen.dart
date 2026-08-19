import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/router.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/item_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final hasProfile = profile.name.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statsAsync = ref.watch(itemStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text('Profil', style: Theme.of(context).textTheme.titleLarge),
          ),
          SliverToBoxAdapter(
            child: _ProfileHeader(
              profileName: profile.name,
              profileSubtitle: hasProfile
                  ? (profile.address.isNotEmpty
                      ? profile.address
                      : 'Profil Pengguna')
                  : 'Ingat semua, temukan segalanya',
              photoPath: profile.photoPath,
              hasProfile: hasProfile,
              isDark: isDark,
            ),
          ),

          // ── Strip statistik (menimpa header) ───────────────
          SliverToBoxAdapter(
            child: statsAsync.when(
              data: (stats) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StatsStrip(
                  total: stats['total'] ?? 0,
                  locations: stats['locations'] ?? 0,
                  reminders: stats['reminders'] ?? 0,
                ),
              ),
              loading: () => const SizedBox(height: 16),
              error: (_, __) => const SizedBox(height: 16),
            ),
          ),

          // ── Menu berkelompok ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MenuGroupLabel('Pengaturan Umum'),
                  const SizedBox(height: 8),
                  _MenuCard(items: [
                    _MenuEntry(
                      icon: Icons.person_rounded,
                      title: 'Akun',
                      subtitle: 'Kelola data personal',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.editProfile),
                    ),
                    _MenuEntry(
                      icon: Icons.category_rounded,
                      title: 'Kelola Kategori',
                      subtitle: 'Tambah atau hapus kategori kustom',
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.manageCategories),
                    ),
                    _MenuEntry(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Kebijakan Privasi',
                      subtitle: 'Bagaimana data Anda dilindungi',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.privacyPolicy),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _MenuGroupLabel('Dukungan'),
                  const SizedBox(height: 8),
                  _MenuCard(items: [
                    _MenuEntry(
                      icon: Icons.help_rounded,
                      title: 'Pusat Bantuan',
                      subtitle: 'FAQ & Kontak dukungan',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    _MenuEntry(
                      icon: Icons.info_rounded,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi & informasi aplikasi',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    _MenuEntry(
                      icon: Icons.star_rounded,
                      title: 'Beri Rating',
                      subtitle: 'Dukung kami di Play Store',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Terima kasih atas dukungan Anda!')),
                        );
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // ── Keluar ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
              child: _LogoutButton(
                onTap: () => _confirmLogout(context),
              ),
            ),
          ),

          // ── Footer versi ───────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                children: [
                  Icon(Icons.rocket_launch_outlined,
                      color: AppTheme.outline, size: 20),
                  SizedBox(height: 6),
                  Text(
                    'Versi 1.0.0+2',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.outline,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Dibuat dengan presisi.',
                    style: TextStyle(fontSize: 10, color: AppTheme.outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari NaruhDimana?'),
        content: const Text(
          'Data barang akan tetap tersimpan di perangkat Anda.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda telah keluar')),
      );
    }
  }
}

// ── Header profil ──────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String profileName;
  final String profileSubtitle;
  final String? photoPath;
  final bool hasProfile;
  final bool isDark;

  const _ProfileHeader({
    required this.profileName,
    required this.profileSubtitle,
    required this.photoPath,
    required this.hasProfile,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = hasProfile ? profileName : 'NaruhDimana';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'N';

    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF232936) : AppTheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar + badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow(alpha: 0.12),
                ),
                child: ClipOval(
                  child: photoPath != null
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          width: 88,
                          height: 88,
                          errorBuilder: (_, __, ___) => _AvatarFallback(
                              initial: initial, isDark: isDark),
                        )
                      : _AvatarFallback(initial: initial, isDark: isDark),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: AppTheme.softShadow(alpha: 0.25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasProfile
                            ? Icons.check_rounded
                            : Icons.auto_awesome_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasProfile ? 'Lengkap' : 'Baru',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              profileSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          // Edit Profil button — pill putih
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pushNamed(context, AppRoutes.editProfile);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: AppTheme.softShadow(alpha: 0.08),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: AppTheme.primaryColor),
                  SizedBox(width: 6),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String initial;
  final bool isDark;

  const _AvatarFallback({required this.initial, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Strip statistik ────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  final int total;
  final int locations;
  final int reminders;

  const _StatsStrip({
    required this.total,
    required this.locations,
    required this.reminders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
        boxShadow: AppTheme.softShadow(alpha: 0.06),
      ),
      child: Row(
        children: [
          _StatItem(value: '$total', label: 'Tersimpan'),
          _divider(),
          _StatItem(value: '$locations', label: 'Lokasi'),
          _divider(),
          _StatItem(value: '$reminders', label: 'Pengingat'),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: AppTheme.surfaceContainerHigh);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.outline,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu berkelompok ───────────────────────────────────────
class _MenuGroupLabel extends StatelessWidget {
  final String label;

  const _MenuGroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MenuEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuEntry> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceContainerHigh),
        boxShadow: AppTheme.softShadow(alpha: 0.04),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: const EdgeInsets.only(left: 68),
                color: AppTheme.surfaceContainerHigh,
              ),
            _MenuRow(entry: items[i]),
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final _MenuEntry entry;

  const _MenuRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: entry.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(entry.icon, size: 20, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}

// ── Tombol Keluar ──────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.errorContainer.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(color: AppTheme.errorContainer),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: AppTheme.error),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
