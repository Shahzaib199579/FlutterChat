import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

class CreateRoom extends StatefulWidget {
  CreateRoom({Key key}) : super(key: key);

  @override
  _CreateRoom createState() => _CreateRoom();
}

class _CreateRoom extends State {
  String _title;
  String _description;
  bool _private = false;
  double _maxPeople = 25;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (BuildContext inBuildContext, Widget inChild,
            FlutterChatModel inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: Text("Create Room")),
            drawer: AppDrawer(),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: SingleChildScrollView(
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        FocusScope.of(inBuildContext).requestFocus(FocusNode());
                        Navigator.of(inBuildContext).pop();
                      },
                    ),
                    Spacer(),
                    FlatButton(
                      child: Text("Save"),
                      onPressed: () {
                        if (!_formKey.currentState.validate()) {
                          return;
                        }

                        _formKey.currentState.save();
                        int maxPeople = _maxPeople.truncate();

                        connector.create(_title, _description, maxPeople,
                            _private, model.userName, (inStatus, roomsList) {
                          if (inStatus == "created") {
                            model.setRoomList(roomsList);
                            FocusScope.of(inBuildContext)
                                .requestFocus(FocusNode());
                            Navigator.of(inBuildContext).pop();
                          } else {
                            Scaffold.of(inBuildContext).showSnackBar(SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                              content: Text("Sorry, that room already exists."),
                            ));
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Name"),
                      validator: (String value) {
                        if (value.length == 0 || value.length > 14) {
                          return "Please enter a name no more than 14 characters long";
                        }

                        return null;
                      },
                      onSaved: (String inValue) {
                        setState(() {
                          _title = inValue;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Description"),
                      onSaved: (String inValue) {
                        setState(() {
                          _description = inValue;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Text("Max People:"),
                        Slider(min: 2,
                                max: 99,
                                value: _maxPeople,
                                onChanged: (double value) {
                                    setState(() {
                                      _maxPeople = value;
                                    });
                                },
                        )
                      ],
                    ),
                    trailing: Text(_maxPeople.toStringAsFixed(0)),
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        Text("Private: "),
                        Switch(
                          value: _private,
                          onChanged: (value) {
                            setState(() {
                              _private = value;
                            });
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
