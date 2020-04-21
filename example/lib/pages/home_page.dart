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

import 'package:built_collection/built_collection.dart';
import 'package:couchbase_lite_example/blocs/home_page_bloc.dart';
import 'package:couchbase_lite_example/models/database/beer.dart';
import 'package:couchbase_lite_example/models/database/brewery.dart';
import 'package:couchbase_lite_example/widgets/beer_list_item.dart';
import 'package:couchbase_lite_example/widgets/brewery_list_item.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageBloc _pageBloc;
  final _textFieldController = TextEditingController();

  @override
  void initState() {
    _pageBloc = HomePageBloc(PageCategory.beer);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Container(
              child: Column(
            children: <Widget>[
              _buildCategoryHeader(),
              Expanded(
                child: StreamBuilder<PageState>(
                  stream: _pageBloc.state,
                  initialData: InitState(),
                  builder: (context, snapshot) {
                    switch (snapshot.data.runtimeType) {
                      case InitState:
                        return _buildInit();
                      case LoadingState:
                        return _buildLoading();
                      case BeerDataState:
                        BeerDataState state = snapshot.data;
                        return _buildBeerContent(state.beerMap,
                            state.lastIndex + 1, state.hasReachedEnd);
                      case BreweryDataState:
                        BreweryDataState state = snapshot.data;
                        return _buildBreweryContent(state.breweryMap,
                            state.lastIndex + 1, state.hasReachedEnd);
                    }

                    return _buildInit();
                  },
                ),
              ),
            ],
          )),
          drawer: _buildMenu(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCreateDialog(),
            tooltip: 'Create New Beer',
            child: Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }

  AppBar _buildAppBar() {
    return AppBar(
      brightness: Brightness.light,
      elevation: 0.0,
      titleSpacing: 0.0,
      centerTitle: true,
      title: Text("Sheets"),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            semanticLabel: 'search',
          ),
          onPressed: () {
            _onPressSearch(context);
          },
        ),
      ],
    );
  }

  Widget _buildInit() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBeerContent(
      BuiltMap<int, Beer> beerMap, int itemCount, bool hasReachedEnd) {
    return ListView.builder(
        itemCount: itemCount + 1,
        physics: ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          _pageBloc.inIndex.add(index);
          final beer = beerMap[index];
          // Display an empty spot at end of list to allow for extra scrolling
          return hasReachedEnd && beer == null
              ? ListTile()
              : Card(child: BeerListItem(beer));
        });
  }

  Widget _buildBreweryContent(
      BuiltMap<int, Brewery> breweryMap, int itemCount, bool hasReachedEnd) {
    return ListView.builder(
        itemCount: itemCount + 1,
        physics: ClampingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          _pageBloc.inIndex.add(index);
          final brewery = breweryMap[index];
          // Display an empty spot at end of list to allow for extra scrolling
          return hasReachedEnd && brewery == null
              ? ListTile()
              : Card(child: BreweryListItem(brewery));
        });
  }

  Drawer _buildMenu() {
    return Drawer(
        child: Column(
      children: <Widget>[
        UserAccountsDrawerHeader(
          accountName: Text("Saltech Systems"),
          accountEmail: Text("cs@saltechsystems.com"),
          currentAccountPicture: CircleAvatar(
            child: Text(
              "SS",
              style: TextStyle(fontSize: 40.0),
            ),
          ),
        ),
        Expanded(
            child: Scrollbar(
                child: ListView(
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Beer"),
              onTap: () {
                setState(() {
                  _pageBloc.setCategory(PageCategory.beer);
                });

                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Brewery: TODO"),
              onTap: () {
                setState(() {
                  _pageBloc.setCategory(PageCategory.brewery);
                });

                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text("Account"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Log Out"),
              onTap: _pageBloc.logout,
            ),
          ],
        ))),
      ],
    ));
  }

  Widget _buildCategoryHeader() {
    return Padding(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Row(
          children: <Widget>[
            Container(
                width: 40.0, child: _buildCategoryIcon(_pageBloc.category)),
            Container(
                width: 120.0, child: Text(_categoryName(_pageBloc.category))),
            StreamBuilder<bool>(
                stream: _pageBloc.sort,
                initialData: true,
                builder: (context, snapshot) {
                  return IconButton(
                    color: Theme.of(context).primaryColor,
                    icon: Icon(snapshot.data
                        ? Icons.arrow_drop_down
                        : Icons.arrow_drop_up),
                    tooltip: 'Reorder Results',
                    onPressed: _pageBloc.toggleSort,
                  );
                }),
            Expanded(child: Container()),
            if (_pageBloc.category == PageCategory.search)
              Container(
                  width: 40.0,
                  child: IconButton(
                      color: Theme.of(context).primaryColor,
                      icon: Icon(Icons.clear),
                      onPressed: _onPressClearSearch)),
          ],
        ));
  }

  Widget _buildCategoryIcon(PageCategory selectedCategory) {
    switch (selectedCategory) {
      case PageCategory.beer:
        return Icon(Icons.add_shopping_cart,
            color: Theme.of(context).primaryColor);
      case PageCategory.brewery:
        return Icon(Icons.home, color: Theme.of(context).primaryColor);
      case PageCategory.search:
        return Icon(Icons.search, color: Theme.of(context).primaryColor);
    }

    return null;
  }

  String _categoryName(PageCategory selectedCategory) {
    switch (selectedCategory) {
      case PageCategory.beer:
        return "Beer";
      case PageCategory.brewery:
        return "Brewery: TODO";
      case PageCategory.search:
        return "Search";
    }

    return "";
  }

  Future<void> _openCreateDialog() async {
    _textFieldController.clear();
    String beerName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text('New Beer')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: "Please enter a name"),
                )
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('CREATE'),
                onPressed: () =>
                    Navigator.of(context).pop(_textFieldController.text),
              )
            ],
          );
        });

    if (beerName != null) {
      await _pageBloc.createBeer(beerName);
    }
  }

  void _onPressClearSearch() {
    // TODO
  }

  void _onPressSearch(BuildContext context) async {
    // TODO
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _pageBloc.dispose();
    super.dispose();
  }
}
