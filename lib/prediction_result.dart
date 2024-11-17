import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // Import for pow function

// Function to format the price or EMI
String formatPrice(double price) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Use 'en_IN' for Indian-style formatting
    symbol: '₹', // Currency symbol
    decimalDigits: 2,
  );
  return formatter.format(price);
}

// Function to calculate EMI
double calculateEMI(double loanAmount, double annualRate, int tenureYears) {
  double monthlyRate =
      annualRate / (12 * 100); // Annual interest rate to monthly rate
  int tenureMonths = tenureYears * 12; // Convert years to months

  if (monthlyRate == 0) {
    return loanAmount / tenureMonths; // Handle 0% interest rate case
  }

  return (loanAmount * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
      (pow(1 + monthlyRate, tenureMonths) - 1);
}

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

    // Retrieve loan details from the `details` map
    double loanAmount = details['loan_amount'] ?? 0.0;
    double interestRate = details['interest_rate'] ?? 0.0;
    int tenure = details['tenure'] ?? 0;

    print(
        'Loan Amount: $loanAmount, Interest Rate: $interestRate, Tenure: $tenure');
    // Calculate EMI
    double emi = calculateEMI(loanAmount, interestRate, tenure);
    final formattedEMI = formatPrice(emi);

    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Predicted Price: $formattedPrice",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 16),
                if (loanAmount > 0 || interestRate > 0 || tenure > 0) ...[
                  // EMI Section with heading
                  const SizedBox(height: 16),
                  Text(
                    "EMI",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Loan Amount: ${formatPrice(loanAmount)}"),
                            Text("Interest Rate: $interestRate%"),
                            Text("Tenure: $tenure years"),
                            Text(
                              "Estimated EMI: $formattedEMI",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ],
                Text(
                  "Details:",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.redAccent,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: details.entries.map((entry) {
                      if (entry.key != 'loan_amount' &&
                          entry.key != 'interest_rate' &&
                          entry.key != 'tenure') {
                        // Handle boolean keys for "Yes" or "No"
                        if (entry.key == 'mainroad_yes' ||
                            entry.key == 'guestroom_yes' ||
                            entry.key == 'basement_yes' ||
                            entry.key == 'hotwaterheating_yes' ||
                            entry.key == 'airconditioning_yes' ||
                            entry.key == 'prefarea_yes') {
                          return Text(
                              "${entry.key}: ${(entry.value == 1) ? "Yes" : "No"}");
                        }

                        // Handle furnishing status
                        if (entry.key == 'furnishingstatus_Semi-furnished' &&
                            entry.value == 1) {
                          return const Text(
                              "Furnishing Status: Semi-furnished");
                        } else if (entry.key ==
                                'furnishingstatus_Unfurnished' &&
                            entry.value == 1) {
                          return const Text("Furnishing Status: Unfurnished");
                        } else if (entry.key ==
                                'furnishingstatus_Semi-furnished' &&
                            entry.value == 0 &&
                            details['furnishingstatus_Unfurnished'] == 0) {
                          return const Text("Furnishing Status: Furnished");
                        }

                        if (entry.key == "furnishingstatus_Semi-furnished" ||
                            entry.key == "furnishingstatus_Unfurnished") {
                          return const Text("");
                        }
                        // Default case for other keys
                        return Text("${entry.key}: ${entry.value}");
                      }
                      return const SizedBox
                          .shrink(); // Skip loan-related details in the general details section
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
