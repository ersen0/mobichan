import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobichan/constants.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static bool isLocalFilePath(String path) {
    Uri uri = Uri.parse(path);
    return !uri.scheme.contains('http');
  }

  static Future<bool?> saveImage(String path, {String? albumName}) async {
    MethodChannel channel = const MethodChannel('gallery_saver');
    File? tempFile;
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path);
      path = tempFile.path;
    }

    bool? result = await channel.invokeMethod(
      'saveImage',
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }

    return result;
  }

  static Future<File> _downloadFile(String url) async {
    http.Client _client = http.Client();
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    String dir = (await getTemporaryDirectory()).path;
    File file = File('$dir/${basename(url)}');
    await file.writeAsBytes(bytes);
    return file;
  }

  static SnackBar buildSnackBar(
      BuildContext context, String text, Color color) {
    return SnackBar(
      backgroundColor: color,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      content: Text(
        text,
        style: snackbarTextStyle(context),
      ),
    );
  }
}
