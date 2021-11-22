import 'package:cab_driver/screens/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

import 'dataprovider.dart';
import 'globalvariabels.dart';
import 'screens/login.dart';
import 'screens/mainpage.dart';
import 'screens/vehicleinfo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:501444260125:ios:87f317c7447d36951671f4',
            gcmSenderID: '501444260125',
            databaseURL:
                'https://uber-clone-afa6a-default-rtdb.asia-southeast1.firebasedatabase.app',
          )
        : const FirebaseOptions(
            googleAppID: '1:501444260125:android:df7856f9cd0d25861671f4',
            apiKey: 'AIzaSyArFilpAuSqF_Le1bR8qMsNEw0STjNIVXg',
            databaseURL:
                'https://uber-clone-afa6a-default-rtdb.asia-southeast1.firebasedatabase.app',
          ),
  );

  currentFirebaseUser = await FirebaseAuth.instance.currentUser();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute:
            (currentFirebaseUser == null) ? LoginPage.id : MainPage.id,
        routes: {
          MainPage.id: (context) => MainPage(),
          RegistrationPage.id: (context) => RegistrationPage(),
          VehicleInfoPage.id: (context) => VehicleInfoPage(),
          LoginPage.id: (context) => LoginPage(),
        },
      ),
    );
  }
}
