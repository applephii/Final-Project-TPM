import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:studybuddy/models/course.dart';
import 'package:studybuddy/sevices/course_api.dart';
import 'package:studybuddy/sevices/mentor_api.dart';

class MoneyconvertPage extends StatefulWidget {
  const MoneyconvertPage({super.key});

  @override
  State<MoneyconvertPage> createState() => _MoneyconvertPageState();
}

class _MoneyconvertPageState extends State<MoneyconvertPage> {
  final TextEditingController _amountController = TextEditingController();

  String _fromCurrency = 'USD';
  String _toCurrency = 'IDR';
  double _convertedAmount = 0;
  bool isLoading = false;
  String formatedAmount = '';
  String selectedCurrency = 'USD';

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

  List<MentorCourse> _apiCourses = [];
  bool _isLoadingCourses = true;
  Map<int, String> _mentorMap = {};
  Map<int, bool> expandedCards = {};

  @override
  void initState() {
    super.initState();
    _loadApiCourses();
  }

  Future<void> _loadApiCourses() async {
    try {
      final mentors = await MentorApi.fetchMentors();
      final mentorMap = {for (var m in mentors) m.id: m.name};

      final allCourses = await CourseApi.getAllCourses();

      setState(() {
        _mentorMap = mentorMap;
        _apiCourses = allCourses;
        _isLoadingCourses = false;
      });
    } catch (e) {
      setState(() => _isLoadingCourses = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load courses: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Special Offers",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
              SizedBox(height: 15),
              _isLoadingCourses
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    height: 430,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _apiCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final course = _apiCourses[index];
                        final mentorName =
                            _mentorMap[course.mentorId] ?? "Unknown";
                        final originalPrice = course.price;
                        final converted =
                            originalPrice /
                            exchangeRates['USD']! *
                            exchangeRates[selectedCurrency]!;
                        final formatted = NumberFormat(
                          '#,##0.00',
                          'en_US',
                        ).format(converted);
                        final isExpanded = expandedCards[course.id] ?? false;

                        return Container(
                          width: 280,
                          constraints: BoxConstraints(
                            minHeight: 200,
                            maxHeight: isExpanded ? 400 : 200,
                          ),
                          child: Card(
                            color: const Color.fromARGB(255, 45, 93, 141),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.only(bottom: 20),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: DefaultTextStyle(
                                style: const TextStyle(color: Colors.white),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.white,
                                      ),
                                      child: Text(
                                        course.statusPublish,
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            45,
                                            93,
                                            141,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      course.title,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "by $mentorName",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 13),

                                    Text(
                                      "Only for $formatted $selectedCurrency",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 1,
                                      width: double.infinity,
                                      color: Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                    Text(
                                      course.description,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

              SizedBox(height: 25),
              Text(
                "Convert course price to your currency",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
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

                child: Text(
                  '$formatedAmount $_toCurrency',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 45, 93, 141),
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
