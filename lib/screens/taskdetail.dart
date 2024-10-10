import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:to_do_list/screens/edittask.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> taskData;
  final String userEmail;
  final String taskId;

  TaskDetailsScreen({
    required this.taskData,
    required this.userEmail,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('รายละเอียดงาน'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(
                    userEmail: userEmail,
                    taskId: taskId,
                    initialTask: taskData,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskHeader(context),
                    SizedBox(height: 30),
                    _buildDetailRow('รายละเอียด', taskData['description']),
                    _buildDetailRow('ความสำคัญ', taskData['priority']),
                    _buildDetailRow('เวลา', taskData['time']),
                    _buildDetailRow('วันที่', taskData['date']),
                    if (taskData['deadline'] != null)
                      _buildDetailRow(
                        'วันครบกำหนด',
                        DateFormat('yyyy-MM-dd')
                            .format(taskData['deadline'].toDate()),
                      ),
                    SizedBox(height: 40),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskScreen(
                                userEmail: userEmail,
                                taskId: taskId,
                                initialTask: taskData,
                              ),
                            ),
                          );
                        },
                        child: Text('แก้ไขงาน'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.purple[200], // เปลี่ยนสีปุ่มเป็นม่วงอ่อน
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black), // ตัวอักษรเป็นสีดำ
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.task, size: 36, color: Theme.of(context).primaryColor),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            'งาน: ${taskData['task']}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value ?? '',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
