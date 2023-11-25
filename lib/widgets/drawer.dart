import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../pages/settings.dart';

class AppDrawer extends StatelessWidget {
  final String appVersion;
  const AppDrawer({required this.appVersion, super.key});

  void _launchPrivacyPolicy() async {
    const _privacyPolicy =
        'https://www.privacypolicies.com/live/6913039d-ae2e-4e47-9937-de2ea5fc269d';
    if (await canLaunch(_privacyPolicy)) {
      await launch(_privacyPolicy);
    } else {
      if (kDebugMode) {
        print('Could not launch website call.');
      }
    }
  }

  @override
  Drawer build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            child: Center(
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.aiImageGenerator,
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Alva'),
                  ),
                  Text(
                    'v$appVersion',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(
                AppLocalizations.of(context)!.home,
                style: const TextStyle(fontSize: 15),
              ),
              onTap: () {
                Navigator.of(context).pop();
              }),
          const SizedBox(
            height: 20,
          ),
          ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(
                AppLocalizations.of(context)!.settings,
                style: const TextStyle(fontSize: 15),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Settings(
                          // callback: callback,
                          ),
                    ));
              }),
          const SizedBox(
            height: 20,
          ),
          // ListTile(
          //     leading: const Icon(Icons.privacy_tip_outlined),
          //     title: const Text(
          //       AppL,
          //       style: TextStyle(fontSize: 15),
          //     ),
          //     onTap: () {}),
          // const SizedBox(
          //   height: 20,
          // ),
          ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(
                AppLocalizations.of(context)!.about,
                style: const TextStyle(fontSize: 15),
              ),
              onTap: () {
                _launchPrivacyPolicy();
              }),
          const SizedBox(),
          const Divider(),
        ],
      ),
    );
  }
}
