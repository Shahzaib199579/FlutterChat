import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class FlutterChatModel extends Model {
  BuildContext rootBuildContext;

  Directory docsDir;

  String greetings = "";

  String userName = "";

  static final String DEFAULT_ROOM_NAME = "Not currently in a room";

  String currentRoom = DEFAULT_ROOM_NAME;

  List currentRoomUserList = [];

  bool currentRoomEnabled = false;

  List currentRoomMessages = [];

  List roomList = [];

  List userList = [];

  bool creatorFunctionsEnabled = false;

  Map roomInvites = {};

  void setGreeting(final String inGreeting) {
    greetings = inGreeting;
    notifyListeners();
  }

  void setUserName(final String inUserName) {
    userName = inUserName;
    notifyListeners();
  }

  void setCurrentRoomName(final String inCurrentRoomName) {
    currentRoom = inCurrentRoomName;
    notifyListeners();
  }

  void setCreatorFunctionsEnabled(final bool isEnabled) {
    creatorFunctionsEnabled = isEnabled;
    notifyListeners();
  }

  void setCurrentRoomEnabled(final bool isEnabled) {
    currentRoomEnabled = isEnabled;
    notifyListeners();
  }

  void addMessage(final String inUsername, final String inMessage) {
    currentRoomMessages.add({"userName": inUsername, "message": inMessage});
    notifyListeners();
  }

  void setRoomList(final Map inRoomList) {
    List rooms = [];
    for (String roomName in inRoomList.keys) {
      Map room = inRoomList[roomName];
      rooms.add(room);
    }

    roomList = rooms;
    notifyListeners();
  }

  void setUserList(final Map inUserList) {
    List users = [];

    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }

    userList = users;
    notifyListeners();
  }

  void setCurrentRoomUserList(final Map inUserList) {
    List users = [];
    for (String userName in inUserList.keys) {
      Map user = inUserList[userName];
      users.add(user);
    }

    currentRoomUserList = users;
    notifyListeners();
  }

  void addRoomInvite(final String inRoomName) {
    roomInvites[inRoomName] = true;
  }

  void removeRoomInvite(final String inRoomName) {
    roomInvites.remove(inRoomName);
  }

  void clearCurrentRoomMessages() {
    currentRoomMessages = [];
  }
}

FlutterChatModel model = FlutterChatModel();
