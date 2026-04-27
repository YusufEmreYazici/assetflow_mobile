import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:assetflow_mobile/core/services/haptic_service.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;
  final String? secondaryCtaLabel;
  final VoidCallback? onSecondaryCtaPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCtaPressed,
    this.secondaryCtaLabel,
    this.onSecondaryCtaPressed,
  });

  const EmptyState.noDevices({
    super.key,
    VoidCallback? onAddDevice,
    VoidCallback? onScanQr,
  }) : icon = Icons.computer_outlined,
       title = 'Henüz cihaz yok',
       description =
           'İlk cihazını ekleyerek başla veya QR kod tarayarak hızlıca ekle.',
       ctaLabel = 'İlk Cihazı Ekle',
       onCtaPressed = onAddDevice,
       secondaryCtaLabel = 'QR Tara',
       onSecondaryCtaPressed = onScanQr;

  const EmptyState.noEmployees({super.key, VoidCallback? onAdd})
    : icon = Icons.people_outline,
      title = 'Henüz personel yok',
      description =
          'Sisteme personel ekleyerek cihaz zimmetlemeye başlayabilirsin.',
      ctaLabel = 'Personel Ekle',
      onCtaPressed = onAdd,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  const EmptyState.noAssignments({super.key})
    : icon = Icons.assignment_outlined,
      title = 'Zimmet yok',
      description =
          'Henüz oluşturulmuş bir zimmet bulunmuyor. Cihaz detayından zimmet oluşturabilirsin.',
      ctaLabel = null,
      onCtaPressed = null,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  const EmptyState.noNotifications({super.key})
    : icon = Icons.notifications_off_outlined,
      title = 'Bildirim yok',
      description =
          'Şu an için bir bildirim bulunmuyor. Garanti uyarıları ve sistem bildirimleri buraya gelecek.',
      ctaLabel = null,
      onCtaPressed = null,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  const EmptyState.noSearchResults({super.key, required String query})
    : icon = Icons.search_off,
      title = 'Sonuç bulunamadı',
      description =
          '"$query" için hiçbir kayıt bulunamadı. Farklı bir arama terimi deneyin.',
      ctaLabel = null,
      onCtaPressed = null,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  const EmptyState.noFavorites({super.key, VoidCallback? onBrowse})
    : icon = Icons.star_border,
      title = 'Favori yok',
      description =
          'Sık erişmek istediğin cihazlara ⭐ tıklayarak buraya ekleyebilirsin.',
      ctaLabel = 'Cihazlara Göz At',
      onCtaPressed = onBrowse,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  const EmptyState.filterNoResults({super.key, VoidCallback? onClearFilter})
    : icon = Icons.filter_alt_off_outlined,
      title = 'Filtreyle eşleşen yok',
      description =
          'Aktif filtreler hiçbir sonuç getirmedi. Filtreyi temizle veya değiştir.',
      ctaLabel = 'Filtreyi Temizle',
      onCtaPressed = onClearFilter,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  const EmptyState.noLocations({super.key, VoidCallback? onAdd})
    : icon = Icons.location_off_outlined,
      title = 'Lokasyon yok',
      description =
          'Henüz lokasyon eklenmemiş. Cihazları konumlarına göre gruplamak için lokasyon ekle.',
      ctaLabel = 'Lokasyon Ekle',
      onCtaPressed = onAdd,
      secondaryCtaLabel = null,
      onSecondaryCtaPressed = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surfaceDivider),
              ),
              child: Icon(icon, size: 40, color: AppColors.navyLight),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onCtaPressed == null
                    ? null
                    : () {
                        HapticService.medium();
                        onCtaPressed!();
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    ctaLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            if (secondaryCtaLabel != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onSecondaryCtaPressed == null
                    ? null
                    : () {
                        HapticService.light();
                        onSecondaryCtaPressed!();
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    secondaryCtaLabel!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.navyLight,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
