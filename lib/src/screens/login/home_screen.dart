import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mobile_tech_app/src/screens/user/user_screen.dart';
import 'package:mobile_tech_app/src/screens/user/users_screen.dart';
import 'package:mobile_tech_app/src/models/token.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Token token;

  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: _getBody(),
      drawer: widget.token.user.userType == 0
          ? _getAdminMenu()
          : _getCustomerMenu(),
    );
  }

  Widget _getBody() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(150),
                child: CachedNetworkImage(
                  imageUrl: widget.token.user.imageFullPath,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  height: 300,
                  width: 300,
                  placeholder: (context, url) => const Image(
                    image: AssetImage('assets/mobile_tech.png'),
                    fit: BoxFit.cover,
                    height: 300,
                    width: 300,
                  ),
                )),
            const SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                '${AppLocalizations.of(context)!.welcome} ${widget.token.user.fullName}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAdminMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
              child: Image(
            image: AssetImage('assets/mobile_tech.png'),
          )),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(AppLocalizations.of(context)!.users),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UsersScreen(
                            token: widget.token,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () => _logOut(),
          ),
        ],
      ),
    );
  }

  Widget _getCustomerMenu() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
              child: Image(
            image: AssetImage('assets/mobile_tech.png'),
          )),
          ListTile(
            leading: const Icon(Icons.face),
            title: Text(AppLocalizations.of(context)!.editProfile),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserScreen(
                            token: widget.token,
                            user: widget.token.user,
                            myProfile: true,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(AppLocalizations.of(context)!.logout),
            onTap: () => _logOut(),
          ),
        ],
      ),
    );
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', false);
    await prefs.setString('userBody', '');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }
}
