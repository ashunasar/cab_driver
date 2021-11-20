import 'dart:io';

import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/datamodels/trip_details.dart';
import 'package:cab_driver/helpers/helper_methods.dart';
import 'package:cab_driver/helpers/map_kit_helper.dart';
import 'package:cab_driver/widgets/collect_paymet_dialog.dart';
import 'package:cab_driver/widgets/progress_diolog.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../globalvariables.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetails;
  NewTripPage({@required this.tripDetails});

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  GoogleMapController rideMapController;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = new Set<Marker>();
  Set<Circle> _circles = new Set<Circle>();
  Set<Polyline> _polyLine = new Set<Polyline>();

  List<LatLng> polyLineCordinates = [];

  PolylinePoints polyLinePoints = PolylinePoints();

  Future<void> getDirection(
      LatLng pickUpLatLng, LatLng destinationLatLng) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) =>
            ProgressDialog(status: 'Please wait...'));
    var thisDetails = await HelperMethods.getDirectionDetails(
        pickUpLatLng, destinationLatLng);

    Navigator.pop(context);
    print(thisDetails.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();

    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polyLineCordinates.clear();
    if (results.isNotEmpty) {
      results.forEach((PointLatLng points) {
        polyLineCordinates.add(LatLng(points.latitude, points.longitude));
      });
    }
    _polyLine.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyId'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polyLineCordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polyLine.add(polyline);
    });
// ignore:
    LatLngBounds bounds;

    if (pickUpLatLng.latitude > destinationLatLng.latitude &&
        pickUpLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: destinationLatLng,
        northeast: pickUpLatLng,
      );
    } else if (pickUpLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickUpLatLng.longitude),
          northeast:
              LatLng(pickUpLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds = LatLngBounds(
        southwest: pickUpLatLng,
        northeast: destinationLatLng,
      );
    }

    rideMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickUpMarker = Marker(
      markerId: MarkerId("pickup"),
      position: pickUpLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId("destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickUpMarker);
      _markers.add(destinationMarker);
    });

    Circle pickUpCircle = Circle(
      circleId: CircleId('pickUp'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickUpLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickUpCircle);
      _circles.add(destinationCircle);
    });
  }

  @override
  void initState() {
    super.initState();
    acceptTrip();
  }

  void acceptTrip() {
    String rideId = widget.tripDetails.rideId;

    rideRef =
        FirebaseDatabase.instance.reference().child('rideRequest/$rideId');
    rideRef.child('status').set('accepted');
    rideRef.child('driver_name').set(currentDriverInfo.fullName);
    rideRef
        .child('car_details')
        .set("${currentDriverInfo.carColor} - ${currentDriverInfo.carModel}");

    rideRef.child('driver_phone').set(currentDriverInfo.phone);
    rideRef.child('driver_id').set(currentDriverInfo.id);

    Map locationMap = {
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
    };

    rideRef.child('driver_location').set(locationMap);

    DatabaseReference historyRef = FirebaseDatabase.instance
        .reference()
        .child('driver/${currentFirebaseUser.uid}/history/$rideId');

    historyRef.set(true);
  }

  double mapPaddingBottom = 0;

  var locationOptions = LocationOptions(
    accuracy: LocationAccuracy.bestForNavigation,
  );

  BitmapDescriptor movingMarkerIcon;

  void createMarker() {
    if (movingMarkerIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));

      BitmapDescriptor.fromAssetImage(imageConfiguration,
              Platform.isIOS ? 'images/car_ios.png' : 'images/car_android.png')
          .then((icon) {
        movingMarkerIcon = icon;
      });
    }
  }

  Position myPosition;
  void getLocationUpdates() {
    LatLng oldPosition = LatLng(0, 0);

    ridePositionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    ).listen((Position position) {
      myPosition = position;
      currentPosition = position;

      LatLng pos = LatLng(position.latitude, position.longitude);
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude,
          oldPosition.longitude, pos.latitude, pos.longitude);
      Marker movingMarker = Marker(
        markerId: MarkerId('moving'),
        position: pos,
        icon: movingMarkerIcon,
        rotation: rotation,
        infoWindow: InfoWindow(title: 'current Location'),
      );

      setState(() {
        CameraPosition cp = CameraPosition(target: pos, zoom: 17);
        rideMapController.animateCamera(CameraUpdate.newCameraPosition(cp));

        _markers
            .removeWhere((Marker marker) => marker.markerId.value == "moving");

        _markers.add(movingMarker);
      });

      oldPosition = pos;

      updateTripDetails();

      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longituede': myPosition.longitude.toString(),
      };

      rideRef.child('driver_location').set(locationMap);
    });
  }

  String status = 'accepted';
  String durationString = '';

  bool isRequestingDirection = false;
  void updateTripDetails() async {
    if (!isRequestingDirection) {
      isRequestingDirection = true;
      if (myPosition = null) {
        return;
      }

      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);

      LatLng destinationLatLng;

      if (status == "accepted") {
        destinationLatLng = widget.tripDetails.pickup;
      } else {
        destinationLatLng = widget.tripDetails.destination;
      }

      var directionDetails = await HelperMethods.getDirectionDetails(
          positionLatLng, destinationLatLng);

      if (directionDetails != null) {
        setState(() {
          durationString = directionDetails.distanceText;
        });
      }

      isRequestingDirection = false;
    }
  }

  Timer timer;
  int durationCounter = 0;

  void sartTimer() {
    const interval = Duration(seconds: 1);

    timer = Timer.periodic(interval, (timer) {
      durationCounter++;
    });
  }

  void endTrip() async {
    timer.cancel();

    HelperMethods.showProgressDialog(context);

    var currentLatLng = LatLng(myPosition.latitude, myPosition.longitude);
    var directionDetails = await HelperMethods.getDirectionDetails(
        widget.tripDetails.pickup, currentLatLng);

    Navigator.pop(context);
    int fares = HelperMethods.estimateFares(directionDetails, durationCounter);

    rideRef.child('fares').set(fares.toString());

    rideRef.child('status').set('ended');

    ridePositionStream.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CollectPayment(
        paymentMethod: widget.tripDetails.paymentMethod,
        fares: fares,
      ),
    );

    topUpEarnings(fares);
  }

  void topUpEarnings(int fares) {
    DatabaseReference earningsRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/${currentFirebaseUser.uid}/earnings');

    earningsRef.once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        double oldEarnnings = double.parse(snapshot.value.toString());

        double adjustedEarnnings = (fares.toDouble() * 0.85) + oldEarnnings;

        earningsRef.set(adjustedEarnnings.toStringAsFixed(2));
      } else {
        double adjustedEarnnings = (fares.toDouble() * 0.85);

        earningsRef.set(adjustedEarnnings.toStringAsFixed(2));
      }
    });
  }

  String buttonTitle = "ARRIVED";
  Color buttonColor = BrandColors.colorGreen;
  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingBottom),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            mapType: MapType.normal,
            circles: _circles,
            markers: _markers,
            polylines: _polyLine,
            initialCameraPosition: googlePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              rideMapController = controller;

              setState(() {
                mapPaddingBottom = Platform.isIOS ? 255 : 260;
              });
              var currentLatLng =
                  LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.tripDetails.pickup;
              await getDirection(currentLatLng, pickupLatLng);

              getLocationUpdates();
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              height: Platform.isIOS ? 280 : 255,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "14 Mins",
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Brand-Bold',
                        color: BrandColors.colorAccentPurple,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.tripDetails.riderName,
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Brand-Bold',
                            color: BrandColors.colorAccentPurple,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.call),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Row(
                      children: [
                        Image.asset('images/pickicon.png',
                            height: 16, width: 16),
                        SizedBox(width: 18),
                        Expanded(
                          child: Container(
                              child: Text(
                            widget.tripDetails.pickupAddress,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Image.asset('images/desticon.png',
                            height: 16, width: 16),
                        SizedBox(width: 18),
                        Expanded(
                          child: Container(
                              child: Text(
                            widget.tripDetails.destinationAddress,
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    TaxiButton(
                        title: buttonTitle,
                        color: buttonColor,
                        onPressed: () async {
                          if (status == 'accepted') {
                            status = 'arrived';
                            rideRef.child('status').set('arrived');

                            setState(() {
                              buttonTitle = 'START TRIP';
                              buttonColor = BrandColors.colorAccentPurple;
                            });

                            HelperMethods.showProgressDialog(context);
                            await getDirection(widget.tripDetails.pickup,
                                widget.tripDetails.destination);
                            Navigator.pop(context);
                          } else if (status == 'arrived') {
                            status = 'ontrip';
                            rideRef.child('status').set(status);
                            setState(() {
                              buttonTitle = 'END TRIP';
                              buttonColor = Colors.red[900];
                            });
                            sartTimer();
                          } else if (status == 'ontrip') {
                            endTrip();
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
