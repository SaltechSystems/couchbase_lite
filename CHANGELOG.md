## 3.0.0-nullsafety.2

* Update Android library to version 2.8.6
* Migrate the example app to null safety
* Fix a down cast issue

## 3.0.0-nullsafety.1

* Added setting logging level feature 

## 3.0.0-nullsafety.0

* Migrate to NNDB
* Update libraries to version 2.8.4 (iOS) & 2.8.5 (Android)
* Updated gradle to 4.0.2

## 2.8.1

* Update libraries to version 2.8.1
* Updated gradle to 3.5.4 and compile version to 29

## 2.7.1+7

* Read blob files without platform code
* Added FullTextIndex and FullTextExpressions
* Support filtering replication on multiple attributes
* Fix with Result.getBoolean
* Fixed error when loading blobs
* Removed caching from blobs

## 2.7.1+6

* Added channels to replicator configs
* Added headers to replicator config
* Added push filters to replicator config
* Added pull filters to replicator config

## 2.7.1+5

* Added deletion of indexes
* Fixed issues with blobs and queries
* Added Fragments to expose value getters for Documents
* Added [] operators to Result, Document, and MutableDocument classes to retrieve Fragments

## 2.7.1+4

* Added Database addDocumentChangeListener 
* Added Database addChangeListener 
* Added Database removeChangeListener

## 2.7.1+3

* Setting up plugin CI/CD

## 2.7.1+2

* Added indexes
* Added explain to queries

## 2.7.1+1

* Fixed issue with optional Session cookieName

## 2.7.1

* Update libraries to version 2.7.1
* Fixed example for logging out
* Updated console logging to Debug for debug mode / Error for everything else
* Removed file logging

## 2.7.0+3

* Giving a simplified example and advanced example

## 2.7.0+2

* Updated documentation

## 2.7.0+1

* Updated Examples to use bloc pattern

## 2.7.0

* Updated Coubchbase Lite libraries to version 2.7.0
* Migrated to Android X
* Added concurrency control

# 2.5.1+8

* Fixed a bug on Android which results in an error for not posting results on the UI Thread

# 2.5.1+7

* Deprecated Database saveDocument methods and replaced with save taking a MutableDocument as an argument
* Fixed a concurrent modification exception with query listeners

# 2.5.1+6

* Fixed an issue where Query Listeners were not being released
* Fixed an issue where the database reference was not being released on close for Android

# 2.5.1+5

* Fixed Replicator Configuration bug which required certain variables like Pinned Certificate to not receive an Platform Error
* Changed the Map object in Document from unmodifiable to a modifiable copy of the Map object
* Renamed the functions In,Is,As to in,iS,aS to comply with flutter plugin standards
* Added a destroy method to Replicator for cleaning up variable references and listeners

## 2.5.1+4

* Updated documentation
* Added more test cases

## 2.5.1+3

* Fixed issue with Replication EventChannel
* Added Travis CI and Code Coverage with Coveralls
* Added support for the having clause
* Fixed some issues with Queries

## 2.5.1+2

* Added all classes as part of couchbase_lite library to eliminate the need to import every class individually

## 2.5.1+1

* Changed return type of class Database documentWithId from Map to Document
* Populated doc/api using dartdoc
* Fixed some format issues

## 2.5.1

* Updated documentation

## 2.5.0

* Initial Release for the plugin using Couchbase Mobile 2.5