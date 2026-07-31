part of 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to farmer screen',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.42),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AgrisellColors.surface,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photoBytes,
    required this.onTap,
    this.errorText,
  });

  final Uint8List? photoBytes;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final photoBytes = this.photoBytes;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final previewWidth = (screenWidth - 52).clamp(270.0, 360.0);
    final previewHeight = (previewWidth * 0.68).clamp(184.0, 230.0);

    return Semantics(
      button: true,
      label: 'Insert product photo',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              if (photoBytes == null)
                Icon(
                  Icons.photo_camera_outlined,
                  color: AgrisellColors.brandBlack.withValues(alpha: 0.46),
                  size: 58,
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ResponsiveAssetImage(
                    imageBytes: photoBytes,
                    width: previewWidth,
                    height: previewHeight,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                photoBytes == null ? 'Insert photo' : 'Change photo',
                style: TextStyle(
                  color: AgrisellColors.brandBlack.withValues(alpha: 0.56),
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                photoBytes == null
                    ? 'Use one clear, well-lit product photo'
                    : 'Tap the photo to replace it',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                ),
              ),
              if (errorText case final error?) ...[
                const SizedBox(height: 6),
                Text(
                  error,
                  style: const TextStyle(
                    color: AgrisellColors.statusRedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
