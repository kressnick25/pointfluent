import 'package:Pointfluent/widgets/RecentModels.dart';
import 'package:Pointfluent/widgets/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:vaultSDK/udManager.dart';

import '../widgets/ErrorMsg.dart';
import '../auth/sceneViewer.dart';

class HomePage extends StatefulWidget {
  final UdManager udManager;

  HomePage({Key key, this.udManager}) : super(key: key);
  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ErrorMsg _error;
  bool logoutLoading;
  static const double marginTop = 12;

  @override
  void initState() {
    _error = ErrorMsg();
    logoutLoading = false;
    super.initState();
  }

  void _handleFileSelect() async {
    var filePath = await FilePicker.getFilePath(type: FileType.any);
    // Would preferably use the following to limit to just `uds` files
    // Currently doing this on Android limits the selection to photos for some reason
    // getFilePath(type: FileType.custom, allowedExtensions: ['uds']);

    // Catch if the user entered the dialog and then tapped the back key
    // this will return the user to the home screen without error
    if (filePath == null) return;

    var recentFiles = context.read<RecentModelsData>();
    recentFiles.add(filePath);

    Navigator.pushNamed(
      context,
      SceneViewerPage.routeName,
      arguments: SceneViewerArgs(filePath),
    );
  }

  _handleLogout(context) async {
    setState(() => logoutLoading = true);
    await widget.udManager.logout();
    Navigator.popAndPushNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        title:
            Text('Home', style: TextStyle(color: Colors.white, fontSize: 26)),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Color.fromRGBO(24, 189, 210, 1.0),
            child: ListTile(
              title: Text(
                'Load file',
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, letterSpacing: -0.3),
              ),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
              onTap: () => _handleFileSelect(),
            ),
          ),
          MenuItem(
            title: 'Most Recent',
            trailing: Icon(Icons.keyboard_arrow_right),
            margin: const EdgeInsets.only(top: marginTop),
            child: RecentModelsView(),
            onTap: () => _handleFileSelect(),
          ),
          MenuItem(
            title: 'Settings',
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => Navigator.pushNamed(context, '/settings'),
            margin: const EdgeInsets.only(top: marginTop),
          ),
          MenuItem(
            title: 'Logout',
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => _handleLogout(context),
            margin: const EdgeInsets.only(top: marginTop),
            isLoading: logoutLoading,
          ),
        ],
      ),
    );
  }
}
