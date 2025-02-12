import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../managers/login_manager.dart';
import 'themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});


  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Dark Theme',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Switch(
                  value: themeProvider.isDarkTheme,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24), // Adds spacing before Sign Out button
            TextButton(
                onPressed: () => _signOut(context),
                child: Text('Sign Out', style: Theme.of(context).textTheme.bodyMedium,),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await LoginManager.signout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
