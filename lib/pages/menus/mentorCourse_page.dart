import 'package:flutter/material.dart';
import 'package:studybuddy/models/course.dart';
import 'package:studybuddy/sevices/course_api.dart';

class MentorcoursePage extends StatefulWidget {
  final int mentorId;
  const MentorcoursePage({super.key, required this.mentorId});

  @override
  State<MentorcoursePage> createState() => _MentorcoursePageState();
}

class _MentorcoursePageState extends State<MentorcoursePage> {
  bool _isLoading = true;
  List<MentorCourse> _courses = [];
  Map<int, bool> expandedCards = {};

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await CourseApi.getCourses(widget.mentorId);
      setState(() {
        _courses = courses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load courses: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mentor's Courses",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body:
          _courses.isEmpty
              ? const Center(child: Text('No courses available'))
              : Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    final isExpanded = expandedCards[course.id] ?? false;
                    return Card(
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
                              Text(
                                course.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),
                                child: Text(
                                  course.statusPublish,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      45,
                                      93,
                                      141,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text("Only for ${course.price} USD"),
                              const SizedBox(height: 6),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    expandedCards[course.id] = !isExpanded;
                                  });
                                },
                                icon: Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: Colors.white,
                                ),
                                label: Text(isExpanded ? 'Hide' : 'Show More'),
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                crossFadeState:
                                    isExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 300),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      backgroundColor: Colors.white,
    );
  }
}
