import 'dart:io';

import 'package:flutter/cupertino.dart';

bool isGalleryNetworkImage(String value) {
  return value.startsWith('http://') || value.startsWith('https://');
}

ImageProvider resolveGalleryImageProvider(String value) {
  if (isGalleryNetworkImage(value)) {
    return NetworkImage(value);
  }
  return FileImage(File(value));
}
