import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studybuddy/models/mentor.dart';
import 'package:studybuddy/pages/menus/mentorCourse_page.dart';
import 'package:studybuddy/sevices/mentor_api.dart';
import 'package:studybuddy/sevices/session.dart';

class StudyBuddiesTimePage extends StatefulWidget {
  const StudyBuddiesTimePage({super.key});

  @override
  State<StudyBuddiesTimePage> createState() => _StudyBuddiesTimePageState();
}

class _StudyBuddiesTimePageState extends State<StudyBuddiesTimePage> {
  late Timer _timer;
  bool showOnlyFavorites = false;
  bool _isConnected = false;
  bool _isLoading = true;

  List<Mentor> _mentors = [];
  List<Mentor> _filteredMentors = [];
  List<Mentor> favoriteMentors = [];
  Set<int> _favoriteMentorIds = {};

  Map<int, int> selectedOffsets = {};
  Map<int, String> selectedLabels = {};
  Map<int, bool> expandedCards = {};

  final List<Map<String, dynamic>> timeZones = [
    {'label': 'WIB (GMT+7)', 'offset': 7},
    {'label': 'London (GMT+1)', 'offset': 1},
    {'label': 'WIT (GMT+9)', 'offset': 9},
    {'label': 'WITA (GMT+8)', 'offset': 8},
    {'label': 'Bangkok (GMT+7)', 'offset': 7},
    {'label': 'Tokyo (GMT+9)', 'offset': 9},
    {'label': 'Seoul (GMT+9)', 'offset': 9},
  ];

  @override
  void initState() {
    super.initState();
    _loadMentor();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadMentor() async {
    try {
      // final userID = await SessionService.getUserId();
      final mentors = await MentorApi.fetchMentors();
      if (mentors.isEmpty) {
        throw Exception('No mentors found');
      }

      final favoriteMentors = await MentorApi.fetchFavouriteMentors();
      _favoriteMentorIds = favoriteMentors.map((m) => m.id).toSet();

      for (var mentor in mentors) {
        selectedOffsets[mentor.id] = mentor.timezoneOffset;

        final matchedTz = timeZones.firstWhere(
          (tz) => tz['offset'] == mentor.timezoneOffset,
          orElse: () => timeZones.first,
        );

        selectedLabels[mentor.id] = matchedTz['label'];
      }

      setState(() {
        _mentors = mentors;
        _filteredMentors = mentors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load mentors: $e')));
    }
  }

  String convertTime(int targetOffsetHours) {
    final nowUtc = DateTime.now().toUtc();
    final convertedTime = nowUtc.add(Duration(hours: targetOffsetHours));
    return DateFormat('HH:mm').format(convertedTime);
  }

  String diffText(int sourceOffsetHours, int targetOffsetHours) {
    final diff = targetOffsetHours - sourceOffsetHours;

    if (diff == 0) return 'Same time zone';

    final aheadBehind = diff > 0 ? 'ahead' : 'behind';
    return '${diff.abs()} hour(s) $aheadBehind';
  }

  void _toggleConnect(int mentorId) async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to manage connection to mentors'),
        ),
      );
      return;
    }

    final wasFavorite = _favoriteMentorIds.contains(mentorId);
    setState(() {
      if (wasFavorite) {
        _favoriteMentorIds.remove(mentorId);
      } else {
        _favoriteMentorIds.add(mentorId);
      }
    });

    try {
      if (wasFavorite) {
        await MentorApi.removeFavouriteMentor(mentorId);
      } else {
        await MentorApi.addFavouriteMentor(mentorId);
      }
    } catch (e) {
      setState(() {
        if (wasFavorite) {
          _favoriteMentorIds.add(mentorId);
        } else {
          _favoriteMentorIds.remove(mentorId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update connection to mentors: $e')),
      );
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
          'Study Buddies',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredMentors.length,
        itemBuilder: (context, index) {
          final mentor = _filteredMentors[index];
          final isExpanded = expandedCards[mentor.id] ?? false;
          final selectedLabel = selectedLabels[mentor.id] ?? mentor.timezone;
          final selectedOffset =
              selectedOffsets[mentor.id] ?? mentor.timezoneOffset;

          final originalTime = convertTime(mentor.timezoneOffset);
          final convertedTime = convertTime(selectedOffset);
          final difference = diffText(mentor.timezoneOffset, selectedOffset);

          final isFavorite = _favoriteMentorIds.contains(mentor.id);

          return Card(
            color: const Color.fromARGB(255, 45, 93, 141), // Tambahkan ini
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 20),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(mentor.imgUrl),
                          backgroundColor: Colors.grey[300],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            mentor.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          isFavorite
                              ? Icons.handshake
                              : Icons.handshake_outlined,
                          color: isFavorite ? Colors.white : Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Currently in ${mentor.location} | $originalTime (${mentor.timezone})',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          expandedCards[mentor.id] = !isExpanded;
                        });
                      },
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
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
                            margin: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Convert to:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                dropdownColor: const Color.fromARGB(
                                  255,
                                  45,
                                  93,
                                  141,
                                ),
                                value:
                                    timeZones.any(
                                          (tz) =>
                                              tz['label'] ==
                                              selectedLabels[mentor.id],
                                        )
                                        ? selectedLabels[mentor.id]
                                        : timeZones.first['label'],
                                iconEnabledColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                items:
                                    timeZones.map((tz) {
                                      return DropdownMenuItem<String>(
                                        value: tz['label'],
                                        child: Text(
                                          tz['label'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() {
                                    if (value == null) return;
                                    final offset =
                                        timeZones.firstWhere(
                                          (tz) => tz['label'] == value,
                                        )['offset'];
                                    setState(() {
                                      selectedLabels[mentor.id] = value;
                                      selectedOffsets[mentor.id] = offset;
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Converted Time: $convertedTime',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            difference,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 1,
                            width: double.infinity,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.only(
                              left: 10,
                              top: 5,
                              bottom: 5,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 60, 138, 215),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              mentor.expertise,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _toggleConnect(mentor.id),
                                  child: Text(
                                    _favoriteMentorIds.contains(mentor.id)
                                        ? 'Disconnect from Mentor'
                                        : 'Connect to Mentor',
                                  ),
                                ),
                              ),
                              if (_favoriteMentorIds.contains(mentor.id)) ...[
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 166, 211, 255),
                                    foregroundColor: const Color.fromARGB(255, 45, 93, 141)
                                  ),
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Navigating to ${mentor.name}\'s course...',
                                        ),
                                      ),
                                    );
                                    await Navigator.push(context, MaterialPageRoute(builder: (context) => MentorcoursePage(mentorId: mentor.id)));
                                  },
                                  child: const Text('Go to Course'),
                                ),
                              ],
                            ],
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
      backgroundColor: Colors.white,
    );
  }
}
