import 'dart:io';

import 'package:cab_driver/screens/mainpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      name: 'db2',
      options: Platform.isIOS || Platform.isMacOS
          ? FirebaseOptions(
              appId: '1:501444260125:ios:87f317c7447d36951671f4',
              apiKey: 'AIzaSyCScnflnC1gRe7saghj8WbaAbi9cWpkJ0E',
              projectId: 'uber-clone-afa6a',
              messagingSenderId: '501444260125',
              databaseURL:
                  'https://uber-clone-afa6a-default-rtdb.asia-southeast1.firebasedatabase.app',
            )
          : FirebaseOptions(
              appId: '1:501444260125:android:df7856f9cd0d25861671f4',
              apiKey: 'AIzaSyArFilpAuSqF_Le1bR8qMsNEw0STjNIVXg',
              messagingSenderId: '501444260125',
              projectId: 'uber-clone-afa6a',
              databaseURL:
                  'https://uber-clone-afa6a-default-rtdb.asia-southeast1.firebasedatabase.app',
            ),
    );
  } catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: MainPage.id,
      routes: {
        MainPage.id: (context) => MainPage(),
      },
    );
  }
}
