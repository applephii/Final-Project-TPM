import 'package:flutter/material.dart';
import 'package:studybuddy/models/task.dart';
import 'package:studybuddy/sevices/task_api.dart';

class TaskeditPage extends StatefulWidget {
  final int? taskId;
  const TaskeditPage({super.key, this.taskId});

  @override
  State<TaskeditPage> createState() => _TaskeditPageState();
}

class _TaskeditPageState extends State<TaskeditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _task;
  String _statusTask = 'on progress'; //default

  bool _isLoading = false;
  bool get isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _task = TextEditingController();
    if (isEditing) {
      _loadTask();
    }
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);

    try {
      final task = await TaskApi.getTaskById(widget.taskId!);
      _title.text = task.title.trim();
      _task.text = task.task.trim();
      _statusTask = task.statusTask;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load task')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final task = Task(
      id: isEditing ? widget.taskId! : null,
      title: _title.text,
      task: _task.text,
      statusTask: _statusTask,
    );

    bool success;
    if (isEditing) {
      success = await TaskApi.updateTask(task);
    } else {
      success = await TaskApi.createTask(task);
    }

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to ${isEditing ? 'update' : 'create'} task'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _task.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Task' : 'Add Task',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 45, 93, 141),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 6,
        shadowColor: Colors.blue.shade900,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: _taskForm(),
              ),
    );
  }

  Widget _taskForm() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              validator:
                  (val) =>
                      val == null || val.isEmpty ? 'Title is required' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _task,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              minLines: 3,
              maxLines: 5,
              validator:
                  (val) =>
                      val == null || val.isEmpty
                          ? 'Task description is required'
                          : null,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _statusTask,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              items: [
                DropdownMenuItem(value: 'done', child: Text('Done')),
                DropdownMenuItem(
                  value: 'on progress',
                  child: Text('On Progress'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _statusTask = val);
                }
              },
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveTask,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 45, 93, 141),
                  fixedSize: Size(150, 50),
                ),
              child: Text(isEditing ? 'Update' : 'Create', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ],
        ),
      ),
    );
  }
}
