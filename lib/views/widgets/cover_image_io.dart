import 'dart:io';
import 'package:flutter/painting.dart';

ImageProvider? localCoverImage(String path) => FileImage(File(path));
