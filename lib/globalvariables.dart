import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String mapKey = "AIzaSyArFilpAuSqF_Le1bR8qMsNEw0STjNIVXg";

User currentFirebaseUser;

final CameraPosition googlePlex = CameraPosition(
  target: LatLng(28.61456886375804, 77.21106869546504),
  zoom: 14.4746,
);

Position currentPosition;

DatabaseReference tripRequestRef;

StreamSubscription<Position> homeTabPositionStream;

final assetsAudioPlayer = AssetsAudioPlayer();
