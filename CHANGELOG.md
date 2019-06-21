## 2.5.0

* Initial Release for the plugin using Couchbase Mobile 2.5

## 2.5.1

* Updated documentation

## 2.5.1+1

* Changed return type of class Database documentWithId from Map to Document
* Populated doc/api using dartdoc
* Fixed some format issues

## 2.5.1+2

* Added all classes as part of couchbase_lite library to eliminate the need to import every class individually

## 2.5.1+3

* Fixed issue with Replication EventChannel
* Added Travis CI and Code Coverage with Coveralls
* Added support for the having clause
* Fixed some issues with Queries

## 2.5.1+4

* Updated documentation
* Added more test cases

# 2.5.1+5

* Fixed Replicator Configuration bug which required certain variables like Pinned Certificate to not receive an Platform Error
* Changed the Map object in Document from unmodifiable to a modifiable copy of the Map object
* Renamed the functions In,Is,As to in,iS,aS to comply with flutter plugin standards
* Added a destroy method to Replicator for cleaning up variable references and listeners

# 2.5.1+6

* Fixed an issue where Query Listeners were not being released
* Fixed an issue where the database reference was not being released on close for Android

# 2.5.1+7

* Deprecated Database saveDocument methods and replaced with save taking a MutableDocument as an argument
* Fixed a concurrent modification exception with query listeners

# 2.5.1+8

* Fixed a bug on Android which results in an error for not posting results on the UI Thread