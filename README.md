# ABFRealmGridController
The `ABFRealmGridController` is a `UICollectionViewController` subclass that binds data in Realm. The underlying `UICollectionView` will animate changes via use of [`RBQFetchedResultsController`](https://github.com/Roobiq/RBQFetchedResultsController).

_**A Swift API that mirrors the Objective-C version is also available.**_

To use, simply subclass `ABFRealmGridController` in the same way as `UICollectionViewController` and set the `entityName` property to the Realm object class name you want to display. Similar to an `UICollectionView` implementation, you will need to implement the necessary `UICollectionViewDelegate` and `UICollectionViewDataSource` protocols.

####Screenshot
The example application displays the current top stories from the New York Times. The app requests the stories for each section of the newspaper and adds the individual stories to Realm.

![Grid of NYTimes Top Stories Backed By ABFRealmGridController](/images/ABFRealmGridController.gif?raw=true "Grid of NYTimes Top Stories Backed By ABFRealmGridController")

####Installation
`ABFRealmGridController` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

**Objective-C**
```
pod 'ABFRealmGridController'
```

**Swift**
```
pod 'RealmGridController'
```

####Demo

Build and run/test the Example project in Xcode to see `ABFRealmGridController` in action. This project uses CocoaPods. If you don't have [CocoaPods](http://cocoapods.org/) installed, grab it with [sudo] gem install cocoapods.

**Objective-C**
```
git clone https://github.com/bigfish24/ABFRealmGridController.git
cd ABFRealmGridController/ABFRealmGridControllerExample
pod install
open ABFRealmGridController.xcworkspace
```

**Swift**
```
git clone https://github.com/bigfish24/ABFRealmTableViewController.git
cd ABFRealmTableViewController/SwiftExample
pod install
open SwiftRealmGridController.xcworkspace
```
