import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart' as drive;

import 'handler_client.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/drive.appdata',
  ],
);

class AccountHeader extends StatefulWidget {
  @override
  _AccountHeaderState createState() => _AccountHeaderState();
}

class _AccountHeaderState extends State<AccountHeader> {
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        print('current user not null');
      }
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser != null) {
      return Column(
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: Text(_currentUser.displayName ?? ''),
            subtitle: Text(_currentUser.email ?? ''),
          ),
          RaisedButton(
            child: const Text('SIGN OUT'),
            onPressed: _handleSignOut,
          ),
          RaisedButton(
            child: const Text('test'),
            onPressed: () => _onTest('hi'),
          ),
        ],
      );
    }
    return RaisedButton(
      child: const Text('SIGN IN'),
      onPressed: _handleSignIn,
    );
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  _onTest(String file) async {
    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    print('authentication: $authentication');
    final client = MyClient(defaultHeaders: {
      'Authorization': 'Bearer ${authentication.accessToken}'
    });

    drive.DriveApi driveApi = drive.DriveApi(client);

    var media = new drive.Media(Stream.value([0]), 1);
    var driveFile = new drive.File()
      ..title = 'test'
      ..parents = [drive.ParentReference()..id = 'appDataFolder'];

    await driveApi.files
        .insert(driveFile, uploadMedia: media)
        .then((drive.File f) {
      print('Uploaded $file. Id: ${f.id}');
    });

    drive.FileList files = await driveApi.files.list(
      spaces: 'appDataFolder',
    );

    print(files.items.length);
    files.items.forEach((element) {
      print(files.items.indexWhere((e) => e == element).toString() +
          ') ' +
          element.title +
          ' ' +
          element.fileSize);
    });
  }
}
