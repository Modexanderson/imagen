// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import '../exceptions/firebase_sign_up_exception.dart';
import '../exceptions/messaged_firebase_auth_exception.dart';
import '../models/config.dart';
import '../models/constants.dart';
import '../services/authentification_service.dart';
import '../services/database/user_database_helper.dart';
import '../services/ext_storage_provider.dart';
import '../utils/backup_restore.dart';
import '../utils/box_switch_tile.dart';
import '../utils/picker.dart';
import '../widgets/async_progress_dialog.dart';
import '../widgets/default_progress_indicator.dart';
import '../widgets/default_text_form_field.dart';
import '../widgets/gradient_container.dart';
import '../widgets/snack_bar.dart';
import '../widgets/text_input_dialog.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? appVersion;
  final Box settingsBox = Hive.box('settings');
  final MyTheme currentTheme = GetIt.I<MyTheme>();
  String autoBackPath = Hive.box('settings').get(
    'autoBackPath',
    defaultValue: '/storage/emulated/0/Imagen/Backups',
  ) as String;
  String lang =
      Hive.box('settings').get('lang', defaultValue: 'English') as String;
  String canvasColor =
      Hive.box('settings').get('canvasColor', defaultValue: 'Grey') as String;
  String cardColor =
      Hive.box('settings').get('cardColor', defaultValue: 'Grey900') as String;
  String theme =
      Hive.box('settings').get('theme', defaultValue: 'Default') as String;
  Map userThemes =
      Hive.box('settings').get('userThemes', defaultValue: {}) as Map;

  String themeColor =
      Hive.box('settings').get('themeColor', defaultValue: 'Indigo') as String;
  int colorHue = Hive.box('settings').get('colorHue', defaultValue: 400) as int;

  List preferredLanguage = Hive.box('settings')
      .get('preferredLanguage', defaultValue: ['English'])?.toList() as List;

  // Fonts
  String appFont =
      Hive.box('settings').get('appFont', defaultValue: 'Oswald') as String;

  void switchToCustomTheme() {
    const custom = 'Custom';
    if (theme != custom) {
      currentTheme.setInitialTheme(custom);
      setState(
        () {
          theme = custom;
        },
      );
    }
  }

  // Account Deletion
  final AuthentificationService authService = AuthentificationService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isPasswordVisible = false;

  void _showDeleteAccountConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.delete),
          content: Text(
            '${AppLocalizations.of(context)!.deleteAccountConfitmation} ? \n${AppLocalizations.of(context)!.deleteAccountNote}',
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
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await _deleteAccount(context);
              },
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
  final provider = authService.currentUserProvider();
  final GlobalKey<State> key = GlobalKey<State>();

  try {
     // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          key: key,
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultProgressIndicator(),
            ],
          ),
        );
      },
    );

    // Check provider type and handle accordingly
    if (provider == "google") {
      await authService.deleteUserAccount();
      await authService.signOut();
    } else if (provider == "apple") {
      await authService.deleteUserAccount();
      await authService.signOut();
    } else {
       // Show reauthentication dialog for other providers
      _showReauthenticateDialog(context);
      // Hide loading dialog
      Navigator.of(key.currentContext!).pop();
      return;
    }

    // Hide loading dialog
    Navigator.of(key.currentContext!).pop();

    // Show success Snackbar
    ShowSnackBar().showSnackBar(context, AppLocalizations.of(context)!.deleted);
    Navigator.pop(context);

    // Navigate back to login screen
    Navigator.of(context).popUntil((route) => route.isFirst);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'requires-recent-login') {
      // Handle requires-recent-login error by showing reauthentication dialog
      _showReauthenticateDialog(context);
    } else {
      // Handle other FirebaseAuthExceptions
      print("Error deleting account: $e");
    }
    // Hide loading dialog
    // Navigator.of(key.currentContext!).pop();
  } catch (e) {
    // Handle other errors
    print("Error deleting account: $e");
    // Hide loading dialog
    // Navigator.of(key.currentContext!).pop();
  }
}

void _showReauthenticateDialog(BuildContext context) {
  final authService = AuthentificationService();
  final provider = authService.currentUserProvider();
  final TextEditingController passwordFieldController = TextEditingController();
  bool isPasswordVisible = false; // Track password visibility
  String? passwordError; // Track password validation error

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (provider == "google" || provider == "apple")
              const Text(
                "",
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            else
              Text(
                AppLocalizations.of(context)!.enterPassword,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 20),
            if (provider != "google" && provider != "apple")
              TextFormField(
                controller: passwordFieldController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                  hintText: AppLocalizations.of(context)!.enterPassword,
                  errorText: passwordError,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    child: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.getPassNullError(context);
                  }
                  return null;
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              // Perform reauthentication and delete account
              if (provider != "google" && provider != "apple") {
                String password = passwordFieldController.text.trim();
                if (password.isEmpty) {
                  setState(() {
                    passwordError = AppStrings.getPassNullError(context);
                  });
                  return;
                }
                await _reauthenticateAndDeleteAccount(context, password);
              } else {
                if (provider == "google") {
                  await authService.signUpWithGoogle(context);
                } else if (provider == "apple") {
                  await authService.signUpWithApple(context);
                }
                await _reauthenticateAndDeleteAccount(context, ""); // No need for password in these cases
              }
            },
            child: Text(AppLocalizations.of(context)!.confirmPassword),
          ),
        ],
      );
    },
  );
}

  Future<void> _reauthenticateAndDeleteAccount(
    BuildContext context,
    String password,
  ) async {
    // Create a GlobalKey for the loading spinner dialog
    final GlobalKey<State> key = GlobalKey<State>();
    try {
      // Reauthenticate the user
      User? user = authService.currentUser;
      if (user != null) {
        var credential = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              key: key,
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultProgressIndicator(),
                  // SizedBox(height: 16),
                  // Text(AppLocalizations.of(context)!
                  //     .creatingBinanceOrder),
                ],
              ),
            );
          },
        );
        // Delete the user account
        await authService.deleteUserAccount();
        // await UserDatabaseHelper().deleteCurrentUserData();

        // Sign out after deletion
        await authService.signOut();
        Navigator.of(key.currentContext!).pop();

        // Show success Snackbar
        ShowSnackBar()
            .showSnackBar(context, AppLocalizations.of(context)!.deleted);

        // Navigate back to login screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        throw FirebaseAuthException(
            message: AppLocalizations.of(context)!.userNotFoundException,
            code: "user-not-found");
      }
    } on FirebaseAuthException catch (e) {
      ShowSnackBar().showSnackBar(context, e.message!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> userThemesList = <String>[
      'Default',
      ...userThemes.keys.map((theme) => theme as String),
      'Custom',
    ];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                  child: Text(
                    AppLocalizations.of(context)!.theme,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
                BoxSwitchTile(
                  title: Text(AppLocalizations.of(context)!.darkMode),
                  keyName: 'darkMode',
                  defaultValue: false,
                  onChanged: (bool val, Box box) {
                    box.put('useSystemTheme', false);
                    currentTheme.switchTheme(
                        isDark: val, useSystemTheme: false);
                  },
                ),
                BoxSwitchTile(
                  title: Text(
                    AppLocalizations.of(context)!.useSystemTheme,
                  ),
                  keyName: 'useSystemTheme',
                  defaultValue: false,
                  onChanged: (bool val, Box box) {
                    currentTheme.switchTheme(useSystemTheme: val);
                    switchToCustomTheme();
                  },
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.accent,
                  ),
                  subtitle: Text('$themeColor, $colorHue'),
                  trailing: Padding(
                    padding: const EdgeInsets.all(
                      10.0,
                    ),
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5.0,
                        ),
                        color: Theme.of(context).colorScheme.secondary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[900]!,
                            blurRadius: 5.0,
                            offset: const Offset(
                              0.0,
                              3.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        final List<String> colors = [
                          'Purple',
                          'Deep Purple',
                          'Indigo',
                          'Blue',
                          'Light Blue',
                          'Cyan',
                          'Teal',
                          'Green',
                          'Light Green',
                          'Lime',
                          'Yellow',
                          'Amber',
                          'Orange',
                          'Deep Orange',
                          'Red',
                          'Pink',
                          'White',
                        ];
                        return BottomGradientContainer(
                          borderRadius: BorderRadius.circular(
                            20.0,
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.all(10),
                            itemCount: colors.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    for (int hue in [100, 200, 400, 700])
                                      Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: GestureDetector(
                                          onTap: () {
                                            themeColor = colors[index];
                                            colorHue = hue;
                                            currentTheme.switchColor(
                                              colors[index],
                                              colorHue,
                                            );
                                            setState(
                                              () {},
                                            );
                                            switchToCustomTheme();
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                10.0,
                                              ),
                                              color: MyTheme().getColor(
                                                colors[index],
                                                hue,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey[900]!,
                                                  blurRadius: 5.0,
                                                  offset: const Offset(
                                                    0.0,
                                                    3.0,
                                                  ),
                                                )
                                              ],
                                            ),
                                            child:
                                                (themeColor == colors[index] &&
                                                        colorHue == hue)
                                                    ? const Icon(
                                                        Icons.done_rounded,
                                                      )
                                                    : const SizedBox(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  dense: true,
                ),
                Visibility(
                  visible: Theme.of(context).brightness == Brightness.dark,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.canvasColor,
                        ),
                        onTap: () {},
                        trailing: DropdownButton(
                          value: canvasColor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              switchToCustomTheme();
                              setState(
                                () {
                                  currentTheme.switchCanvasColor(newValue);
                                  canvasColor = newValue;
                                },
                              );
                            }
                          },
                          items: <String>['Grey', 'Black']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        dense: true,
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.cardColor,
                        ),
                        onTap: () {},
                        trailing: DropdownButton(
                          value: cardColor,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                          underline: const SizedBox(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              switchToCustomTheme();
                              setState(
                                () {
                                  currentTheme.switchCardColor(newValue);
                                  cardColor = newValue;
                                },
                              );
                            }
                          },
                          items: <String>[
                            'Grey800',
                            'Grey850',
                            'Grey900',
                            'Black'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        dense: true,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.currentTheme,
                  ),
                  trailing: DropdownButton(
                    value: theme,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    underline: const SizedBox(),
                    onChanged: (String? themeChoice) {
                      if (themeChoice != null) {
                        const deflt = 'Default';

                        currentTheme.setInitialTheme(themeChoice);

                        setState(
                          () {
                            theme = themeChoice;
                            if (themeChoice == 'Custom') return;
                            final selectedTheme = userThemes[themeChoice];

                            settingsBox.put(
                              'backGrad',
                              themeChoice == deflt
                                  ? 2
                                  : selectedTheme['backGrad'],
                            );
                            currentTheme.backGrad = themeChoice == deflt
                                ? 2
                                : selectedTheme['backGrad'] as int;

                            settingsBox.put(
                              'cardGrad',
                              themeChoice == deflt
                                  ? 4
                                  : selectedTheme['cardGrad'],
                            );
                            currentTheme.cardGrad = themeChoice == deflt
                                ? 4
                                : selectedTheme['cardGrad'] as int;

                            settingsBox.put(
                              'bottomGrad',
                              themeChoice == deflt
                                  ? 3
                                  : selectedTheme['bottomGrad'],
                            );
                            currentTheme.bottomGrad = themeChoice == deflt
                                ? 3
                                : selectedTheme['bottomGrad'] as int;

                            currentTheme.switchCanvasColor(
                              themeChoice == deflt
                                  ? 'Grey'
                                  : selectedTheme['canvasColor'] as String,
                              notify: false,
                            );
                            canvasColor = themeChoice == deflt
                                ? 'Grey'
                                : selectedTheme['canvasColor'] as String;

                            currentTheme.switchCardColor(
                              themeChoice == deflt
                                  ? 'Grey900'
                                  : selectedTheme['cardColor'] as String,
                              notify: false,
                            );
                            cardColor = themeChoice == deflt
                                ? 'Grey900'
                                : selectedTheme['cardColor'] as String;

                            themeColor = themeChoice == deflt
                                ? 'Indigo'
                                : selectedTheme['accentColor'] as String;
                            colorHue = themeChoice == deflt
                                ? 400
                                : selectedTheme['colorHue'] as int;

                            currentTheme.switchColor(
                              themeColor,
                              colorHue,
                              notify: false,
                            );
                            currentTheme.switchFont(
                              appFont,
                              notify: false,
                            );

                            currentTheme.switchTheme(
                              useSystemTheme: !(themeChoice == deflt) &&
                                  selectedTheme['useSystemTheme'] as bool,
                              isDark: themeChoice == deflt ||
                                  selectedTheme['isDark'] as bool,
                            );
                          },
                        );
                      }
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return userThemesList.map<Widget>((String item) {
                        return Text(item);
                      }).toList();
                    },
                    items: userThemesList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (value != 'Default' && value != 'Custom')
                              Flexible(
                                child: IconButton(
                                  //padding: EdgeInsets.zero,
                                  iconSize: 18,
                                  splashRadius: 18,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.0,
                                          ),
                                        ),
                                        title: Text(
                                          AppLocalizations.of(context)!
                                              .deleteTheme,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                        // content: Text(
                                        //   '${AppLocalizations.of(
                                        //     context,
                                        //   )!.deleteThemeSubtitle} $value?',
                                        // ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                Navigator.of(context).pop,
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .cancel,
                                            ),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context)
                                                          .colorScheme
                                                          .secondary ==
                                                      Colors.white
                                                  ? Colors.black
                                                  : null,
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                            ),
                                            onPressed: () {
                                              currentTheme.deleteTheme(value);
                                              if (currentTheme
                                                      .getInitialTheme() ==
                                                  value) {
                                                currentTheme.setInitialTheme(
                                                  'Custom',
                                                );
                                                theme = 'Custom';
                                              }
                                              setState(
                                                () {
                                                  userThemes =
                                                      currentTheme.getThemes();
                                                },
                                              );
                                              ShowSnackBar().showSnackBar(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .themeDeleted,
                                              );
                                              return Navigator.of(
                                                context,
                                              ).pop();
                                            },
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .delete,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  tooltip: AppLocalizations.of(context)!.delete,
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                  ),
                                ),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                    isDense: true,
                  ),
                  dense: true,
                ),
                Visibility(
                  visible: theme == 'Custom',
                  child: ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.saveTheme,
                    ),
                    onTap: () {
                      final initialThemeName = 'Theme ${userThemes.length + 1}';
                      showTextInputDialog(
                        context: context,
                        title: AppLocalizations.of(context)!.enterThemeName,
                        onSubmitted: (value) {
                          if (value == '') return;
                          currentTheme.saveTheme(value);
                          currentTheme.setInitialTheme(value);
                          setState(
                            () {
                              userThemes = currentTheme.getThemes();
                              theme = value;
                            },
                          );
                          ShowSnackBar().showSnackBar(
                            context,
                            AppLocalizations.of(context)!.themeSaved,
                          );
                          Navigator.of(context).pop();
                        },
                        keyboardType: TextInputType.text,
                        initialText: initialThemeName,
                      );
                    },
                    dense: true,
                  ),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(
          //     10.0,
          //     10.0,
          //     10.0,
          //     10.0,
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Padding(
          //         padding: const EdgeInsets.fromLTRB(
          //           15,
          //           15,
          //           15,
          //           0,
          //         ),
          //         child: Text(
          //           'User Interface',
          //           style: TextStyle(
          //             fontSize: 22,
          //             fontWeight: FontWeight.bold,
          //             color: Theme.of(context).colorScheme.secondary,
          //           ),
          //         ),
          //       ),

          //       // Lyrics font
          //       ListTile(
          //         title: const Text('App Font'),
          //         subtitle: Text(appFont),
          //         // onTap: () {},
          //         trailing: DropdownButton(
          //           value: appFont,
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Theme.of(context).textTheme.bodyLarge!.color,
          //           ),
          //           underline: const SizedBox(),
          //           onChanged: (String? newValue) {
          //             if (newValue != null) {
          //               currentTheme.switchFont(appFont);
          //               setState(
          //                 () {
          //                   appFont = newValue;
          //                   // settingsBox.put('appFont', newValue);

          //                   Hive.box('settings').put('appFont', newValue);
          //                 },
          //               );
          //               setState(() {});
          //             }
          //           },
          //           items: <String>[
          //             'DeliciousHandrawn',
          //             'Oswald',
          //             'Gotham',
          //              'Alva',
          //           ].map<DropdownMenuItem<String>>((String value) {
          //             return DropdownMenuItem<String>(
          //               value: value,
          //               child: Text(
          //                 value,
          //               ),
          //             );
          //           }).toList(),
          //         ),

          //         onTap: () {},
          //         dense: true,
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              10.0,
              10.0,
              10.0,
              10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    15,
                    15,
                    15,
                    0,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.others,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.lang,
                  ),
                  onTap: () {},
                  trailing: DropdownButton(
                    value: lang,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    underline: const SizedBox(),
                    onChanged: (String? newValue) {
                      final Map<String, String> codes = {
                        'Arabic': 'ar',
                        'Chinese': 'zh',
                        'Czech': 'cs',
                        'Dutch': 'nl',
                        'English': 'en',
                        'French': 'fr',
                        'German': 'de',
                        'Hebrew': 'he',
                        'Hindi': 'hi',
                        'Indonesian': 'id',
                        'Portuguese': 'pt',
                        'Russian': 'ru',
                        'Spanish': 'es',
                        'Tamil': 'ta',
                        'Turkish': 'tr',
                        'Ukrainian': 'uk',
                        'Urdu': 'ur',
                      };
                      if (newValue != null) {
                        setState(
                          () {
                            lang = newValue;
                            MyApp.of(context).setLocale(
                              Locale.fromSubtags(
                                languageCode: codes[newValue]!,
                              ),
                            );
                            Hive.box('settings').put('lang', newValue);
                          },
                        );
                      }
                    },
                    items: <String>[
                      'Arabic',
                      'Chinese',
                      'Czech',
                      'Dutch',
                      'English',
                      'French',
                      'German',
                      'Hebrew',
                      'Hindi',
                      'Indonesian',
                      'Portuguese',
                      'Russian',
                      'Spanish',
                      'Tamil',
                      'Turkish',
                      'Ukrainian',
                      'Urdu',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                        ),
                      );
                    }).toList(),
                  ),
                  dense: true,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.createBack,
                  ),
                  dense: true,
                  onTap: () {
                    showModalBottomSheet(
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (BuildContext context) {
                        // final List playlistNames = Hive.box('settings').get(
                        //   'playlistNames',
                        //   defaultValue: ['Favorite Songs'],
                        // ) as List;
                        // if (!playlistNames.contains('Favorite Songs')) {
                        //   playlistNames.insert(0, 'Favorite Songs');
                        //   settingsBox.put(
                        //     'playlistNames',
                        //     playlistNames,
                        //   );
                        // }

                        final List<String> persist = [
                          AppLocalizations.of(context)!.settings,
                          // AppLocalizations.of(
                          //   context,
                          // )!
                          //     .playlists,
                        ];

                        final List<String> checked = [
                          AppLocalizations.of(context)!.settings,
                          AppLocalizations.of(context)!.imageHistory,
                        ];

                        final List<String> items = [
                          AppLocalizations.of(context)!.settings,
                          AppLocalizations.of(context)!.imageHistory,
                          AppLocalizations.of(context)!.cache,
                        ];

                        final Map<String, List> boxNames = {
                          AppLocalizations.of(context)!.settings: ['settings'],
                          AppLocalizations.of(context)!.imageHistory: [
                            'imageHistory'
                          ],
                          AppLocalizations.of(context)!.cache: ['cache'],
                        };
                        return StatefulBuilder(
                          builder: (
                            BuildContext context,
                            StateSetter setStt,
                          ) {
                            return BottomGradientContainer(
                              borderRadius: BorderRadius.circular(
                                20.0,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        10,
                                      ),
                                      itemCount: items.length,
                                      itemBuilder: (context, idx) {
                                        return CheckboxListTile(
                                          activeColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          checkColor: Theme.of(context)
                                                      .colorScheme
                                                      .secondary ==
                                                  Colors.white
                                              ? Colors.black
                                              : null,
                                          value: checked.contains(
                                            items[idx],
                                          ),
                                          title: Text(
                                            items[idx],
                                          ),
                                          onChanged:
                                              persist.contains(items[idx])
                                                  ? null
                                                  : (bool? value) {
                                                      value!
                                                          ? checked.add(
                                                              items[idx],
                                                            )
                                                          : checked.remove(
                                                              items[idx],
                                                            );
                                                      setStt(
                                                        () {},
                                                      );
                                                    },
                                        );
                                      },
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.cancel,
                                        ),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        onPressed: () {
                                          createBackup(
                                            context,
                                            checked,
                                            boxNames,
                                          );
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!.ok,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.restore,
                  ),
                  dense: true,
                  onTap: () async {
                    await restore(context);
                    currentTheme.refresh();
                  },
                ),
                BoxSwitchTile(
                  title: Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .autoBack,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .autoBackSub,
                  ),
                  keyName: 'autoBackup',
                  defaultValue: false,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .autoBackLocation,
                  ),
                  subtitle: Text(autoBackPath),
                  trailing: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey[700],
                    ),
                    onPressed: () async {
                      autoBackPath = await ExtStorageProvider.getExtStorage(
                            dirName: 'Imagen/Backups',
                          ) ??
                          '/storage/emulated/0/Imagen/Backups';
                      Hive.box('settings').put('autoBackPath', autoBackPath);
                      setState(
                        () {},
                      );
                    },
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!
                          .reset,
                    ),
                  ),
                  onTap: () async {
                    final String temp = await Picker.selectFolder(
                      context: context,
                      message: AppLocalizations.of(
                        context,
                      )!
                          .autoBackLocation,
                    );
                    if (temp.trim() != '') {
                      autoBackPath = temp;
                      Hive.box('settings').put('autoBackPath', temp);
                      setState(
                        () {},
                      );
                    } else {
                      ShowSnackBar().showSnackBar(
                        context,
                        AppLocalizations.of(
                          context,
                        )!
                            .noFolderSelected,
                      );
                    }
                  },
                  dense: true,
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.clearCache,
                  ),
                  subtitle: const Text(""),
                  trailing: SizedBox(
                    height: 70.0,
                    width: 70.0,
                    child: Center(
                      child: FutureBuilder(
                        future: File(Hive.box('cache').path!).length(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<int> snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Text(
                              '${((snapshot.data ?? 0) / (1024 * 1024)).toStringAsFixed(2)} MB',
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  dense: true,
                  isThreeLine: true,
                  onTap: () async {
                    Hive.box('cache').clear();
                    setState(
                      () {},
                    );
                  },
                ),
                ListTile(
                  title: Text(
                    AppLocalizations.of(context)!.deleteAccount,
                    style: const TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(""),
                  dense: true,
                  onTap: () {
                    _showDeleteAccountConfirmationDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// void _navigateToReAuthScreen(BuildContext context) {
//   Navigator.push(
//     context,
//     MaterialPageRoute(builder: (context) => ReAuthScreen()),
//   ).then((reauthSuccess) {
//     if (reauthSuccess == true) {
//       _deleteAccount(context);
//     }
//   });
// }
