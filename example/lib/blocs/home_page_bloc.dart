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

import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:couchbase_lite_example/data/observable_response.dart';
import 'package:couchbase_lite_example/data/repository.dart';
import 'package:couchbase_lite_example/models/database/beer.dart';
import 'package:couchbase_lite_example/models/database/brewery.dart';
import 'package:rxdart/rxdart.dart';

enum PageCategory { beer, brewery, search }

class HomePageBloc {
  HomePageBloc(this._category) {
    _indexController.stream
        .debounceTime(Duration(milliseconds: 500))
        .listen((index) => _handleIndexes([index]));

    _fetchPage(0);
  }

  ///
  /// This controller will be used to request an item at a certain index and if
  /// the item is not available then a listener will detect this and update
  /// the publish subject to include it.
  ///
  final _indexController = PublishSubject<int>();

  ///
  /// This subject keeps the state of the sheets being displayed and all
  /// updates will be sent through this.
  ///
  final _stateSubject = BehaviorSubject<PageState>();
  final BehaviorSubject<bool> _sortSubject = BehaviorSubject<bool>.seeded(true);

  ///
  /// Keep the currently displayed response so it can be properly disposed of
  ///
  ObservableResponse<BuiltList<Beer>> _beerResponse;
  bool _isDescending = true;

  final perPage = 20;
  int currentPage = 0;
  PageCategory _category;
  Map<String, dynamic> _searchData = {};
  Map<String, dynamic> get searchData => _searchData;
  PageCategory get category => _category;
  Sink<int> get inIndex => _indexController.sink;
  Stream<PageState> get state => _stateSubject.stream;
  Stream<bool> get sort => _sortSubject.stream;

  void _handleIndexes(List<int> indexes) {
    var index = indexes.last;

    var min = (currentPage - 0.5) * perPage;
    var max = (currentPage + 1.5) * perPage;

    // Use a min and max to provide a buffer for scrolling back and forth
    if (index < min || index > max) {
      var page = index ~/ perPage;
      _fetchPage(page);
    }
  }

  void toggleSort() async {
    _isDescending = !_isDescending;
    _fetchPage(currentPage);
    _sortSubject.sink.add(_isDescending);
  }

  void setCategory(PageCategory pageCategory) async {
    if (pageCategory != _category) {
      _category = pageCategory;
      _stateSubject.sink.add(PageState._sheetsLoading());
      //This will trigger a reload
      _fetchPage(0);
    }
  }

  void _fetchPage(int pageIndex) {
    currentPage = pageIndex;

    // We no longer need the result so dispose of it
    _beerResponse?.close();
    _beerResponse = null;

    // Add some buffer to the current page so the user doesn't have to see it loading
    var offset =
        pageIndex > 0 ? (pageIndex - 1) * perPage : pageIndex * perPage;

    // Save the observable response so we can properly dispose of it
    switch (_category) {
      case PageCategory.beer:
        _beerResponse =
            Repository.instance.getBeer(perPage * 3, offset, _isDescending);

        // If the results change this will propagate the changes to the UI and will
        // also initialize it with the first result set
        _beerResponse.stream.listen((data) {
          Map<int, Beer> cards = {};
          for (var i = 0; i < data.length; i++) {
            cards[i + offset] = data[i];
          }

          var lastIndex = data.length - 1 + offset;
          var hasReachedEnd = data.length < perPage * 3;

          _stateSubject.sink.add(PageState._beerData(
              BuiltMap.from(cards), lastIndex, hasReachedEnd));
        });
        break;
      case PageCategory.brewery:
        _stateSubject.sink.add(BreweryDataState(BuiltMap(), 0, true));
        break;
      case PageCategory.search:
        // TODO
        break;
    }
  }

  void createBeer(String name) {
    // TODO
  }

  void logout() {
    Repository.instance.triggerLogout(LogoutMethod.normal);
  }

  void dispose() {
    _indexController.close();
    _beerResponse?.close();
    _sortSubject.close();
    _stateSubject.close();

    // This is called after all streams / listeners have been disposed
    Repository.instance.logout();
  }
}

class PageState {
  PageState();
  factory PageState._beerData(
          BuiltMap<int, Beer> beerMap, int lastIndex, bool hasReachedEnd) =
      BeerDataState;
  factory PageState._breweryData(BuiltMap<int, Brewery> breweryMap,
      int lastIndex, bool hasReachedEnd) = BreweryDataState;
  factory PageState._sheetsLoading() = LoadingState;
}

class InitState extends PageState {}

class LoadingState extends PageState {}

class BeerDataState extends PageState {
  BeerDataState(this.beerMap, this.lastIndex, this.hasReachedEnd);
  final BuiltMap<int, Beer> beerMap;
  final int lastIndex;
  final bool hasReachedEnd;
}

class BreweryDataState extends PageState {
  BreweryDataState(this.breweryMap, this.lastIndex, this.hasReachedEnd);
  final BuiltMap<int, Brewery> breweryMap;
  final int lastIndex;
  final bool hasReachedEnd;
}
