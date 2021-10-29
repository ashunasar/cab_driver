import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/datamodels/trip_details.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/screens/new_trip_page.dart';
import 'package:cab_driver/widgets/brand_divider.dart';
import 'package:cab_driver/widgets/progress_diolog.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class NotificationDialog extends StatelessWidget {
  final TripDetails tripDetails;

  NotificationDialog({this.tripDetails});

  void checkAvailability(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Accepting Request...'),
    );

    DatabaseReference newRideRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/newtrip');

    newRideRef.once().then((DataSnapshot snapshot) {
      Navigator.pop(context);
      Navigator.pop(context);
      String thisRideId = "";
      if (snapshot.value != null) {
        thisRideId = snapshot.value.toString();
      } else {
        Toast.show("Ride not found", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }

      if (thisRideId == tripDetails.rideId) {
        newRideRef.set('accepted');

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewTripPage(
                      tripDetails: tripDetails,
                    )));
      } else if (thisRideId == 'cancelled') {
        Toast.show("Ride has been cancelled", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else if (thisRideId == 'timeout') {
        Toast.show("Ride has timed out", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      } else {
        Toast.show("Ride not found", context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            Image.asset('images/taxi.png', width: 100),
            SizedBox(height: 16),
            Text(
              "New Trip Request",
              style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.pickupAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: Container(
                          child: Text(
                            tripDetails.destinationAddress,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            BrandDivider(),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                          title: 'DECLINE',
                          color: BrandColors.colorPrimary,
                          onPressed: () async {
                            assetsAudioPlayer.stop();
                            Navigator.pop(context);
                          }),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      child: TaxiButton(
                          title: 'ACCEPT',
                          color: BrandColors.colorGreen,
                          onPressed: () async {
                            assetsAudioPlayer.stop();
                            checkAvailability(context);
                          }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
