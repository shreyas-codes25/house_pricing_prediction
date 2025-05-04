import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

String formatPrice(double price) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  return formatter.format(price);
}

double calculateEMI(double loanAmount, double annualRate, int tenureYears) {
  double monthlyRate = annualRate / (12 * 100);
  int tenureMonths = tenureYears * 12;

  if (monthlyRate == 0) return loanAmount / tenureMonths;

  return (loanAmount * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
      (pow(1 + monthlyRate, tenureMonths) - 1);
}

class PredictionResultScreen extends StatefulWidget {
  final double predictedPrice;
  final Map<String, dynamic> details;
  final String incomeClass;

  const PredictionResultScreen({
    super.key,
    required this.predictedPrice,
    required this.details,
    required this.incomeClass,
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildIncomeClassification() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        "Income Class: ${widget.incomeClass}",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = formatPrice(widget.predictedPrice);
    final loanAmount = widget.details['loan_amount'] ?? 0.0;
    final interestRate = widget.details['interest_rate'] ?? 0.0;
    final tenure = widget.details['tenure'] ?? 0;

    final emi = calculateEMI(loanAmount, interestRate, tenure);
    final formattedEMI = formatPrice(emi);

    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Predicted Price",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  buildIncomeClassification(),
                  const Divider(height: 32),
                  if (loanAmount > 0 || interestRate > 0 || tenure > 0)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Loan Amount: ${formatPrice(loanAmount)}"),
                          Text("Interest Rate: $interestRate%"),
                          Text("Tenure: $tenure years"),
                          const SizedBox(height: 8),
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
                  const SizedBox(height: 24),
                  Text(
                    "Details",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
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
                      children: widget.details.entries.map((entry) {
                        if (entry.key != 'loan_amount' &&
                            entry.key != 'interest_rate' &&
                            entry.key != 'tenure') {
                          if ([
                            'mainroad_yes',
                            'guestroom_yes',
                            'basement_yes',
                            'hotwaterheating_yes',
                            'airconditioning_yes',
                            'prefarea_yes'
                          ].contains(entry.key)) {
                            return Text(
                                "${entry.key.replaceAll('_yes', '').replaceAll('_', ' ').toUpperCase()}: ${(entry.value == 1) ? "Yes" : "No"}");
                          }

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
                              widget.details['furnishingstatus_Unfurnished'] ==
                                  0) {
                            return const Text("Furnishing Status: Furnished");
                          }

                          if (entry.key == "furnishingstatus_Semi-furnished" ||
                              entry.key == "furnishingstatus_Unfurnished") {
                            return const SizedBox.shrink();
                          }

                          return Text(
                              "${entry.key.replaceAll('_', ' ').toUpperCase()}: ${entry.value}");
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
