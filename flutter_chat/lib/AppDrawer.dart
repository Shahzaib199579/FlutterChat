import 'package:flutter/material.dart';
import 'package:flutterchat/Connector.dart' as connector;
import 'package:flutterchat/Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder:
            (BuildContext inContext, Widget inChild, FlutterChatModel inModle) {
          return Drawer(
            child: Column(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/drawback01.jpg"))),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 30, 0, 15),
                      child: ListTile(
                        title: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: Center(
                            child: Text(model.userName,
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 24)),
                          ),
                        ),
                        subtitle: Center(
                          child: Text(model.currentRoom,
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ListTile(
                    leading: Icon(Icons.list),
                    title: Text("Lobby"),
                    onTap: () {
                      Navigator.of(model.rootBuildContext)
                          .pushNamedAndRemoveUntil(
                              "/Lobby", ModalRoute.withName("/"));

                      connector.listRooms((inRoomList) {
                        model.setRoomList(inRoomList);
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.face),
                  title: Text("User List"),
                  onTap: () {
                    Navigator.of(model.rootBuildContext)
                        .pushNamedAndRemoveUntil(
                            "/UserList", ModalRoute.withName("/"));

                    connector.listUsers((inUserList) {
                      model.setUserList(inUserList);
                    });
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
