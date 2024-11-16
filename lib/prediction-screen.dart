import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prediction_result.dart';

class PredictionInputScreen extends StatefulWidget {
  const PredictionInputScreen({Key? key}) : super(key: key);

  @override
  _PredictionInputScreenState createState() => _PredictionInputScreenState();
}

class _PredictionInputScreenState extends State<PredictionInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _storiesController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();
  final TextEditingController _loan = TextEditingController();
  final TextEditingController _tenure = TextEditingController();
  final TextEditingController _interest = TextEditingController();

  // Boolean inputs
  bool _mainRoad = false;
  bool _guestRoom = false;
  bool _basement = false;
  bool _hotWaterHeating = false;
  bool _airConditioning = false;
  bool _prefArea = false;

  // Dropdown for furnishing status
  String _furnishingStatus = 'Semi-furnished';
  final List<String> _furnishingOptions = [
    'Semi-furnished',
    'Unfurnished',
    'Furnished'
  ];

  Future<void> _predictPrice(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    // Prepare input data
    final inputData = {
      'area': double.parse(_areaController.text),
      'bedrooms': int.parse(_bedroomsController.text),
      'bathrooms': int.parse(_bathroomsController.text),
      'stories': int.parse(_storiesController.text),
      'mainroad_yes': _mainRoad ? 1 : 0,
      'guestroom_yes': _guestRoom ? 1 : 0,
      'basement_yes': _basement ? 1 : 0,
      'hotwaterheating_yes': _hotWaterHeating ? 1 : 0,
      'airconditioning_yes': _airConditioning ? 1 : 0,
      'parking': int.parse(_parkingController.text),
      'prefarea_yes': _prefArea ? 1 : 0,
      'furnishingstatus_Semi-furnished':
          _furnishingStatus == 'Semi-furnished' ? 1 : 0,
      'furnishingstatus_Unfurnished':
          _furnishingStatus == 'Unfurnished' ? 1 : 0,
      'loan_amount': int.parse(_loan.text),
      'tenure': int.parse(_tenure.text),
      'interest_rate': double.parse(_interest.text),
    };

    // Send the data to the Flask API
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inputData),
      );

      if (response.statusCode == 200) {
        final prediction = jsonDecode(response.body)['predicted_price'];

        // Navigate to result screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PredictionResultScreen(
              predictedPrice: prediction,
              details: inputData,
            ),
          ),
        );
      } else {
        throw Exception("Failed to predict price");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Housing Price Predictor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(_areaController, "Area (sq. ft.)", deviceWidth),
                _buildTextField(_bedroomsController, "Bedrooms", deviceWidth),
                _buildTextField(_bathroomsController, "Bathrooms", deviceWidth),
                _buildTextField(_storiesController, "Stories", deviceWidth),
                _buildTextField(
                    _parkingController, "Parking Spaces", deviceWidth),
                _buildSwitch("Located on Main Road?", _mainRoad, (value) {
                  setState(() => _mainRoad = value);
                }),
                _buildSwitch("Guest Room Available?", _guestRoom, (value) {
                  setState(() => _guestRoom = value);
                }),
                _buildSwitch("Has Basement?", _basement, (value) {
                  setState(() => _basement = value);
                }),
                _buildSwitch("Has Hot Water Heating?", _hotWaterHeating,
                    (value) {
                  setState(() => _hotWaterHeating = value);
                }),
                _buildSwitch("Has Air Conditioning?", _airConditioning,
                    (value) {
                  setState(() => _airConditioning = value);
                }),
                _buildSwitch("Preferred Area?", _prefArea, (value) {
                  setState(() => _prefArea = value);
                }),
                _buildTextField(_loan, "Loan Amount (₹)", deviceWidth),
                _buildTextField(_interest, "Interest Rate (%)", deviceWidth),
                _buildTextField(_tenure, "Tenure (in years)", deviceWidth),
                // // Add loan details
                // TextFormField(
                //   decoration:
                //       const InputDecoration(labelText: "Loan Amount (₹)"),
                //   keyboardType: TextInputType.number,
                //   onSaved: (value) =>
                //       inputData['loan_amount'] = double.parse(value!),
                // ),
                // TextFormField(
                //   decoration:
                //       const InputDecoration(labelText: "Interest Rate (%)"),
                //   keyboardType: TextInputType.number,
                //   onSaved: (value) =>
                //       inputData['interest_rate'] = double.parse(value!),
                // ),
                // TextFormField(
                //   decoration:
                //       const InputDecoration(labelText: "Tenure (in years)"),
                //   keyboardType: TextInputType.number,
                //   onSaved: (value) => inputData['tenure'] = int.parse(value!),
                // ),
                DropdownButtonFormField(
                  value: _furnishingStatus,
                  items: _furnishingOptions
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _furnishingStatus = value!),
                  decoration:
                      const InputDecoration(labelText: "Furnishing Status"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _predictPrice(context),
                  //{                  //   if (_formKey.currentState!.validate()) {
                  //     _formKey.currentState!.save();
                  //     _predictPrice(context);
                  //   }
                  // },
                  child: const Text("Predict Price"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _predictPrice(context)

  Widget _buildTextField(
      TextEditingController controller, String label, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value!.isEmpty ? "Enter $label" : null,
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
