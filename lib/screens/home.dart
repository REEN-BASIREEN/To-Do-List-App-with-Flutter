import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:to_do_list/screens/addtask.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list/screens/auth.dart';
import 'package:to_do_list/screens/taskdetail.dart';
import 'package:to_do_list/screens/todaytask.dart';
import 'package:to_do_list/screens/nextweektask.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showGif = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/6/6d/Todoist_logo.png',
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error, color: Colors.red);
          },
        ),
        backgroundColor: Color.fromRGBO(162, 128, 93, 1.0),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              String userId = FirebaseAuth.instance.currentUser!.uid;
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text("parnjai"),
              accountEmail: Text("0/5"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://i.pinimg.com/550x/13/d9/7d/13d97d540be78ef119a9e357b76816a1.jpg"),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(220, 72, 72, 1.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.inbox),
              title: Text("Inbox"),
              trailing: Text("2"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.today),
              title: Text("วันนี้"),
              trailing: Text("2"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodayTasksScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("สัปดาห์หน้า"),
              trailing: Text("2"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NextWeekTasksScreen()),
                );
              },
            ),
            ExpansionTile(
              leading: Icon(Icons.folder),
              title: Text("Projects"),
              children: <Widget>[
                ListTile(
                  title: Text("Project 1"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Project 2"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.label),
              title: Text("Labels"),
              children: <Widget>[
                ListTile(
                  title: Text("Label 1"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Label 2"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ExpansionTile(
              leading: Icon(Icons.filter_list),
              title: Text("Filters"),
              children: <Widget>[
                ListTile(
                  title: Text("Filter 1"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text("Filter 2"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(218, 198, 163, 1.0),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (userSnapshot.hasError) {
                  return Center(child: Text('Error: ${userSnapshot.error}'));
                }
                if (!userSnapshot.hasData) {
                  return Center(child: Text('User not logged in!'));
                }

                String? userEmail = userSnapshot.data?.email;

                Stream<DocumentSnapshot> tasksStream = FirebaseFirestore
                    .instance
                    .collection('tasks')
                    .doc(userEmail)
                    .snapshots();

                return StreamBuilder<DocumentSnapshot>(
                  stream: tasksStream,
                  builder: (context, tasksSnapshot) {
                    if (tasksSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${tasksSnapshot.error}'));
                    }

                    if (tasksSnapshot.hasData && tasksSnapshot.data!.exists) {
                      Map<String, dynamic> tasks =
                          tasksSnapshot.data?['tasks'] ?? {};

                      if (tasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.list_alt,
                                  size: 80,
                                  color: Color.fromRGBO(162, 128, 93, 1.0)),
                              SizedBox(height: 20),
                              Text(
                                'ยังไม่มีงาน!',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromRGBO(162, 128, 93, 1.0)),
                              ),
                              SizedBox(height: 10),
                              Text('เพิ่มงานแรกของคุณโดยการกดปุ่ม +.',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          String taskId = tasks.keys.elementAt(index);
                          Map<String, dynamic> taskData = tasks[taskId];
                          String task = taskData['task'] ?? '';
                          String priority = taskData['priority'] ?? '';
                          String time = taskData['time'] ?? '';
                          String date = taskData['date'] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailsScreen(
                                      taskData: taskData,
                                      userEmail: userEmail!,
                                      taskId: taskId,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: Colors.white,
                                child: ListTile(
                                  leading: Icon(
                                    taskData['isCompleted']
                                        ? Icons.check_circle
                                        : Icons.circle,
                                    color: taskData['isCompleted']
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 30,
                                  ),
                                  title: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      task,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          decoration: taskData['isCompleted']
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none),
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      'Priority: $priority\nTime: $time\nDate: $date',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                            taskData['isCompleted']
                                                ? Icons.undo
                                                : Icons.check,
                                            color: Colors.green),
                                        onPressed: () async {
                                          final action = taskData['isCompleted']
                                              ? 'ยกเลิกการทำเครื่องหมายสำเร็จ'
                                              : 'ทำเครื่องหมายว่างานสำเร็จ';
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text('ยืนยันการทำงาน'),
                                                content: Text(
                                                    'คุณแน่ใจหรือไม่ที่จะ $action?'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('ยกเลิก'),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                  ),
                                                  TextButton(
                                                    child: Text('ยืนยัน'),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm == true) {
                                            await FirebaseFirestore.instance
                                                .collection('tasks')
                                                .doc(userEmail)
                                                .update({
                                              'tasks.$taskId.isCompleted':
                                                  !taskData['isCompleted'],
                                            });
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final db = FirebaseFirestore.instance;
                                          final tasksCollection = db
                                              .collection('tasks')
                                              .doc(userEmail);
                                          await tasksCollection.update({
                                            'tasks.$taskId':
                                                FieldValue.delete(),
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return Center(child: CircularProgressIndicator());
                  },
                );
              },
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddTaskScreen()),
                  );
                },
                backgroundColor: Color.fromRGBO(162, 128, 93, 1.0),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
