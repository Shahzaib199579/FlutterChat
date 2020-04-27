import 'package:flutter/material.dart';
import 'package:flutterchat/AppDrawer.dart';
import 'package:flutterchat/Model.dart' show FlutterChatModel, model;
import 'package:scoped_model/scoped_model.dart';
import 'Connector.dart' as connector;

class Room extends StatefulWidget {

  Room({Key key}) : super(key: key);
  
  @override
  _Room createState() => _Room();

}

class _Room extends State<Room> {
  bool _expanded = false;
  String _postMessage;
  final ScrollController _controller = ScrollController();
  final TextEditingController _postEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (BuildContext inBuilderContext, Widget inChild, FlutterChatModel inModel) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text(model.currentRoom),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: (inValue) {
                    if (inValue == "invite") {
                      _inviteOrKick(inBuilderContext, "invite");
                    } else if (inValue == "leave") {

                      connector.leave(model.userName, model.currentRoom, () {
                        model.removeRoomInvite(model.currentRoom);
                        model.setCurrentRoomUserList({});
                        model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
                        model.setCurrentRoomEnabled(false);

                        Navigator.of(inBuilderContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                      });
                    } else if (inValue == "close") {
                      connector.close(model.currentRoom, () {
                        Navigator.of(inBuilderContext).pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
                      });
                    } else if (inValue == "kick") {
                      _inviteOrKick(inBuilderContext, "kick");
                    }
                  },
                  itemBuilder: (BuildContext inPMBContext) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem(value: "leave", child: Text("Leave Room")),
                      PopupMenuItem(value: "invite", child: Text("Invite A User")),
                      PopupMenuDivider(),
                      PopupMenuItem(value: "close", child: Text("Close Room"), enabled: model.creatorFunctionsEnabled),
                      PopupMenuItem(value: "kick", child: Text("Kick User"), enabled: model.creatorFunctionsEnabled),
                    ];
                  },
                )
              ],
            ),
            drawer: AppDrawer(),
            body: Padding(
              padding: EdgeInsets.fromLTRB(6, 14, 6, 6),
              child: Column(
                children: <Widget>[
                  ExpansionPanelList(expansionCallback: (index, inExpanded) {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      isExpanded: _expanded,
                      headerBuilder: (BuildContext context, bool isExpanded) => Text(" Users in Room"),
                      body: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Builder(builder: (inBuilderContext) {
                          List<Widget> userList = [];

                          for (var user in model.currentRoomUserList) {
                            userList.add(Text(user["userName"]));
                          }

                          return Column(children: userList);
                        },),
                      )
                    )
                  ],),
                  Container(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: model.currentRoomMessages.length,
                      itemBuilder: (inContext, index) {
                        Map message = model.currentRoomMessages[index];

                        return ListTile(
                          title: Text(message["message"]),
                          subtitle: Text(message["userName"]),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          controller: _postEditingController,
                          onChanged: (value) {
                            setState(() {
                              _postMessage = value;
                            });
                          },
                          decoration: new InputDecoration.collapsed(hintText: "Enter Message"),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(2, 0, 2, 0),
                        child: IconButton(
                          icon: Icon(Icons.send),
                          color: Colors.blue,
                          onPressed: () {

                            connector.post(model.userName, model.currentRoom, _postMessage, (inStatus) {
                              if (inStatus == "ok") {
                                model.addMessage(model.userName, _postMessage);

                                _controller.jumpTo(_controller.position.maxScrollExtent);
                              }
                            });
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _inviteOrKick(BuildContext buildContext, String inviteOrKick) {
    
    connector.listUsers((inUserList) {
      model.setUserList(inUserList);

      showDialog(
        context: buildContext,
        builder: (BuildContext inDialogContext) {
          return ScopedModel<FlutterChatModel>(
            model: model,
            child: ScopedModelDescendant<FlutterChatModel>(
              builder: (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
                return AlertDialog(
                  title: Text("Set user to $inviteOrKick"),
                  content: Container(
                    width: double.maxFinite,
                    height: double.maxFinite / 2,
                    child: ListView.builder(
                      itemCount: inviteOrKick == "invite" ? model.userList.length : model.currentRoomUserList. length,
                      itemBuilder: (BuildContext inBuildContext, int index) {
                        Map user;

                        if (inviteOrKick == "invite") {
                          user = model.userList[index];
                        } else {
                          user = model.currentRoomUserList[index];
                        }

                        if (user["userName"] == model.userName) {
                          return Container();
                        }

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border(
                              left: BorderSide(),
                              top: BorderSide(),
                              right: BorderSide(),
                              bottom: BorderSide()
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [ .1, .2, .3, .4, .5, .6, .7, .8, .9],
                              colors: [Color.fromRGBO(250, 250, 0, .75), Color.fromRGBO(250, 220, 0, .75),
                                Color.fromRGBO(250, 190, 0, .75), Color.fromRGBO(250, 160, 0, .75),
                                Color.fromRGBO(250, 130, 0, .75), Color.fromRGBO(250, 110, 0, .75),
                                Color.fromRGBO(250, 80, 0, .75), Color.fromRGBO(250, 50, 0, .75),
                                Color.fromRGBO(250, 0, 0, .75)]
                            )
                          ),
                          margin: EdgeInsets.only(top: 10),
                          child: ListTile(
                            title: Text(user["userName"]),
                            onTap: () {
                              if (inviteOrKick == "invite") {
                                connector.invite(user["userName"], model.currentRoom, model.userName, () {
                                  // Hide user selection dialog.
                                  Navigator.of(inContext).pop();
                                });
                              } else {
                                connector.kick(user["userName"], model.currentRoom, () {
                                  // Hide user selection dialog.
                                  Navigator.of(inContext).pop();
                                });
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
      );
    });
  }

}