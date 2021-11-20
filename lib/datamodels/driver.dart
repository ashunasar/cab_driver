import 'package:firebase_database/firebase_database.dart';

class Driver {
  String fullName;
  String email;
  String phone;
  String id;
  String carModel;
  String carColor;
  String vehicalNumber;

  Driver(
      {this.fullName,
      this.email,
      this.phone,
      this.id,
      this.carModel,
      this.carColor,
      this.vehicalNumber});

  Driver.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullName'];
    carModel = snapshot.value['vehicle_details']['car_model'];
    carColor = snapshot.value['vehicle_details']['car_color'];
    vehicalNumber = snapshot.value['vehicle_details']['vehical_number'];
  }
}
