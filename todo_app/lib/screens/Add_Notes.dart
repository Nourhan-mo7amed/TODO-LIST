import 'package:flutter/material.dart';

import '../Sqldb.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function refreshTasks;

  const AddTaskBottomSheet({Key? key, required this.refreshTasks})
    : super(key: key);

  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  DateTime? selectedDate;
  List<TextEditingController> subtaskControllers = [];

  final Sqldb db = Sqldb();
  Color selectedColor = Colors.indigo;

  @override
  void initState() {
    super.initState();
    addSubtaskField(); // أول خانة
  }

  void addSubtaskField() {
    setState(() {
      subtaskControllers.add(TextEditingController());
    });
  }

  void removeSubtaskField(int index) {
    setState(() {
      subtaskControllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final mainTaskId = await db.insertMainTask(
      titleController.text.trim(),
      selectedDate?.toString().split(" ")[0],
      selectedColor.value.toRadixString(16), // حفظ اللون
    );

    for (var controller in subtaskControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        await db.insertSubTask(mainTaskId, text);
      }
    }

    widget.refreshTasks();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add New Task",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 15),

                // Task Title
                TextFormField(
                  controller: titleController,
                  style: TextStyle(color: Colors.black), // ← لون الكتابة أسود
                  decoration: InputDecoration(
                    hintText: "Task title...",
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 14,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                // Date Picker
                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.indigo,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? "Select due date"
                              : "${selectedDate!.toLocal()}".split(' ')[0],
                          // style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Color Picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Color",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      //color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children:
                      [
                        Colors.indigo,
                        Colors.red,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                        Colors.blueGrey,
                      ].map((color) {
                        return GestureDetector(
                          onTap: () => setState(() => selectedColor = color),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: color,
                            child: selectedColor == color
                                ? Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                ),

                SizedBox(height: 25),

                // Subtasks
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Subtasks",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ...List.generate(subtaskControllers.length, (index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: subtaskControllers[index],
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Subtask ${index + 1}",
                                hintStyle: TextStyle(color: Colors.grey),
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          if (subtaskControllers.length > 1)
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => removeSubtaskField(index),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ), // ← هنا المسافة بين كل ساب تاسك والتاني
                    ],
                  );
                }),

                SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: addSubtaskField,
                    icon: Icon(Icons.add, color: Colors.indigo),
                    label: Text(
                      "Add Subtask",
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // Save and Cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Save",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
