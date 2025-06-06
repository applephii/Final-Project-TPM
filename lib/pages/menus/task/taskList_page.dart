import 'package:flutter/material.dart';
import 'package:studybuddy/models/task.dart';
import 'package:studybuddy/pages/menus/task/TaskDetail_page.dart';
import 'package:studybuddy/pages/menus/task/TaskEdit_page.dart';
import 'package:studybuddy/sevices/session.dart';
import 'package:studybuddy/sevices/task_api.dart';

class TasklistPage extends StatefulWidget {
  const TasklistPage({super.key});

  @override
  State<TasklistPage> createState() => _TasklistPageState();
}

class _TasklistPageState extends State<TasklistPage> {
  late Future<List<Task>> _futureTasks;
  String _filterStatus = 'all';
  int _doneCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    setState(() {
      _futureTasks = TaskApi.getTasks().then((tasks) async {
        final doneCount = tasks.where((t) => t.statusTask == 'done').length;
        await SessionService.setDonePoints(doneCount);
        _doneCount = doneCount;
        return tasks;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'all', child: Text('All')),
              PopupMenuItem(value: 'done', child: Text('Done')),
              PopupMenuItem(value: 'on progress', child: Text('On Progress')),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _taskList()),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => TaskeditPage()),
          );
          if (created == true) _loadTask();
        },
      ),
      backgroundColor: const Color.fromARGB(255, 45, 93, 141),
    );
  }

  Widget _taskList() {
    return FutureBuilder<List<Task>>(
      future: _futureTasks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        var tasks = snapshot.data ?? [];
        if (_filterStatus != 'all') {
          tasks = tasks.where((t) => t.statusTask == _filterStatus).toList();
        }

        if (tasks.isEmpty) {
          return Center(child: Text('No tasks found.'));
        }

        return Column(
          children: [
            Card(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '🎯 Points Earned: $_doneCount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 45, 93, 141),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: const Color.fromARGB(255, 45, 93, 141),
                        ),
                      ),
                      tileColor: Colors.white,
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(task.statusTask),
                      trailing: Icon(
                        task.statusTask == 'done'
                            ? Icons.check_circle
                            : Icons.pending,
                        color: task.statusTask == 'done'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      onTap: () async {
                        final refresh = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskdetailPage(taskId: task.id!),
                          ),
                        );
                        if (refresh == true) _loadTask();
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
