import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mobile_tech_app/src/models/token.dart';
import 'package:mobile_tech_app/src/models/user.dart';

class UserScreen extends StatelessWidget {
  final Token token;
  final User user;
  final bool myProfile;

  const UserScreen(
      {Key? key,
      required this.token,
      required this.user,
      required this.myProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.user),
        ),
        body: const Text('dummy profile'));
  }
}
