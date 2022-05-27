import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'newpage.dart';
import 'Contactmodal.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iconly/iconly.dart';

const String boxname = 'contactbox';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final document1 = await getApplicationDocumentsDirectory();
  Hive.init(document1.path);
  Hive.registerAdapter(ContactmodalAdapter());
  await Hive.openBox<Contactmodal>(boxname);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CONTACT APP',
      theme: ThemeData(primaryColor: Colors.blue),
      home: const Contactapp(),
    );
  }
}

class Contactapp extends StatefulWidget {
  const Contactapp({Key? key}) : super(key: key);

  @override
  State<Contactapp> createState() => _ContactappState();
}

class _ContactappState extends State<Contactapp> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<String> str = ["AMARJIT"];

  Box<Contactmodal>? box_contact;

  String name1 = '';
  String number1 = '';

  TextEditingController _namefieldcontroller = TextEditingController();
  TextEditingController _phonfieldcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    box_contact = Hive.box<Contactmodal>(boxname);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact App")),
      body: Column(
        children: [
          /*ListView.builder(itemCount: str.length,itemBuilder: (cnt,ind){
              return ListTile(
                title: Text(str[ind]),
              );
          })*/
          ValueListenableBuilder(
            valueListenable: box_contact!.listenable(),
            builder: (context, Box<Contactmodal> todos, _) {
              List<int> keys = todos.keys.cast<int>().toList();
              return ListView.separated(
                itemBuilder: (_, index) {
                  final int key = keys[index];
                  final Contactmodal todo = todos.get(key) as Contactmodal;

                  return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(todo.name),
                          PopupMenuButton(
                            onSelected: (item) {
                              switch (item) {
                                case 'update':
                                  _namefieldcontroller.text = todo.name;
                                  _phonfieldcontroller.text = todo.phone;

                                  break;
                                case 'delete':
                                  todos.deleteAt(index);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ];
                            },
                          ),
                          Icon(
                            Icons.phone,
                            color: Colors.greenAccent[700],
                          ),
                        ],
                      ),
                      subtitle: Text(todo.phone),
                      leading: Stack(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 42,
                            color: Colors.blue[600],
                          ),
                          Icon(Icons.person, color: Colors.yellow)
                        ],
                        alignment: Alignment.center,
                      ));
                },
                separatorBuilder: (_, index) => Divider(),
                itemCount: keys.length,
                shrinkWrap: true,
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (cnt) {
              return AlertDialog(
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(primary: Colors.green),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("CANCEL")),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.green),
                              onPressed: () {
                                name1 = _namefieldcontroller.text;
                                number1 = _phonfieldcontroller.text;

                                Contactmodal modal =
                                    Contactmodal(name: name1, phone: number1);
                                box_contact!.add(modal);

                                Navigator.pop(context);

                                /* setState() {
                              str.add(_namefieldcontroller.text);
                            }*/
                              },
                              child: Text("ADD")),
                        )
                      ],
                    ),
                  ],
                  title: Text("Add new contact"),
                  content: Form(
                    key: _formkey,
                    child: Container(
                      height: 150,
                      child: Column(
                        children: [
                          TextFormField(
                              keyboardType: TextInputType.text,
                              controller: _namefieldcontroller,
                              decoration: InputDecoration(
                                hintText: 'Name',
                              )),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
                                  .hasMatch(value)) {
                                return "Please Enter a Valid Phone Number";
                              }
                            },
                            keyboardType: TextInputType.number,
                            controller: _phonfieldcontroller,
                            decoration:
                                InputDecoration(hintText: 'Phone Number'),
                          )
                        ],
                      ),
                    ),
                  ));
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
