
import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

class ShareFiles {

  static const MethodChannel _channel = MethodChannel('fr.enlight/share_files');

  /// Summons the platform's share sheet to share multiple files.
  ///
  /// Wraps the platform's native share dialog. Can share a file.
  /// It uses the `ACTION_SEND` Intent on Android and `UIActivityViewController`
  /// on iOS.
  ///
  /// The optional `mimeTypes` parameter can be used to specify MIME types for
  /// the provided files.
  ///
  /// Android supports all natively available MIME types (wildcards like image/*
  /// are also supported) and it's considered best practice to avoid mixing
  /// unrelated file types (eg. image/jpg & application/pdf). If MIME types are
  /// mixed the plugin attempts to find the lowest common denominator. Even
  /// if MIME types are supplied the receiving app decides if those are used
  /// or handled.
  ///
  /// On iOS image/jpg, image/jpeg and image/png are handled as images, while
  /// every other MIME type is considered a normal file.
  ///
  /// The optional `sharePositionOrigin` parameter can be used to specify a global
  /// origin rect for the share sheet to popover from on iPads. It has no effect
  /// on non-iPads.
  ///
  /// from [MethodChannel].
  static Future<void> shareFiles(
      List<String> paths, {
        List<String>? mimeTypes,
        String? subject,
        String? text,
        String? phoneNumber,
        String? email,
        Rect? sharePositionOrigin,
      }) {
    assert(paths.isNotEmpty);
    assert(paths.every((element) => element.isNotEmpty));
    final params = <String, dynamic>{
      'paths': paths,
      'mimeTypes': mimeTypes ??
          paths.map((String path) => _mimeTypeForPath(path)).toList(),
    };

    if (subject != null) params['subject'] = subject;
    if (text != null) params['text'] = text;
    if (email != null) params['email'] = email;
    if (phoneNumber != null) params['phoneNumber'] = phoneNumber;

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return _channel.invokeMethod('shareFiles', params);
  }

  static String _mimeTypeForPath(String path) {
    return lookupMimeType(path) ?? 'application/octet-stream';
  }
}

