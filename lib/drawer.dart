import 'package:flutter/material.dart';
import 'package:imagen/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Drawer build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.AIImageGenerator,
                style: TextStyle(
                  fontSize: 24,
                ),
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
              onTap: () {}),
          const SizedBox(),
          const Divider(),
        ],
      ),
    );
  }
}
