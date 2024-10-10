import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final String userEmail;
  final String taskId;
  final Map<String, dynamic> initialTask;

  EditTaskScreen({
    required this.userEmail,
    required this.taskId,
    required this.initialTask,
  });

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _task;
  late String _selectedPriority;
  late TimeOfDay _selectedTime;
  late String _description;
  late DateTime _selectedDate;
  late DateTime _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _task = widget.initialTask['task'];
    _selectedPriority = widget.initialTask['priority'];
    _selectedTime = TimeOfDay(
      hour: int.parse(widget.initialTask['time'].split(':')[0]),
      minute: int.parse(widget.initialTask['time'].split(':')[1].split(' ')[0]),
    );
    _description = widget.initialTask['description'] ?? '';
    _selectedDate =
        DateTime.tryParse(widget.initialTask['date'] ?? '') ?? DateTime.now();

    // ตรวจสอบว่า deadline เป็น null หรือไม่
    if (widget.initialTask['deadline'] != null) {
      _selectedDeadline =
          (widget.initialTask['deadline'] as Timestamp).toDate();
    } else {
      _selectedDeadline = DateTime.now(); // ตั้งเป็นค่าเริ่มต้นถ้าเป็น null
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขงาน', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromRGBO(162, 128, 93, 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFormField('งาน', (value) {
                  _task = value!;
                }, validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกงาน';
                  }
                  return null;
                }, initialValue: _task),
                SizedBox(height: 20),
                _buildTextFormField('รายละเอียด', (value) {
                  _description = value!;
                }, maxLines: 3, initialValue: _description),
                SizedBox(height: 20),
                _buildDropdownButtonFormField(
                    'ความสำคัญ', _selectedPriority, ['ต่ำ', 'ปานกลาง', 'สูง'],
                    (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                }),
                SizedBox(height: 20),
                _buildElevatedButton('เวลา: ${_selectedTime.format(context)}',
                    () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                }, Color.fromRGBO(218, 198, 163, 1.0)), // สีปุ่มเวลา
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
                }, Color.fromRGBO(218, 198, 163, 1.0)), // สีปุ่มวันที่
                SizedBox(height: 20),
                _buildUpdateTaskButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, Function(String) onSaved,
      {int? maxLines,
      String? Function(String?)? validator,
      required String initialValue}) {
    return TextFormField(
      initialValue: initialValue,
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
      value: value,
      items: [
        DropdownMenuItem<String>(
          value: '', // เพิ่ม DropdownMenuItem ที่มีค่าว่าง
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
      child: Text(text, style: TextStyle(color: Colors.black)), // ตัวอักษรสีดำ
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildUpdateTaskButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            final db = FirebaseFirestore.instance;
            final tasksCollection =
                db.collection('tasks').doc(widget.userEmail);

            await tasksCollection.update({
              'tasks.${widget.taskId}': {
                'taskId': widget.taskId,
                'task': _task,
                'priority': _selectedPriority,
                'time': _selectedTime.format(context),
                'description': _description,
                'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
                'deadline': Timestamp.fromDate(_selectedDeadline),
                'isCompleted': widget.initialTask['isCompleted'],
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('แก้ไขงานสำเร็จ')),
            );
            Navigator.pop(context);
          }
        },
        child: Text('แก้ไขงาน'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(185, 154, 99, 1),
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
      ),
    );
  }
}
