import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// About screen for OM Manager
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About OM Manager'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // App Icon and Name
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'OM Manager',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _infoTile(
                      icon: Icons.tag,
                      label: 'Version',
                      value: '1.0.0',
                      context: context,
                    ),
                    const Divider(height: 20),
                    _infoTile(
                      icon: Icons.person,
                      label: 'Developer',
                      value: '@omar_cherigui_dev_2026',
                      context: context,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'About',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A powerful file manager for Android, inspired by MT Manager. '
                      'OM Manager provides fast and intuitive file browsing, '
                      'management, and sharing capabilities with a clean and modern interface.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Features Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Features',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _featureItem('📁 File and folder management'),
                    _featureItem('📋 Copy, cut, and paste operations'),
                    _featureItem('🗑️ Delete files and folders'),
                    _featureItem('📤 Share files with other apps'),
                    _featureItem('🔍 View file information'),
                    _featureItem('🎯 Multi-file selection'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Made with ❤️ for Android',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 OM Manager. All rights reserved.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Text(
        text,
        style: const TextStyle(height: 1.6),
      ),
    );
  }
}
