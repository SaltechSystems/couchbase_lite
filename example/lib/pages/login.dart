// Copyright 2020-present the Saltech Systems authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.ß

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:couchbase_lite_example/beer_sample_app.dart';
import 'package:couchbase_lite_example/data/repository.dart';

class LoginPage extends StatefulWidget {
  LoginPage(this.mode);

  final AppMode mode;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String usernameErrorMessage;
  String passwordErrorMessage;
  Environment databaseEnvironment = Environment.production;
  var environmentNames = {
    Environment.production: "Production",
    Environment.development: "Development"
  };

  StreamSubscription<bool> _loggedInSubscription;
  StreamSubscription<LogoutMethod> _logoutSubscription;

  String appName = "";
  String version = "";

  bool _isAuthenticating = false;

  TextEditingController _usernameController;
  TextEditingController _passwordController;
  FocusNode _passwordFocus;

  @override
  void initState() {
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocus = FocusNode();

    if (widget.mode == AppMode.development) {
      databaseEnvironment = Environment.development;
    }

    _loggedInSubscription = Repository.instance.isLoggedIn.listen((loggedIn) {
      if (!loggedIn) {
        Navigator.of(context).popUntil((route) {
          return route.settings.name == '/';
        });
      }
    });

    // DOESN'T DO MUCH - Just displays an incredible error message on logout
    _logoutSubscription = Repository.instance.lastLogoutMethod.listen((method) {
      switch (method) {
        case LogoutMethod.normal:
          setState(() {
            passwordErrorMessage = null;
          });
          break;
        case LogoutMethod.apiCredentialsError:
          setState(() {
            passwordErrorMessage = "API Authentication failed";
          });
          break;
        case LogoutMethod.dbCredentialsError:
          setState(() {
            passwordErrorMessage = "DB Authentication failed";
          });
          break;
        case LogoutMethod.validationError:
          setState(() {
            passwordErrorMessage = "Invalid Session";
          });
          break;
        case LogoutMethod.sessionDeleted:
          setState(() {
            passwordErrorMessage = "Another device logged in";
          });
          break;
      }
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        appName = packageInfo.appName;
        version = packageInfo.version;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: OrientationBuilder(builder: (context, orientation) {
            return ListView(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[
                SizedBox(
                    height: Orientation.portrait == orientation ? 80.0 : 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 225,
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                                height: 55,
                                child: FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text('Couchbase Lite',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Rubik')))),
                            FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  'Example App',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Rubik'),
                                )),
                          ],
                        )),
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(height: 16.0),
                    Text(
                      'Saltech Systems',
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    Text(
                      'Mobile Development',
                      style: Theme.of(context).textTheme.subtitle,
                    )
                  ],
                ),
                SizedBox(
                    height: Orientation.portrait == orientation ? 120.0 : 20.0),
                if (widget.mode == AppMode.development)
                  Column(
                    children: <Widget>[
                      Text("Development Environment"),
                      SizedBox(height: 16.0),
                    ],
                  ),
                TextField(
                  textInputAction: TextInputAction.next,
                  controller: _usernameController,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_passwordFocus),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    errorText: usernameErrorMessage,
                  ),
                ),
                SizedBox(height: 12.0),
                TextField(
                  focusNode: _passwordFocus,
                  textInputAction: TextInputAction.done,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: passwordErrorMessage,
                  ),
                  obscureText: true,
                ),
                ButtonBar(
                  alignment: _isAuthenticating
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (_isAuthenticating) CircularProgressIndicator(),
                    if (!_isAuthenticating)
                      FlatButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          setState(() {
                            usernameErrorMessage = null;
                            passwordErrorMessage = null;
                          });

                          _usernameController.clear();
                          _passwordController.clear();
                        },
                      ),
                    if (!_isAuthenticating)
                      OutlineButton(
                        child: Container(
                            alignment: Alignment.center,
                            width: 80.0,
                            child: Text('NEXT')),
                        onPressed: _onSignin,
                      ),
                  ],
                ),
                Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Center(
                        child: InkWell(
                      child: Text('Saltech Systems',
                          style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline)),
                      onTap: () => launch('https://saltechsystems.com'),
                    ))),
                Center(
                    child: Text(
                  "$appName $version",
                  style: TextStyle(color: Theme.of(context).disabledColor),
                ))
              ],
            );
          }),
        ),
      ),
    );
  }

  void _onSignin() {
    if (_validateUsername() && _validatePassword()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      Repository.instance.login(databaseEnvironment, username, password,
          (result) {
        switch (result) {
          case LoginResult.authorized:
            _isAuthenticating = false;
            Navigator.of(context).pushNamed('/home');
            break;
          case LoginResult.unauthorized:
            setState(() {
              _isAuthenticating = false;
              passwordErrorMessage = "Incorrect username or password";
            });
            break;
          case LoginResult.disconnected:
            setState(() {
              _isAuthenticating = false;
              passwordErrorMessage = "Check network connection";
            });
            break;
          case LoginResult.error:
            setState(() {
              _isAuthenticating = false;
              passwordErrorMessage = "Error connecting to the database";
            });
            break;
        }
      });

      setState(() {
        _isAuthenticating = true;
      });
    }
  }

  bool _validateUsername() {
    _usernameController.text = _usernameController.text.trim().toLowerCase();
    if (_usernameController.text.isEmpty) {
      setState(() {
        usernameErrorMessage = "Username required";
      });
    } else {
      setState(() {
        usernameErrorMessage = null;
      });
    }

    return usernameErrorMessage == null;
  }

  bool _validatePassword() {
    _passwordController.text = _passwordController.text.trim();
    if (_passwordController.text.isEmpty) {
      setState(() {
        passwordErrorMessage = "Password required";
      });
    } else {
      setState(() {
        passwordErrorMessage = null;
      });
    }

    return passwordErrorMessage == null;
  }

  @override
  void dispose() {
    _logoutSubscription?.cancel();
    _loggedInSubscription?.cancel();
    _passwordController?.dispose();
    _usernameController?.dispose();
    _passwordFocus?.dispose();

    super.dispose();
  }
}
