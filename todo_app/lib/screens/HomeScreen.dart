import 'package:flutter/material.dart';
import 'package:todo_app/screens/Add_Notes.dart';
import 'package:todo_app/screens/TaskDetailScreen.dart'; // تأكد إنه موجود

import '../Sqldb.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Sqldb db = Sqldb();

  @override
  void initState() {
    super.initState();
    //Sqldb().deleteDatabaseFile(); // 🧨 احذفيها بعد أول تشغيل
  }

  Future<List<Map<String, dynamic>>> getMainTasks() async {
    return await db.getMainTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {});
  }

  Widget buildProgressBar(double percent) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: percent,
        backgroundColor: Colors.grey[300],
        color: Colors.pinkAccent,
        minHeight: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF88A2A2),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF88A2A2),
        leading: Icon(Icons.menu, color: Colors.white),
        title: Text('ToDo', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getMainTasks(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final mainTasks = snapshot.data!;
          if (mainTasks.isEmpty) {
            return Center(
              child: Text(
                "No tasks yet",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: mainTasks.length,
            itemBuilder: (context, index) {
              final task = mainTasks[index];
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: db.getSubTasks(task['id']),
                builder: (context, snapshotSubs) {
                  final subtasks = snapshotSubs.data ?? [];
                  final done = subtasks.where((s) => s['is_done'] == 1).length;
                  final percent = subtasks.isEmpty
                      ? 0.0
                      : done / subtasks.length;

                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(
                            taskId: task['id'],
                            taskTitle: task['title'],
                          ),
                        ),
                      );

                      if (result == true) _refreshTasks(); // ✅ تحديث بعد الرجوع
                    },

                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color(
                          int.parse(task['color'] ?? 'FF2196F3', radix: 16),
                        ).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(
                            int.parse(task['color'] ?? 'FF2196F3', radix: 20),
                          ),
                          width: 2,
                        ),
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.book_outlined,
                                color: Colors.pinkAccent,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  task['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (val) async {
                                  if (val == 'delete') {
                                    await db.deleteMainTask(task['id']);
                                    _refreshTasks();
                                  } else if (val == 'add_item') {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (_) => AddSubTaskBottomSheet(
                                        taskId: task['id'],
                                        onSubTaskAdded: _refreshTasks,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.grey[800],
                                ),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'add_item',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, color: Colors.indigo),
                                        SizedBox(width: 10),
                                        Text(
                                          'Add Item',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Delete',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            "${subtasks.length} items",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          buildProgressBar(percent),
                          SizedBox(height: 6),
                          Text(
                            "${(percent * 100).toInt()}%",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return AddTaskBottomSheet(refreshTasks: _refreshTasks);
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.indigo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class AddSubTaskBottomSheet extends StatefulWidget {
  final int taskId;
  final Function onSubTaskAdded;

  const AddSubTaskBottomSheet({
    super.key,
    required this.taskId,
    required this.onSubTaskAdded,
  });

  @override
  State<AddSubTaskBottomSheet> createState() => _AddSubTaskSheet();
}

class _AddSubTaskSheet extends State<AddSubTaskBottomSheet> {
  final _controller = TextEditingController();
  bool isLoading = false;

  void _addSubTask() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => isLoading = true);
    await Sqldb().insertSubTask(widget.taskId, _controller.text.trim());
    widget.onSubTaskAdded();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add Subtask',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Subtask title',
              filled: true,
              fillColor: Colors.grey[300],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: isLoading ? null : _addSubTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
