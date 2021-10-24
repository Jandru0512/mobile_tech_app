import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mobile_tech_app/src/models/token.dart';

class UsersScreen extends StatelessWidget {
  final Token token;

  const UsersScreen({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.users),
        ),
        body: const Text('dummy users'));
  }
}
