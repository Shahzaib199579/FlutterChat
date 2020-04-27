import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'CreateRoom.dart';
import 'Home.dart';
import 'Lobby.dart';
import 'Model.dart' show model, FlutterChatModel;
import 'package:path/path.dart';
import 'LoginDialog.dart';
import 'Room.dart';
import 'UserList.dart';

var credentials;
var exists;

void main() {
  startMeUp() async {

    Directory docsDir;

    try {
      WidgetsFlutterBinding.ensureInitialized();
      PermissionStatus permissionResult =
      await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);

      if (permissionResult == PermissionStatus.authorized) {
      docsDir = await getApplicationDocumentsDirectory();
      } else {
        throw Exception("Error");
      }
    } catch (e) {
      print(e);
    }

    model.docsDir = docsDir;

    var credentialsFile = File(join(model.docsDir.path, "credentials"));

    exists = credentialsFile.existsSync();

    if (exists) {
      credentials = await credentialsFile.readAsString();
    }

    runApp(FlutterChat());
  }
  startMeUp();
}

class FlutterChat extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


//    model.rootBuildContext = context;
//
//    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());


//    return ScopedModel<FlutterChatModel>(
//      model: model,
//      child: ScopedModelDescendant<FlutterChatModel>(
//        builder: (BuildContext buildContext, Widget inChild,
//            FlutterChatModel inModel) {
//          return MaterialApp(
//            initialRoute: "/",
//            routes: {
//              "/Lobby": (screenContext) => Lobby(),
//              "/Room": (screenContext) => Room(),
//              "/UserList": (screenContext) => UserList(),
//              "/CreateRoom": (screenContext) => CreateRoom()
//            },
//            home: Home(),
//          );
//        },
//      ),
//    );

    return MaterialApp(
      initialRoute: "/",
      routes: {
        "/Lobby": (screenContext) => Lobby(),
        "/Room": (screenContext) => Room(),
        "/UserList": (screenContext) => UserList(),
        "/CreateRoom": (screenContext) => CreateRoom()
      },
      home: FlutterChatMain(),
    );
}

//  Future<void> executeAfterBuild() async {
//    if (exists) {
//      List credParts = credentials.split("============");
//
//      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
//    } else {
//      await showDialog(
//          context: model.rootBuildContext,
//          barrierDismissible: false,
//          builder: (BuildContext inDialogContext) {
//            return LoginDialog();
//          });
//    }
//  }
}

class FlutterChatMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    model.rootBuildContext = context;

    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());


    return ScopedModel<FlutterChatModel>(
      model: model,
      child: ScopedModelDescendant<FlutterChatModel>(
        builder: (BuildContext buildContext, Widget inChild,
            FlutterChatModel inModel) {
          return MaterialApp(
//            initialRoute: "/",
//            routes: {
//              "/Lobby": (screenContext) => Lobby(),
//              "/Room": (screenContext) => Room(),
//              "/UserList": (screenContext) => UserList(),
//              "/CreateRoom": (screenContext) => CreateRoom()
//            },
            home: Home(),
          );
        },
      ),
    );
  }

  Future<void> executeAfterBuild() async {
    if (exists) {
      List credParts = credentials.split("============");

      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
    } else {
      await showDialog(
          context: model.rootBuildContext,
          barrierDismissible: false,
          builder: (BuildContext inDialogContext) {
            return LoginDialog();
          });
    }
  }
}
