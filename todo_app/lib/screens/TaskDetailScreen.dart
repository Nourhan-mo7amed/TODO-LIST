import 'package:flutter/material.dart';
import '../Sqldb.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final String taskTitle;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final db = Sqldb();
  bool updated = false;

  Future<List<Map<String, dynamic>>> getSubTasks() async {
    return await db.getSubTasks(widget.taskId);
  }

  Future<void> toggleDone(int subTaskId, bool currentValue) async {
    await db.updateSubTaskDone(subTaskId, !currentValue);
    updated = true;
    setState(() {});
  }

  Future<void> deleteSubTask(int subTaskId) async {
    await db.deleteSubTask(subTaskId);
    updated = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, updated);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color(0xFF5A189A),
          elevation: 3,
          title: Text(
            widget.taskTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: getSubTasks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final subtasks = snapshot.data!;
            if (subtasks.isEmpty) {
              return const Center(
                child: Text(
                  "No subtasks yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subtasks.length,
              itemBuilder: (context, index) {
                final sub = subtasks[index];
                final isDone = sub['is_done'] == 1;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2.5,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: Colors.indigoAccent,
                      value: isDone,
                      onChanged: (val) => toggleDone(sub['id'], isDone),
                    ),
                    title: Text(
                      sub['content'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDone ? Colors.grey : Colors.black87,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.redAccent,
                      onPressed: () => deleteSubTask(sub['id']),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
