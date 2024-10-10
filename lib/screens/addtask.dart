import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPriority = '';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มงาน', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(162, 128, 93, 1.0),
      ),
      body: Container(
        color: Color.fromRGBO(218, 198, 163, 1.0),
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('การเริ่มต้น Firebase ล้มเหลว'));
            }

            if (snapshot.connectionState == ConnectionState.done) {
              String? userEmail = FirebaseAuth.instance.currentUser?.email;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'สร้างงานใหม่',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(162, 128, 93, 1.0),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildTextFormField(
                            'งาน',
                            _taskController,
                            (value) {},
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกงาน';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          _buildTextFormField(
                            'รายละเอียด',
                            _descriptionController,
                            (value) {},
                            maxLines: 3,
                          ),
                          SizedBox(height: 20),
                          _buildDropdownButtonFormField(
                            'ความสำคัญ',
                            _selectedPriority,
                            ['ต่ำ', 'ปานกลาง', 'สูง'],
                            (value) {
                              _selectedPriority = value!;
                            },
                          ),
                          SizedBox(height: 20),
                          _buildElevatedButton(
                            'เวลา: ${_selectedTime.format(context)}',
                            () async {
                              final TimeOfDay? pickedTime =
                                  await showTimePicker(
                                context: context,
                                initialTime: _selectedTime,
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  _selectedTime = pickedTime;
                                });
                              }
                            },
                            Color.fromRGBO(218, 198, 163, 1.0),
                          ),
                          SizedBox(height: 20),
                          _buildElevatedButton(
                            'วันที่: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                            () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _selectedDate = pickedDate;
                                });
                              }
                            },
                            Color.fromRGBO(218, 198, 163, 1.0),
                          ),
                          SizedBox(height: 20),
                          _buildAddTaskButton(context, userEmail),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      String label, TextEditingController controller, Function(String) onSaved,
      {int? maxLines, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      validator: validator,
      onSaved: (value) {
        onSaved(value!);
      },
    );
  }

  Widget _buildDropdownButtonFormField(String label, String value,
      List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      value: value.isEmpty ? null : value,
      items: [
        DropdownMenuItem<String>(
          value: '',
          child: Text('เลือกความสำคัญ'),
        ),
        ...items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildElevatedButton(
      String text, VoidCallback onPressed, Color? color) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context, String? userEmail) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            String taskId = Uuid().v4();
            await FirebaseFirestore.instance
                .collection('tasks')
                .doc(userEmail)
                .set({
              'tasks': {
                taskId: {
                  'taskId': taskId,
                  'task': _taskController.text,
                  'description': _descriptionController.text,
                  'priority': _selectedPriority,
                  'time': _selectedTime.format(context),
                  'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
                  'isCompleted': false,
                }
              }
            }, SetOptions(merge: true));
            Navigator.pop(context);
          }
        },
        child: Text('เพิ่มงาน'),
      ),
    );
  }
}
