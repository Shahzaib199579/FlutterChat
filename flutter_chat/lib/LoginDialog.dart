import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutterchat/Connector.dart';
import 'package:flutterchat/Model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;
import 'package:path/path.dart' as path;

class LoginDialog extends StatelessWidget {
  static final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

  String _username;
  String _password;

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (BuildContext inBuildContext, Widget inChild,
            FlutterChatModel inModel) {
          return AlertDialog(
            content: Container(
              height: 220,
              child: Form(
                key: _loginFormKey,
                child: Column(
                  children: <Widget>[
                    Text(
                        "Enter a username and password to register with server",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(model.rootBuildContext).accentColor,
                            fontSize: 18)),
                    SizedBox(height: 20),
                    TextFormField(
                      validator: (String inValue) {
                        if (inValue.length == 0 || inValue.length > 10) {
                          return "Please enter a username no more than 10 characters long";
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        _username = value;
                      },
                      decoration: InputDecoration(
                          hintText: "Username", labelText: "Username"),
                    ),
                    TextFormField(
                      obscureText: true,
                      validator: (String inValue) {
                        if (inValue.length == 0) {
                          return "Please enter a password";
                        }

                        return null;
                      },
                      onSaved: (String value) {
                        _password = value;
                      },
                      decoration: InputDecoration(
                          hintText: "Password", labelText: "Password"),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Log In"),
                onPressed: () {
                  if (_loginFormKey.currentState.validate()) {
                    _loginFormKey.currentState.save();

                    connector.connectToServer(() {
                      connector.validate(_username, _password,
                          (inStatus) async {
                        if (inStatus == "ok") {
                          model.setUserName(_username);

                          Navigator.of(model.rootBuildContext).pop();

                          model.setGreeting("Welcome back, $_username!");
                        } else if (inStatus == "fail") {
                          Scaffold.of(model.rootBuildContext)
                              .showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                            content:
                                Text("Sorry that username is already taken."),
                          ));
                        } else if (inStatus == "created") {
                          var credentialsFile = File(
                              path.join(model.docsDir.path, "credentials"));

                          await credentialsFile.writeAsString(
                              "$_username============$_password");

                          model.setUserName(_username);

                          Navigator.of(model.rootBuildContext).pop();

                          model.setGreeting("Welcome to server, $_username!");
                        }
                      });
                    });
                  }
                },
              )
            ],
          );
        },
      ),
    );
  }

  void validateWithStoredCredentials(
      final String inUsername, final String inPassword) {
    connector.connectToServer(() {
      connector.validate(inUsername, inPassword, (inStatus) async {
        if (inStatus == "ok" || inStatus == "created") {
          model.setUserName(inUsername);

          model.setGreeting("Welcome back, $inUsername");
        } else if (inStatus == "fail") {
          showDialog(
              context: model.rootBuildContext,
              barrierDismissible: false,
              builder: (final BuildContext inDialogContext) {
                return AlertDialog(
                  title: Text("Validation Failed"),
                  content: Text(
                      "It appears server was restarted and your username was taken by someone else."
                      "\n\nPlease restart the application and choose a new username"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: () {
                        var credentialsFile =
                            File(path.join(model.docsDir.path, "credentials"));
                        credentialsFile.deleteSync();

                        exit(0);
                      },
                    )
                  ],
                );
              });
        }
      });
    });
  }
}
