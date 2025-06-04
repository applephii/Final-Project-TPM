import 'package:flutter/material.dart';
import 'package:studybuddy/models/task.dart';
import 'package:studybuddy/pages/menus/task/TaskEdit_page.dart';
import 'package:studybuddy/sevices/task_api.dart';

class TaskdetailPage extends StatefulWidget {
  final int taskId;
  const TaskdetailPage({super.key, required this.taskId});

  @override
  State<TaskdetailPage> createState() => _TaskdetailPageState();
}

class _TaskdetailPageState extends State<TaskdetailPage> {
  late Future<Task> _futureTask;

  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    _futureTask = TaskApi.getTaskById(widget.taskId);
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete task?'),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await TaskApi.deleteTask(widget.taskId);
      if (success) {
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete task')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskeditPage(taskId: widget.taskId),
                ),
              );
              if (updated == true) {
                setState(() {
                  _loadTask();
                });
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(icon: Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: _detail()),
      backgroundColor: Colors.white,
    );
  }

  Widget _detail() {
    return SingleChildScrollView(
      child: FutureBuilder<Task>(
        future: _futureTask,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final task = snapshot.data!;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color:
                        task.statusTask == 'done'
                            ? Colors.green
                            : task.statusTask == 'on progress'
                            ? Colors.orange
                            : Colors.grey,
                  ),
                  child: Text(
                    task.statusTask,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  task.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(task.task, style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
