import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_tech_app/src/components/login/loader_component.dart';
import 'package:mobile_tech_app/src/helpers/constants.dart';
import 'package:mobile_tech_app/src/models/token.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email = '';
  String _emailError = '';
  bool _emailShowError = false;

  String _password = '';
  String _passwordError = '';
  bool _passwordShowError = false;

  bool _rememberme = true;
  bool _passwordShow = false;

  bool _showLoader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  height: 40,
                ),
                _showLogo(),
                const SizedBox(
                  height: 20,
                ),
                _showEmail(),
                _showPassword(),
                _showRememberme(),
                _showButtons(),
              ],
            ),
          ),
          _showLoader
              ? LoaderComponent(text: AppLocalizations.of(context)!.waitPlease)
              : Container(),
        ],
      ),
    );
  }

  Widget _showLogo() {
    return const Image(
      image: AssetImage('assets/mobile_tech.png'),
      width: 300,
      fit: BoxFit.fill,
    );
  }

  Widget _showEmail() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.emailHint,
          labelText: AppLocalizations.of(context)!.email,
          errorText: _emailShowError ? _emailError : null,
          prefixIcon: const Icon(Icons.alternate_email),
          suffixIcon: const Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPassword() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: TextField(
        obscureText: !_passwordShow,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.passwordHint,
          labelText: AppLocalizations.of(context)!.password,
          errorText: _passwordShowError ? _passwordError : null,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: _passwordShow
                ? const Icon(Icons.visibility)
                : const Icon(Icons.visibility_off),
            onPressed: () {
              setState(() {
                _passwordShow = !_passwordShow;
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          _password = value;
        },
      ),
    );
  }

  Widget _showRememberme() {
    return CheckboxListTile(
      title: Text(AppLocalizations.of(context)!.rememberMe),
      value: _rememberme,
      onChanged: (value) {
        setState(() {
          _rememberme = value!;
        });
      },
    );
  }

  Widget _showButtons() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _showLoginButton(),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  void _login() async {
    setState(() {
      _passwordShow = false;
    });

    if (!_validateFields()) {
      return;
    }

    setState(() {
      _showLoader = true;
    });

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _showLoader = false;
      });
      await showAlertDialog(
          context: context,
          title: 'Error',
          message: AppLocalizations.of(context)!.checkConnection,
          actions: <AlertDialogAction>[
            AlertDialogAction(
                key: null, label: AppLocalizations.of(context)!.ok),
          ]);
      return;
    }

    Map<String, dynamic> request = {
      'userName': _email,
      'password': _password,
    };

    var url = Uri.parse('${Constants.apiUrl}/api/AccountApi/CreateToken');
    var response = await http.post(
      url,
      headers: {
        'content-type': 'application/json',
        'accept': 'application/json',
      },
      body: jsonEncode(request),
    );

    setState(() {
      _showLoader = false;
    });

    if (response.statusCode >= 400) {
      setState(() {
        _passwordShowError = true;
        _passwordError = AppLocalizations.of(context)!.wrongEmailOrPassword;
      });
      return;
    }

    var body = response.body;

    if (_rememberme) {
      _storeUser(body);
    }

    var decodedJson = jsonDecode(body);
    var token = Token.fromJson(decodedJson);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(
                  token: token,
                )));
  }

  bool _validateFields() {
    bool isValid = true;

    if (_email.isEmpty) {
      isValid = false;
      _emailShowError = true;
      _emailError = AppLocalizations.of(context)!.requiredEmail;
    } else if (!EmailValidator.validate(_email)) {
      isValid = false;
      _emailShowError = true;
      _emailError = AppLocalizations.of(context)!.requiredValidEmail;
    } else {
      _emailShowError = false;
    }

    if (_password.isEmpty) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = AppLocalizations.of(context)!.requiredPassword;
    } else if (_password.length < 6) {
      isValid = false;
      _passwordShowError = true;
      _passwordError = AppLocalizations.of(context)!.requiredPasswordMin;
    } else {
      _passwordShowError = false;
    }

    setState(() {});
    return isValid;
  }

  Widget _showLoginButton() {
    return Expanded(
      child: ElevatedButton(
        child: Text(AppLocalizations.of(context)!.login),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return const Color(0xFF120E43);
          }),
        ),
        onPressed: () => _login(),
      ),
    );
  }

  void _storeUser(String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', true);
    await prefs.setString('userBody', body);
  }
}
