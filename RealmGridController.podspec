Pod::Spec.new do |s|
  s.name         = "RealmGridController"
  s.version      = "1.4"
  s.summary      = "Swift UICollectionViewController subclass that binds data in Realm"
  s.description  = <<-DESC
Swift UICollectionViewController subclass that adds data binding support for a Realm object model.
                   DESC
  s.homepage     = "https://github.com/bigfish24/ABFRealmGridController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adam Fish" => "af@realm.io" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/bigfish24/ABFRealmGridController.git", :tag => "v#{s.version}" }
  s.source_files  = "RealmGridController/*.{swift}"
  s.requires_arc = true
  s.dependency "SwiftFetchedResultsController", ">= 2.4"
  s.dependency "RealmSwift", ">= 0.96"

end
