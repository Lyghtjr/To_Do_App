import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskTxtController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Color primaryColor = Color(0xFF00F58D);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User user;
  @override
  void initState() {
    // TODO: implement initState
    getUid();
    super.initState();
  }

  void getUid() async {
    User u = await _auth.currentUser;
    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddtaskDialog();
          },
          child: Icon(Icons.add),
          elevation: 4,
          backgroundColor: primaryColor,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.menu),
                  ),
                  IconButton(
                    onPressed: () {
                      _auth.signOut();
                    },
                    icon: Icon(Icons.person_outline),
                  )
                ])),
                appBar: AppBar(title: Text("To Do App"),),
        body: Container(
        
          margin: EdgeInsets.only(top: 20),
          child: StreamBuilder(
            stream: _db
                .collection("users")
                .doc(user.uid)
                .collection("tasks")
                .orderBy("date", descending: true)
                .snapshots(),
            builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.docs.isNotEmpty) {
                  return ListView(
                      children: snapshot.data.docs.map((snap) {
                    return ListTile(
                      title: Text(snap.get("task")),
                      onTap: () {},
                      trailing: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _db
                                .collection("users")
                                .doc(user.uid)
                                .collection("tasks")
                                .doc(snap.id)
                                .delete();
                          }),
                    );
                  }).toList());
                } else {
                  return Container(
                    child: Center(
                      child: Image(
                        image: AssetImage("assets/no_task.png"),
                      ),
                    ),
                  );
                }
              }
              return Container();
            },
          ),
        ));
  }

  void _showAddtaskDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text("Add Task"),
            children: [
              Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: _taskTxtController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Write your Task Here",
                      labelText: "Task Name",
                    ),
                  )),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    FlatButton(
                      onPressed: () {
                      
                        Navigator.of(ctx).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        String task = _taskTxtController.text.trim();

                        _db
                            .collection("users")
                            .doc(user.uid)
                            .collection("tasks")
                            .add({"task": task, "date": DateTime.now()});

                        Navigator.of(ctx).pop();
                      },
                      child: Text("Add"),
                    )
                  ],
                ),
              )
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        });
  }
}
