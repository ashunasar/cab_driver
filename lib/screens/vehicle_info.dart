import 'package:cab_driver/brand_colors.dart';
import 'package:cab_driver/globalvariables.dart';
import 'package:cab_driver/screens/mainpage.dart';
import 'package:cab_driver/widgets/taxi_button.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class VehicleInfo extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  void showSnackBar(String title) {
    final snackbar = SnackBar(
        content: Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15),
    ));
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  static const id = "vehicleinfo";

  TextEditingController carModelController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController vehicalNumberController = TextEditingController();

  void updateProfile(BuildContext context) {
    String id = currentFirebaseUser.uid;

    DatabaseReference driverRef = FirebaseDatabase.instance
        .reference()
        .child('drivers/$id/vehicle_details');

    Map map = {
      'car_color': carColorController.text,
      'car_model': carModelController.text,
      'vehicle_number': vehicalNumberController.text,
    };

    driverRef.set(map);

    Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Image.asset('images/logo.png', height: 110, width: 110),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 20, 30, 30),
              child: Column(
                children: [
                  Text("Enter Vehicle Details",
                      style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 22)),
                  SizedBox(height: 25),
                  TextField(
                    controller: carModelController,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Car Model',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: carColorController,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Car Color',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    maxLength: 11,
                    controller: vehicalNumberController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: 'Vehical Number',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TaxiButton(
                    title: 'PROCEED',
                    color: BrandColors.colorGreen,
                    onPressed: () {
                      if (carModelController.text.length < 3) {
                        showSnackBar('Please Provide a valid car model');
                        return;
                      }

                      if (carColorController.text.length < 3) {
                        showSnackBar('Please Provide a valid car Color');
                        return;
                      }
                      if (vehicalNumberController.text.length < 3) {
                        showSnackBar('Please Provide a valid vehicle Number');
                        return;
                      }

                      updateProfile(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
