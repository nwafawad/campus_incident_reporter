import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../utils/constants.dart';

class PhotoPicker extends StatelessWidget {
  const PhotoPicker({
    super.key,
    required this.photos,
    required this.photoUrls,
    required this.onAdd,
    required this.onRemovePhoto,
    required this.onRemoveUrl,
  });

  final List<XFile> photos; // new, not uploaded yet
  final List<String> photoUrls; // already uploaded (when editing)
  final ValueChanged<XFile> onAdd;
  final ValueChanged<XFile> onRemovePhoto;
  final ValueChanged<String> onRemoveUrl;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    // Shrinks big phone photos so they usually stay under the limit.
    final photo = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (photo == null) return;

    if (await photo.length() > maxPhotoBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('That photo is over 5 MB. Choose a smaller one.'),
          ),
        );
      }
      return;
    }
    onAdd(photo);
  }

  @override
  Widget build(BuildContext context) {
    final full = photos.length + photoUrls.length >= maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final url in photoUrls)
              _Thumbnail(
                image: Image.network(url, fit: BoxFit.cover),
                onRemove: () => onRemoveUrl(url),
              ),
            for (final photo in photos)
              _Thumbnail(
                image: Image.file(File(photo.path), fit: BoxFit.cover),
                onRemove: () => onRemovePhoto(photo),
              ),
            if (!full) ...[
              _AddButton(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onTap: () => _pick(context, ImageSource.camera),
              ),
              _AddButton(
                icon: Icons.photo_outlined,
                label: 'Gallery',
                onTap: () => _pick(context, ImageSource.gallery),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Up to $maxPhotos photos, JPG or PNG under ${maxPhotoBytes ~/ (1024 * 1024)} MB',
        ),
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.image, required this.onRemove});

  final Widget image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: image,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove photo',
              iconSize: 18,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 96,
          height: 96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
