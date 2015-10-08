Pod::Spec.new do |s|
  s.name         = "ABFRealmGridController"
  s.version      = "1.3"
  s.summary      = "UICollectionViewController subclass that binds data in Realm"
  s.description  = <<-DESC
UICollectionViewController subclass that adds data binding support for a Realm object model.
                   DESC
  s.homepage     = "https://github.com/bigfish24/ABFRealmGridController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Adam Fish" => "af@realm.io" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/bigfish24/ABFRealmGridController.git", :tag => "v#{s.version}" }
  s.source_files  = "ABFRealmGridController/*.{h,m}"
  s.requires_arc = true
  s.dependency "RBQFetchedResultsController", ">= 2.3"
  s.dependency "Realm", ">= 0.95"

end