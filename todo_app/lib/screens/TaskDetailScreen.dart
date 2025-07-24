import 'package:flutter/material.dart';
import '../Sqldb.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  final String taskTitle;

  const TaskDetailScreen({required this.taskId, required this.taskTitle});

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
        backgroundColor: const Color(0xFFF1F3F6),
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          title: Text(
            widget.taskTitle,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 4,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: getSubTasks(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final subtasks = snapshot.data!;
            if (subtasks.isEmpty) return const Center(child: Text("No subtasks yet"));

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: subtasks.length,
              itemBuilder: (context, index) {
                final sub = subtasks[index];
                final isDone = sub['is_done'] == 1;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        // ✔️ Checkbox على الشمال
                        Checkbox(
                          activeColor: Colors.deepPurpleAccent,
                          value: isDone,
                          onChanged: (val) => toggleDone(sub['id'], isDone),
                        ),

                        // نص التاسك
                        Expanded(
                          child: Text(
                            sub['content'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDone ? Colors.grey : Colors.black87,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),

                        // 🗑️ زر الحذف
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => deleteSubTask(sub['id']),
                        ),
                      ],
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
