import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class MoneyconvertPage extends StatefulWidget {
  const MoneyconvertPage({super.key});

  @override
  State<MoneyconvertPage> createState() => _MoneyconvertPageState();
}

class _MoneyconvertPageState extends State<MoneyconvertPage> {
  final TextEditingController _amountController = TextEditingController();

  String _fromCurrency = 'IDR';
  String _toCurrency = 'EUR';
  double _convertedAmount = 0;
  bool isLoading = false;
  String formatedAmount = '';

  final Map<String, double> exchangeRates = {
    'USD': 1,
    'IDR': 15600,
    'EUR': 0.92,
    'JPY': 157.5,
    'GBP': 0.78,
  };

  void _convert() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fromRate = exchangeRates[_fromCurrency]!;
    final toRate = exchangeRates[_toCurrency]!;

    final result = amount / fromRate * toRate;

    setState(() {
      _convertedAmount = result;
    });

    formatedAmount = NumberFormat('#,##0.00', 'en_US').format(_convertedAmount);
  }

  final List<Map<String, String>> courses = [
    {'name': 'Flutter Basics', 'price': '100 USD'},
    {'name': 'Dart Advanced', 'price': '150 USD'},
    {'name': 'State Management', 'price': '120 USD'},
    {'name': 'UI/UX Design', 'price': '90 USD'},
    {'name': 'Firebase Integration', 'price': '110 USD'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Available Courses:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Container(
                      width: 160,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade400,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            course['name']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            course['price']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 35),
              Text(
                "Convert course price to your currency",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              //dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _fromCurrency,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          exchangeRates.keys.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _fromCurrency = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.swap_horiz),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _toCurrency,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          exchangeRates.keys.map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _toCurrency = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Convert button
              ElevatedButton(
                onPressed: _convert,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                  fixedSize: Size(150, 50),
                ),
                child: Text(
                  'Convert',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 184, 225, 255),
                  borderRadius: BorderRadius.circular(8),
                  shape: BoxShape.rectangle,
                ),
                child: Text(
                  '$formatedAmount $_toCurrency',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
