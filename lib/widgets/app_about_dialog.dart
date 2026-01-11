import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

class AppAboutDialog extends StatelessWidget {
  const AppAboutDialog({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        String version = "Loading...";
        String buildNumber = "";
        
        if (snapshot.hasData) {
          version = snapshot.data!.version;
          buildNumber = snapshot.data!.buildNumber;
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. App Logo / Title
                const Icon(Icons.radio, size: 48, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                const Text(
                  "Wavelog Portable",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  "v$version (Build $buildNumber)",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                
                const Divider(height: 32),

                // 2. Developer Info
                const Text("Developed by", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                const Text("K1GLV - Daniel Tang", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _launchUrl("https://github.com/greenlava82/WavelogPortable"),
                  icon: const Icon(Icons.code, size: 16),
                  label: const Text("View Source Code"),
                ),

                const SizedBox(height: 16),

                // 3. Wavelog Info
                const Text("Powered by (and with special thanks to)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                const Text("Wavelog", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: () => _launchUrl("https://github.com/wavelog/wavelog"),
                  icon: const Icon(Icons.link, size: 16),
                  label: const Text("Wavelog Project"),
                ),
                
                const SizedBox(height: 24),
                
                // 4. Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}