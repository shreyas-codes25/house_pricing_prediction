import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Function to format the price
String formatPrice(double price) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Use 'en_IN' for Indian-style formatting
    symbol: '₹', // Currency symbol
    decimalDigits: 2,
  );
  return formatter.format(price);
}

// In your widget where the price is displayed
// predictedPrice is the double value

class PredictionResultScreen extends StatelessWidget {
  final double predictedPrice;
  final Map<String, dynamic> details;

  const PredictionResultScreen({
    super.key,
    required this.predictedPrice,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = formatPrice(predictedPrice);
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Predicted Price: ₹$formattedPrice",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "Details:",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ...details.entries
                .map((entry) => Text("${entry.key}: ${entry.value}")),
          ],
        ),
      ),
    );
  }
}
