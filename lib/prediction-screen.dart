import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'prediction_result.dart';

class PredictionInputScreen extends StatefulWidget {
  const PredictionInputScreen({Key? key}) : super(key: key);

  @override
  _PredictionInputScreenState createState() => _PredictionInputScreenState();
}

class _PredictionInputScreenState extends State<PredictionInputScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _storiesController = TextEditingController();
  final TextEditingController _parkingController = TextEditingController();
  final TextEditingController _loan = TextEditingController();
  final TextEditingController _tenure = TextEditingController();
  final TextEditingController _interest = TextEditingController();

  bool _mainRoad = false;
  bool _guestRoom = false;
  bool _basement = false;
  bool _hotWaterHeating = false;
  bool _airConditioning = false;
  bool _prefArea = false;

  String _furnishingStatus = 'Semi-furnished';
  final List<String> _furnishingOptions = [
    'Semi-furnished',
    'Unfurnished',
    'Furnished'
  ];

  bool _loading = false;

  Future<void> _predictPrice(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _loading = true;
    });

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
      'loan_amount': double.parse(_loan.text),
      'tenure': int.parse(_tenure.text),
      'interest_rate': double.parse(_interest.text),
    };

    try {
      final response = await http.post(
        // Replace with your server URL
        Uri.parse('http://192.168.29.32:5000/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inputData),
      );

      setState(() {
        _loading = false;
      });

      if (response.statusCode == 200) {
        final double prediction = jsonDecode(response.body)['predicted_price'];
        final incomeClass = jsonDecode(response.body)['income_class'];

        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final tween = Tween(begin: 0.0, end: 1.0);
              return FadeTransition(
                  opacity: animation.drive(tween), child: child);
            },
            pageBuilder: (_, __, ___) => PredictionResultScreen(
              predictedPrice: prediction,
              details: inputData,
              incomeClass: incomeClass,
            ),
          ),
        );
      } else {
        throw Exception("Failed to predict price");
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Padding(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) => value!.isEmpty ? "Enter $label" : null,
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (val) => setState(() => onChanged(val)),
      activeColor: Colors.deepPurple,
    );
  }

  Widget _buildSectionTitle(String title) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(Icons.label_important_rounded, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏠 Housing Price Predictor"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSectionTitle("Property Info"),
                        _buildTextField(_areaController, "Area (sq. ft.)"),
                        _buildTextField(_bedroomsController, "Bedrooms"),
                        _buildTextField(_bathroomsController, "Bathrooms"),
                        _buildTextField(_storiesController, "Stories"),
                        _buildTextField(_parkingController, "Parking Spaces"),
                        const Divider(),
                        _buildSectionTitle("Amenities"),
                        _buildSwitch("Located on Main Road?", _mainRoad,
                            (val) => _mainRoad = val),
                        _buildSwitch("Guest Room Available?", _guestRoom,
                            (val) => _guestRoom = val),
                        _buildSwitch("Has Basement?", _basement,
                            (val) => _basement = val),
                        _buildSwitch("Hot Water Heating?", _hotWaterHeating,
                            (val) => _hotWaterHeating = val),
                        _buildSwitch("Air Conditioning?", _airConditioning,
                            (val) => _airConditioning = val),
                        _buildSwitch("Preferred Area?", _prefArea,
                            (val) => _prefArea = val),
                        const Divider(),
                        _buildSectionTitle("Loan Details"),
                        _buildTextField(_loan, "Loan Amount (₹)"),
                        _buildTextField(_interest, "Interest Rate (%)"),
                        _buildTextField(_tenure, "Tenure (in years)"),
                        const Divider(),
                        _buildSectionTitle("Furnishing"),
                        DropdownButtonFormField<String>(
                          value: _furnishingStatus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _furnishingOptions.map((option) {
                            return DropdownMenuItem(
                                value: option, child: Text(option));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _furnishingStatus = value!),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed:
                              _loading ? null : () => _predictPrice(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.calculate,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Predict Price",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_loading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
