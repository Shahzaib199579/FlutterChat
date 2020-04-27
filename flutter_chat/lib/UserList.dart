import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';

class UserList extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (BuildContext inBuildContext, Widget inChild, FlutterChatModel inModel) {
          return Scaffold(
            appBar: AppBar(title: Text("User List")),
            drawer: AppDrawer(),
            body: GridView.builder(
                itemCount: model.userList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                itemBuilder: (BuildContext inBuilderContext, int index) {
                  Map user = model.userList[index];

                  return Padding(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: GridTile(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: Image.asset("assets/user.png"),
                            ),
                          ),
                          footer: Text(user["userName"], textAlign: TextAlign.center)
                        ),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
    );
  }

}