import 'package:cab_driver/datamodels/trip_details.dart';
import 'package:flutter/material.dart';

class NewTripPage extends StatefulWidget {
  final TripDetails tripDetails;
  NewTripPage({@required this.tripDetails});

  @override
  _NewTripPageState createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("NewTripPage")),
    );
  }
}
