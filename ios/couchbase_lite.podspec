#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'couchbase_lite'
  s.version          = '0.0.1'
  s.summary          = 'Community edition of Couchbase Lite.  Couchbase Lite is an embedded lightweight, document-oriented (NoSQL), syncable database engine.'
  s.description      = <<-DESC
Community edition of Couchbase Lite.  Couchbase Lite is an embedded lightweight, document-oriented (NoSQL), syncable database engine.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'CouchbaseLite-Swift', '~> 2.7.1'

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target  = '10.11'
end

