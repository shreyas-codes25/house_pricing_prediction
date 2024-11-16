import 'package:flutter/material.dart';
import 'package:house_pricing_prediction/prediction-screen.dart';

void main() {
  runApp(const HousingApp());
}

class HousingApp extends StatelessWidget {
  const HousingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PredictionInputScreen(),
    );
  }
}
