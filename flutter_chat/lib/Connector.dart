import 'dart:convert';

import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'Model.dart';
import 'package:flutter/material.dart';

String serverURL = "http://10.0.2.2";

SocketIO _io;

void showPleaseWait() {
  showDialog(
      context: model.rootBuildContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 150,
            height: 150,
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(color: Colors.blue[200]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text("Please wait, contacting server...",
                        style: new TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      });
}

void hidePleaseWait() {
  Navigator.of(model.rootBuildContext).pop();
}

void connectToServer(final Function inCallback) {

  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "",
      socketStatusCallback: (inData) {
    if (inData == "connect") {
      _io.subscribe("newUser", newUser);
      _io.subscribe("created", created);
      _io.subscribe("closed", closed);
      _io.subscribe("joined", joined);
      _io.subscribe("left", left);
      _io.subscribe("kicked", kicked);
      _io.subscribe("invited", invited);
      _io.subscribe("posted", posted);

      inCallback();
    }
  });

  _io.destroy();
  _io = SocketIOManager().createSocketIO(serverURL, "/", query: "",
      socketStatusCallback: (inData) {
    if (inData == "connect") {
      inCallback();
    }
  });

  _io.init();
  _io.connect();
}

void validate(
    final String inUsername, final String inPassword, final Function callback) {
  showPleaseWait();

  _io.sendMessage("validate",
      "{ \"userName\": \"$inUsername\", \"password\": \"$inPassword\"}",
      (inData) {
    Map<String, dynamic> response = jsonDecode(inData);

    hidePleaseWait();

    callback(response["status"]);
  });
}

void listRooms(final Function callback) {
  showPleaseWait();

  _io.sendMessage("listRooms", "{}", (inData) {
    Map<String, dynamic> response = jsonDecode(inData);
    hidePleaseWait();

    callback(response);
  });
}

void create(
    final String inRoomName,
    final String inDescription,
    final int inMaxPeople,
    final bool inPrivate,
    final String inCreator,
    final Function callback) {
  showPleaseWait();

  _io.sendMessage(
      "create",
      "{ \"roomName\": \"$inRoomName\", \"description\": \"$inDescription\","
          "\"maxPeople\": $inMaxPeople, \"private\": $inPrivate, \"creator\": \"$inCreator\"}",
      (inData) {
    Map<String, dynamic> response = jsonDecode(inData);

    hidePleaseWait();

    callback(response["status"], response["rooms"]);
  });
}

void join(final String inUserName, final String inRoomName,
    final Function inCallback) {
  print(
      "## Connector.join(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("join",
      "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\"}",
      (inData) {
    print("## Connector.join(): callback: inData = $inData");
    // Parse response JSON string into a Map.
    Map<String, dynamic> response = jsonDecode(inData);
    print("## Connector.join(): callback: response = $response");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback(response["status"], response["room"]);
  });
}

void leave(final String inUserName, final String inRoomName,
    final Function inCallback) {
  print(
      "## Connector.leave(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("leave",
      "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\"}",
      (inData) {
    print("## Connector.leave(): callback: inData = $inData");
    // Parse response JSON string into a Map.
    Map<String, dynamic> response = jsonDecode(inData);
    print("## Connector.listUsers(): callback: response = $response");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

void listUsers(final Function inCallback) {
  print("## Connector.listUsers()");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("listUsers", "{}", (inData) {
    print("## Connector.listUsers(): callback: inData = $inData");
    // Parse response JSON string into a Map.
    Map<String, dynamic> response = jsonDecode(inData);
    print("## Connector.listUsers(): callback: response = $response");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback(response);
  });
}

void invite(final String inUserName, final String inRoomName,
    final String inInviterName, final Function inCallback) {
  print(
      "## Connector.invite(): inUserName = $inUserName, inRoomName = $inRoomName, inInviterName = $inInviterName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage(
      "invite",
      "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\", "
          "\"inviterName\" : \"$inInviterName\" }", (inData) {
    print("## Connector.invite(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

void post(final String inUserName, final String inRoomName,
    final String inMessage, final Function inCallback) {
  print(
      "## Connector.post(): inUserName = $inUserName, inRoomName = $inRoomName, inMessage = $inMessage");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage(
      "post",
      "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\", "
          "\"message\" : \"$inMessage\" }", (inData) {
    print("## Connector.post(): callback: inData = $inData");
    // Parse response JSON string into a Map.
    Map<String, dynamic> response = jsonDecode(inData);
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback(response["status"]);
  });
}

void close(final String inRoomName, final Function inCallback) {
  print("## Connector.close(): inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("close", "{ \"roomName\" : \"$inRoomName\" }", (inData) {
    print("## Connector.close(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

void kick(final String inUserName, final String inRoomName,
    final Function inCallback) {
  print(
      "## Connector.kick(): inUserName = $inUserName, inRoomName = $inRoomName");

  // Block screen while we call server.
  showPleaseWait();

  // Call server to create the room.
  _io.sendMessage("kick",
      "{ \"userName\" : \"$inUserName\", \"roomName\" : \"$inRoomName\" }",
      (inData) {
    print("## Connector.kick(): callback: inData = $inData");
    // Hide please wait.
    hidePleaseWait();
    // Call the specified callback, passing it the response.
    inCallback();
  });
}

void newUser(inData) {
  print("## Connector.newUser(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.newUser(): payload = $payload");

  model.setUserList(payload);
}

void created(inData) {
  print("## Connector.created(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.created(): payload = $payload");

  model.setRoomList(payload);
}

void closed(inData) {
  print("## Connector.closed(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.closed(): payload = $payload");

  model.setRoomList(payload);

  // If this user is in the room, boot 'em! (oh, also, be nice and tell 'em what happened).
  if (payload["roomName"] == model.currentRoom) {
    // Clear the model attributes reflecting the user in this room.
    model.removeRoomInvite(payload["roomName"]);
    model.setCurrentRoomUserList({});
    model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
    model.setCurrentRoomEnabled(false);
    // Tell the user the room was closed.
    model.setGreeting("The room you were in was closed by its creator.");
    // Route back to the home screen.
    Navigator.of(model.rootBuildContext)
        .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
  }
}

void joined(inData) {
  print("## Connector.joined(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.joined(): payload = $payload");

  // Update the list of users in the room if this user is in the room.
  if (model.currentRoom == payload["roomName"]) {
    model.setCurrentRoomUserList(payload["users"]);
  }
}

void left(inData) {
  print("## Connector.left(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.left(): payload = $payload");

  // Update the list of users in the room if this user is in the room.
  if (model.currentRoom == payload["room"]["roomName"]) {
    model.setCurrentRoomUserList(payload["room"]["users"]);
  }
}

void kicked(inData) {
  print("## Connector.kicked(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.kicked(): payload = $payload");

  // Clear the model attributes reflecting the user in this room.
  model.removeRoomInvite(payload["roomName"]);
  model.setCurrentRoomUserList({});
  model.setCurrentRoomName(FlutterChatModel.DEFAULT_ROOM_NAME);
  model.setCurrentRoomEnabled(false);

  // Tell the user they got the boot.
  model.setGreeting("What did you do?! You got kicked from the room! D'oh!");

  // Route back to the home screen.
  Navigator.of(model.rootBuildContext)
      .pushNamedAndRemoveUntil("/", ModalRoute.withName("/"));
}

void invited(inData) async {
  print("## Connector.invited(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.invited(): payload = $payload");

  // Grab necessary data from payload.
  String roomName = payload["roomName"];
  String inviterName = payload["inviterName"];

  // Add the invite to the model.
  model.addRoomInvite(roomName);

  // Show snackbar to alert the user about the invite.
  Scaffold.of(model.rootBuildContext).showSnackBar(SnackBar(
      backgroundColor: Colors.amber,
      duration: Duration(seconds: 60),
      content: Text(
          "You've been invited to the room '$roomName' by user '$inviterName'.\n\n"
          "You can enter the room from the lobby."),
      action: SnackBarAction(label: "Ok", onPressed: () {})));
}

void posted(inData) {
  print("## Connector.posted(): inData = $inData");

  // Parse response JSON string into a Map.
  Map<String, dynamic> payload = jsonDecode(inData);
  print("## Connector.posted(): payload = $payload");

  // If the user is currently in the room then add message to room's message list.
  if (model.currentRoom == payload["roomName"]) {
    model.addMessage(payload["userName"], payload["message"]);
  }
}
