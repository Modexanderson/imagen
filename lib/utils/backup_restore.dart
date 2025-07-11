// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/snack_bar.dart';
import 'picker.dart';

Future<void> createBackup(
  BuildContext context,
  List items,
  Map<String, List> boxNameData, {
  String? path,
  String? fileName,
  bool showDialog = true,
}) async {
  if (!Platform.isWindows) {
    PermissionStatus status = await Permission.storage.status;
    if (status.isDenied) {
      await [
        Permission.storage,
        Permission.accessMediaLocation,
        Permission.mediaLibrary,
      ].request();
    }
    status = await Permission.storage.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
  final String savePath = path ??
      await Picker.selectFolder(
        context: context,
        message: 'Select Backup Location',
      );
  if (savePath.trim() != '') {
    try {
      final saveDir = Directory(savePath);
      final List<File> files = [];
      final List boxNames = [];

      for (int i = 0; i < items.length; i++) {
        boxNames.addAll(boxNameData[items[i]]!);
      }

      for (int i = 0; i < boxNames.length; i++) {
        await Hive.openBox(boxNames[i].toString());
        try {
          await File(Hive.box(boxNames[i].toString()).path!)
              .copy('$savePath/${boxNames[i]}.hive');
        } catch (e) {
          await [
            Permission.manageExternalStorage,
          ].request();
          await File(Hive.box(boxNames[i].toString()).path!)
              .copy('$savePath/${boxNames[i]}.hive');
        }

        files.add(File('$savePath/${boxNames[i]}.hive'));
      }

      final now = DateTime.now();
      final String time =
          '${now.hour}${now.minute}_${now.day}${now.month}${now.year}';
      final zipFile =
          File('$savePath/${fileName ?? "Imagen_Backup_$time"}.zip');

      await ZipFile.createFromFiles(
        sourceDir: saveDir,
        files: files,
        zipFile: zipFile,
      );
      for (int i = 0; i < files.length; i++) {
        files[i].delete();
      }
      if (showDialog) {
        ShowSnackBar().showSnackBar(
          context,
          AppLocalizations.of(context)!.backupSuccess,
        );
      }
    } catch (e) {
      ShowSnackBar().showSnackBar(
        context,
        'Backup Failed \nError: $e',
      );
    }
  } else {
    ShowSnackBar().showSnackBar(
      context,
      AppLocalizations.of(context)!.noFolderSelected,
    );
  }
}

Future<void> restore(
  BuildContext context,
) async {
  final String savePath = await Picker.selectFile(
    context: context,
    ext: ['zip'],
    message: AppLocalizations.of(context)!.selectBackupFile,
  );
  final File zipFile = File(savePath);
  final Directory tempDir = await getTemporaryDirectory();
  final Directory destinationDir = Directory('${tempDir.path}/restore');

  try {
    await ZipFile.extractToDirectory(
      zipFile: zipFile,
      destinationDir: destinationDir,
    );
    final List<FileSystemEntity> files = await destinationDir.list().toList();

    for (int i = 0; i < files.length; i++) {
      final String backupPath = files[i].path;
      final String boxName = backupPath.split('/').last.replaceAll('.hive', '');
      final Box box = await Hive.openBox(boxName);
      final String boxPath = box.path!;
      await box.close();

      try {
        await File(backupPath).copy(boxPath);
      } finally {
        await Hive.openBox(boxName);
      }
    }
    destinationDir.delete(recursive: true);
    ShowSnackBar()
        .showSnackBar(context, AppLocalizations.of(context)!.importSuccessful);
  } catch (e) {
    ShowSnackBar().showSnackBar(
      context,
      '${AppLocalizations.of(context)!.importFailed}\n${AppLocalizations.of(context)!.error} $e',
    );
  }
}
