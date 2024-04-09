import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

import '../bloc/image_cubit.dart';
import '../models/image_info.dart';
import '../screens/settings.dart';
import '../services/authentification_service.dart';
import 'show_confirmation_dialog.dart';

class AppDrawer extends StatefulWidget {
  final String appVersion;
  final Function(String) setPromptCallback;

  AppDrawer({
    Key? key,
    required this.appVersion,
    required this.setPromptCallback,
  }) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
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
      : 'https://apps.apple.com/app/imagen-ai/id6478289950';

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
      AppLocalizations.of(context)!.history,
      style: const TextStyle(fontSize: 15),
    ),
    children: [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: reversedList.length,
        itemBuilder: (context, index) {
          final imageInfo = reversedList[index];
          return BlocProvider(
            create: (context) => ImageCubit(),
            child: ListTile(
              leading: Image.memory(
            imageInfo.image,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
          ),
              title: Text(
                imageInfo.prompt,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              onTap: () {
                context.read<ImageCubit>().setSelectedImage(imageInfo.image);
                widget.setPromptCallback(imageInfo.prompt);
                Navigator.pop(context);
              },
              trailing: PopupMenuButton<int>(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        const Icon(Icons.share),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.share.split(' ').first),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        const Icon(Icons.delete),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.delete),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 0) {
                    _shareImage(imageInfo.image);
                  } else if (value == 1) {
                    _showDeleteConfirmationDialog(context, imageInfo);
                  }
                },
                icon: const Icon(Icons.more_vert),
              ),
            ),
          );
        },
      ),
    ],
  );
}


  void _showDeleteConfirmationDialog(BuildContext context, dynamic imageInfo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete),
          content: Text(
            '${AppLocalizations.of(context)!.deleteThemeSubtitle} ${imageInfo.prompt}',
            overflow: TextOverflow.fade,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                _deleteImage(context, imageInfo);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  void _deleteImage(BuildContext context, HiveImageInfo imageInfo) {
    final imageHistoryBox = Hive.box('imageHistory');

    // Find the key associated with the provided imageInfo
    final key =
        imageHistoryBox.values.toList().indexWhere((item) => item == imageInfo);

    if (key != -1) {
      // If the key is found, delete the item from the box
      imageHistoryBox.deleteAt(key);
      setState(() {});

      // Update the UI or notify state management solution accordingly
    }
  }

  void _shareImage(Uint8List imageBytes) async {
    // Convert the imageBytes to base64 encoding
    String base64Image = base64Encode(imageBytes);

    // Create a temporary directory
    Directory tempDir = await getTemporaryDirectory();

    // Create a temporary file to save the image
    File tempFile = File('${tempDir.path}/image.png');
    await tempFile.writeAsBytes(Uint8List.fromList(base64.decode(base64Image)));

    // Share the image using the share package
    Share.shareFiles(
      [tempFile.path],
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
                    'v${widget.appVersion}',
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
