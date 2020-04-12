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
// limitations under the License.

import 'package:couchbase_lite_example/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'colors.dart';

import 'package:couchbase_lite_example/data/api_provider.dart';
import 'package:couchbase_lite_example/data/repository.dart';
import 'package:couchbase_lite_example/pages/login.dart';

enum AppMode { production, development }

class BeerSampleApp extends StatefulWidget {
  BeerSampleApp(this.mode);

  final AppMode mode;

  @override
  _BeerSampleAppState createState() => _BeerSampleAppState();
}

class _BeerSampleAppState extends State<BeerSampleApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Werk Sheets',
      theme: _kTheme,
      routes: {
        '/home': (BuildContext context) => HomePage(),
        '/': (BuildContext context) => LoginPage(widget.mode),
      },
    );
  }

  bool isActive() => mounted;

  @override
  void dispose() {
    ApiProvider.instance.client.close();
    Repository.instance.dispose();
    super.dispose();
  }
}

final ThemeData _kTheme = _buildTheme();

ThemeData _buildTheme() {
  final ThemeData base = ThemeData(
      // Define the default brightness and colors.
      brightness: Brightness.light,
      primaryColor: kPrimaryColor,
      accentColor: kAccentColor,

      // Define the default font family.
      fontFamily: 'Rubik');

  return base.copyWith(
    buttonTheme: base.buttonTheme.copyWith(
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    ),
    textTheme: _buildTextTheme(base.textTheme),
    //primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base.apply(
    displayColor: kPrimaryColor,
    bodyColor: kPrimaryColor,
  );
}
