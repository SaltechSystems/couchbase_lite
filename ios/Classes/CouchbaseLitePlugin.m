#import "CouchbaseLitePlugin.h"
#import <couchbase_lite/couchbase_lite-Swift.h>

@implementation CouchbaseLitePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCouchbaseLitePlugin registerWithRegistrar:registrar];
}
@end
