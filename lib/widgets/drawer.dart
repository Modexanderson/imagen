import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../bloc/image_cubit.dart';
import '../screens/settings.dart';
import '../services/authentification_service.dart';
import 'show_confirmation_dialog.dart';

class AppDrawer extends StatelessWidget {
  final String appVersion;
  final Function(String) setPromptCallback;

  AppDrawer({
    Key? key,
    required this.appVersion,
    required this.setPromptCallback,
  }) : super(key: key);

  final String userEmail = AuthentificationService().currentUser.email!;
  void _launchPrivacyPolicy() async {
    const privacyPolicy =
        'https://www.privacypolicies.com/live/6913039d-ae2e-4e47-9937-de2ea5fc269d';
    if (await canLaunchUrl(Uri.parse(privacyPolicy))) {
      await launchUrl(Uri.parse(privacyPolicy));
    } else {
      if (kDebugMode) {
        print('Could not launch website call.');
      }
    }
  }

  final _appLink = Platform.isAndroid
      ? 'https://cupertinostudios.online/#/imagen/android'
      : '';
  void _shareApp() {
    Share.share(_appLink);
  }

  ExpansionTile buildHistoryTile(BuildContext context) {
    final imageHistoryBox = Hive.box('imageHistory');
    final reversedList = List.generate(
      imageHistoryBox.length,
      (index) => imageHistoryBox.getAt(index),
    ).reversed.toList();

    return ExpansionTile(
      leading: const Icon(Icons.history_outlined),
      title: Text(
        AppLocalizations.of(context)!.showHistory.split(' ').last,
        style: const TextStyle(fontSize: 15),
      ),
      children: reversedList.map((imageInfo) {
        return BlocProvider(
          create: (context) => ImageCubit(),
          child: ListTile(
            leading: Image.memory(imageInfo!.image, width: 40, height: 40),
            title: Text(
              imageInfo.prompt,
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
            onTap: () {
              context.read<ImageCubit>().setSelectedImage(imageInfo.image);
              setPromptCallback(imageInfo.prompt); // Call the callback function
              Navigator.pop(context);
            },
          ),
        );
      }).toList(),
    );
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
          buildHistoryTile(context),
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
