import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'datamodels/driver.dart';

FirebaseUser currentFirebaseUser;

// final CameraPosition googlePlex = CameraPosition(
//   target: LatLng(37.42796133580664, -122.085749655962),
//   zoom: 14.4746,
// );
final CameraPosition googlePlex = CameraPosition(
  target: LatLng(28.61456886375804, 77.21106869546504),
  zoom: 14.4746,
);

// String mapKey = 'AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs';

String mapKey = "AIzaSyArFilpAuSqF_Le1bR8qMsNEw0STjNIVXg";

StreamSubscription<Position> homeTabPositionStream;

StreamSubscription<Position> ridePositionStream;

final assetsAudioPlayer = AssetsAudioPlayer();

Position currentPosition;

DatabaseReference rideRef;

Driver currentDriverInfo;
