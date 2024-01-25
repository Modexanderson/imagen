import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../screens/settings.dart';
import '../services/authentification_service.dart';
import 'show_confirmation_dialog.dart';

class AppDrawer extends StatelessWidget {
  final String appVersion;
  AppDrawer({required this.appVersion, super.key});

  final String userEmail = AuthentificationService().currentUser.email!;
  void _launchPrivacyPolicy() async {
    const _privacyPolicy =
        'https://www.privacypolicies.com/live/6913039d-ae2e-4e47-9937-de2ea5fc269d';
    if (await canLaunchUrl(Uri.parse(_privacyPolicy))) {
      await launchUrl(Uri.parse(_privacyPolicy));
    } else {
      if (kDebugMode) {
        print('Could not launch website call.');
      }
    }
  }

  final _appLink = Platform.isAndroid ? 'https://cupertinostudios.online/#/imagen/android' : '' ;
  void _shareApp() {
    Share.share(_appLink);
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
              leading: const Icon(
                Icons.share,
              ),
              title: Text(
                AppLocalizations.of(context)!.share,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              onTap: () {
                _shareApp();
              }),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
            ),
            title: Text(
              AppLocalizations.of(context)!.signOut,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Text(userEmail),
            onTap: () async {
              final confirmation = await showConfirmationDialog(
                context,
                AppLocalizations.of(context)!.confirmSignOut,
                negativeResponse: AppLocalizations.of(context)!.no,
                positiveResponse: AppLocalizations.of(context)!.yes,
              );
              if (confirmation) AuthentificationService().signOut();
            },
          ),
          const SizedBox(
            height: 20,
          ),
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
