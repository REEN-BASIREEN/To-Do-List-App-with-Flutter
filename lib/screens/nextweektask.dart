import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'taskdetail.dart';

class NextWeekTasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('งานสัปดาห์หน้า')),
      body: TaskListView(DateTime.now().add(Duration(days: 7))),
    );
  }
}

class TaskListView extends StatelessWidget {
  final DateTime date;

  TaskListView(this.date);

  @override
  Widget build(BuildContext context) {
    final userEmail = 'user@example.com'; // เปลี่ยนเป็น userEmail ที่ถูกต้อง

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .doc(userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('ไม่พบเอกสาร'));
        }

        final tasks =
            (snapshot.data!.data() as Map<String, dynamic>)['tasks'] ?? {};

        // แสดง debug ข้อมูลที่ดึงมา
        print("Tasks data: $tasks");

        // กรองงานตามวันที่ในฟิลด์ 'deadline'
        final filteredTasks = (tasks.values as List<dynamic>).where((task) {
          final deadline = task['deadline'] as Timestamp?;
          if (deadline != null) {
            final deadlineDate = deadline.toDate();
            return deadlineDate.isAfter(date.subtract(Duration(days: 7))) &&
                deadlineDate.isBefore(date.add(Duration(days: 1)));
          }
          return false; // ถ้าไม่มี deadline ให้กรองออก
        }).toList();

        if (filteredTasks.isEmpty) {
          return Center(child: Text('ไม่มีงานสำหรับสัปดาห์หน้า'));
        }

        return ListView.builder(
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final taskData = filteredTasks[index] as Map<String, dynamic>;
            String task = taskData['task'] ?? '';
            String priority = taskData['priority'] ?? '';
            String time = taskData['time'] ?? '';
            Timestamp? deadline = taskData['deadline'];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: 5,
              child: ListTile(
                title:
                    Text(task, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Priority: $priority\nTime: $time\nDeadline: ${deadline != null ? DateFormat('yyyy-MM-dd').format(deadline.toDate()) : 'ไม่มีการกำหนด'}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsScreen(
                        taskData: taskData,
                        userEmail: userEmail,
                        taskId: taskData['taskId'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
