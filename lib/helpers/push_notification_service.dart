import 'dart:io';

// import 'package:audioplayers/audioplayers.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cab_driver/datamodels/trip_details.dart';
import 'package:cab_driver/widgets/notification_dialog.dart';
import 'package:cab_driver/widgets/progress_diolog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

import '../globalvariables.dart';

class PushNotificationService {
  final FirebaseMessaging fcm = FirebaseMessaging();

  Future initialize(BuildContext context) async {
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        fetchRideInfo(getRideId(message), context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        fetchRideInfo(getRideId(message), context);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        fetchRideInfo(getRideId(message), context);
      },
    );
  }

  Future<String> getToken() async {
    String token = await fcm.getToken();

    print("Token : $token");

    DatabaseReference tokenRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('alldrivers');
    fcm.subscribeToTopic('allusers');
  }

  String getRideId(Map<String, dynamic> message) {
    String rideId;
    if (Platform.isAndroid) {
      rideId = message['data']['ride_id'];
    } else {
      rideId = message['ride_id'];
    }
    return rideId;
  }

  void fetchRideInfo(String rideId, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              status: "Fetching details...",
            ));

    DatabaseReference rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');

    rideRef.once().then((DataSnapshot snapshot) async {
      Navigator.pop(context);

      assetsAudioPlayer.open(Audio('sounds/alert.mp3'));
      assetsAudioPlayer.play();
      // AudioPlayer audioPlayer = AudioPlayer();
      // await audioPlayer.play('sounds/alert.mp3', isLocal: true);

      if (snapshot.value != null) {
        double pickupLat =
            double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng =
            double.parse(snapshot.value['location']['longitude'].toString());

        String pickupAddress = snapshot.value['pickup_address'].toString();

        double destinationLat =
            double.parse(snapshot.value['destination']['latitude'].toString());

        double destinationLng =
            double.parse(snapshot.value['destination']['longitude'].toString());

        String destinationAddress =
            snapshot.value['destination_address'].toString();

        String paymentMethod = snapshot.value['payment_method'];

        String riderName = snapshot.value['rider_name'];
        String riderPhone = snapshot.value['rider_phone'];

        // Logger().e(pickupAddress);
        print(pickupAddress);

        TripDetails tripDetails = TripDetails();
        tripDetails.rideId = rideId;
        tripDetails.pickupAddress = pickupAddress;
        tripDetails.destinationAddress = destinationAddress;
        tripDetails.pickup = LatLng(pickupLat, pickupLng);
        tripDetails.destination = LatLng(destinationLat, destinationLng);
        tripDetails.paymentMethod = paymentMethod;
        tripDetails.riderName = riderName;
        tripDetails.riderPhone = riderPhone;

        showDialog(
            context: context,
            builder: (BuildContext context) => NotificationDialog(
                  tripDetails: tripDetails,
                ));
      }
    });
  }
}
