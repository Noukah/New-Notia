import 'package:flutter/material.dart';
import 'package:notia/core/storage/secure_storage_service.dart';
import 'package:notia/features/notes/domain/models/recording_profile.dart';

class ProfileSelectorRow extends StatelessWidget {
  final Function(RecordingProfile profile) onProfileSelected;
  final VoidCallback onMissingApiKey;
  final SecureStorageService secureStorageService;

  const ProfileSelectorRow({
    super.key,
    required this.onProfileSelected,
    required this.onMissingApiKey,
    required this.secureStorageService,
  });

  Future<void> _handleProfileTap(BuildContext context, RecordingProfile profile) async {
    final apiKey = await secureStorageService.getApiKey();
    if (apiKey == null || apiKey.trim().isEmpty) {
      onMissingApiKey();
      return;
    }
    onProfileSelected(profile);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = RecordingProfile.defaultProfiles;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = isDark ? const Color(0xFFD6D6D6) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: profiles.map((profile) {
          return Tooltip(
            message: '${profile.name}: ${profile.description}',
            child: GestureDetector(
              onTap: () => _handleProfileTap(context, profile),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: buttonColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      profile.icon,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
