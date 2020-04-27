import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

class Lobby extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (final BuildContext inContext, Widget inChild,
            FlutterChatModel inModel) {
          return Scaffold(
            appBar: AppBar(title: Text("Lobby")),
            drawer: AppDrawer(),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(inContext, "/CreateRoom");
              },
            ),
            body: model.roomList.length == 0
                ? Text("There are no rooms, why not create one?")
                : ListView.builder(
                    itemCount: model.roomList.length,
                    itemBuilder: (BuildContext inBuildContext, int index) {
                      Map room = model.roomList[index];

                      String roomName = room["roomName"];

                      return Column(
                        children: <Widget>[
                          ListTile(
                            leading: room["private"]
                                ? Image.asset("assets/private.png")
                                : Image.asset("assets/public.png"),
                            title: Text(roomName),
                            subtitle: Text(room["description"]),
                            onTap: () {
                              if (room["private"] &&
                                  !model.roomInvites.containsKey(roomName) &&
                                  room["creator" != model.userName]) {
                                Scaffold.of(inBuildContext)
                                    .showSnackBar(SnackBar(
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                  content: Text(
                                      "Sorry, you cannot enter a private room without an invite."),
                                ));
                              } else {
                                connector.join(model.userName, roomName,
                                    (inStatus, inRoomDescriptor) {
                                  if (inStatus == "join") {
                                    model.setCurrentRoomName(
                                        inRoomDescriptor["roomName"]);

                                    model.setCurrentRoomUserList(
                                        inRoomDescriptor["users"]);

                                    model.setCurrentRoomEnabled(true);
                                    model.clearCurrentRoomMessages();

                                    if (inRoomDescriptor["creator"] ==
                                        model.userName) {
                                      model.setCreatorFunctionsEnabled(true);
                                    } else {
                                      model.setCreatorFunctionsEnabled(false);
                                    }

                                    Navigator.pushNamed(inContext, "/Room");
                                  } else if (inStatus == "full") {
                                    Scaffold.of(inBuildContext)
                                        .showSnackBar(SnackBar(
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.red,
                                      content: Text("Sorry, room is full."),
                                    ));
                                  }
                                });
                              }
                            },
                          )
                        ],
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
