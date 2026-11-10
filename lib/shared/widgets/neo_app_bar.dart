import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/audio_service.dart';
import '../../core/theme/neo_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'neo_modal.dart';

class NeoAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onAvatarTap;

  const NeoAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final user = userAsync.asData?.value;

    String initials = 'US';
    if (user != null && user.name.isNotEmpty) {
      final parts = user.name.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: NeoColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: NeoColors.black, width: 4.0),
        ),
        boxShadow: [
          BoxShadow(
            color: NeoColors.black,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: NeoColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 18.0,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (actions != null) ...actions!,

              // Tombol Notifikasi (Lonceng Neobrutalism)
              GestureDetector(
                onTap: () {
                  AudioService().playClickSound();
                  NeoModal.show(
                    context: context,
                    title: 'Pemberitahuan',
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'Belum ada notifikasi baru saat ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: NeoColors.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: NeoColors.yellowAccent,
                    border: Border.all(color: NeoColors.black, width: 2.0),
                    boxShadow: NeoColors.hardShadow(offset: 2.0),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.notifications_outlined, size: 22, color: NeoColors.black),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: NeoColors.dangerRed,
                            border: Border.all(color: NeoColors.black, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Avatar Pengguna
              GestureDetector(
                onTap: () {
                  AudioService().playClickSound();
                  onAvatarTap?.call();
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: NeoColors.primaryBlueLight,
                    border: Border.all(color: NeoColors.black, width: 2.0),
                    boxShadow: NeoColors.hardShadow(offset: 2.0),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: NeoColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

