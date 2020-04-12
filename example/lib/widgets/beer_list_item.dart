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

import 'package:couchbase_lite_example/models/database/beer.dart';
import 'package:flutter/material.dart';

class BeerListItem extends StatelessWidget {
  BeerListItem(this.beer, {this.onTap});

  final Beer beer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return beer == null
        ? ListTile(title: Center(child: CircularProgressIndicator()))
        : ListTile(
            key: ObjectKey(beer),
            title: Text(
              beer.name,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: onTap,
          );
  }
}
