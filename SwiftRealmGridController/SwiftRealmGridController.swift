//
//  SwiftRealmGridController.swift
//  SwiftRealmGridController
//
//  Created by Adam Fish on 9/4/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

import UIKit
import RealmSwift
import RBQFetchedResultsController

typealias UpdateBlock = () -> Void

public class SwiftRealmGridController: UICollectionViewController, RBQFetchedResultsControllerDelegate {
    
    @IBInspectable public var entityName: String? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    @IBInspectable public var sectionNameKeyPath: String? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    public var basePredicate: NSPredicate? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    public var sortDescriptors: [SortDescriptor]? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    public var realmConfiguration: Realm.Configuration? {
        set {
            self.internalConfiguration = newValue
            
            self.updateFetchedResultsController()
        }
        get {
            if let configuration = self.internalConfiguration {
                return configuration
            }
            
            return Realm.Configuration.defaultConfiguration
        }
    }
    
    public var realm: Realm? {
        if let configuration = self.realmConfiguration {
            return Realm(configuration: configuration, error: nil)
        }
        
        return nil
    }
        
    public func objectAtIndexPath<T: Object>(type: T.Type, indexPath: NSIndexPath) -> T? {
        if let anObject: AnyObject = self.fetchedResultsController.objectAtIndexPath(indexPath) {
            return unsafeBitCast(anObject, T.self)
        }
        
        return nil
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        baseInit()
    }
    
    override public init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
        
        baseInit()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        baseInit()
    }
    
    private func baseInit() {
        self.fetchedResultsController = RBQFetchedResultsController()
        self.fetchedResultsController.delegate = self
    }
    
    private var viewLoaded: Bool = false
    
    private var updateBlocks = [UpdateBlock]()
    
    private var internalConfiguration: Realm.Configuration?
    
    public var fetchedResultsController: RBQFetchedResultsController!
    
    private var rlmRealm: RLMRealm? {
        if let realmConfiguration = self.realmConfiguration {
            let configuration = self.toRLMConfiguration(realmConfiguration)
            
            return RLMRealm(configuration: configuration, error: nil)
        }
        
        return nil
    }
    
    private func updateFetchedResultsController() {
        if self.entityName != nil && !self.viewLoaded {
            
            if let realm = self.rlmRealm {
                let fetchRequest = RBQFetchRequest(entityName: self.entityName!, inRealm: realm, predicate: self.basePredicate)
                
                self.fetchedResultsController.updateFetchRequest(fetchRequest, sectionNameKeyPath: self.sectionNameKeyPath, andPeformFetch: false)
            }
        }
        else if self.entityName != nil {
            
            weak var weakSelf: SwiftRealmGridController? = self
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                if let realm = weakSelf?.rlmRealm {
                    let fetchRequest = RBQFetchRequest(entityName: weakSelf?.entityName, inRealm: realm, predicate: weakSelf?.basePredicate)
                    
                    if let viewLoaded = weakSelf?.viewLoaded {
                        weakSelf?.fetchedResultsController.updateFetchRequest(fetchRequest, sectionNameKeyPath: weakSelf?.sectionNameKeyPath, andPeformFetch: viewLoaded)
                        
                        if (weakSelf?.viewLoaded != nil) {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                weakSelf?.collectionView?.reloadData()
                            })
                        }
                    }
                }
            })
        }
    }
    
    private func toRLMConfiguration(configuration: Realm.Configuration) -> RLMRealmConfiguration {
        let rlmConfiguration = RLMRealmConfiguration()
        rlmConfiguration.path = configuration.path
        rlmConfiguration.inMemoryIdentifier = configuration.inMemoryIdentifier
        rlmConfiguration.encryptionKey = configuration.encryptionKey
        rlmConfiguration.readOnly = configuration.readOnly
        rlmConfiguration.schemaVersion = configuration.schemaVersion
        return rlmConfiguration
    }
    
    private func add(updateBlock: UpdateBlock) {
        self.updateBlocks.append(updateBlock)
    }
    
    private func performUpdates() {
        for updateBlock in self.updateBlocks {
            updateBlock()
        }
    }
}

extension SwiftRealmGridController {
    public override func viewDidLoad() {
        self.fetchedResultsController.performFetch()
        
        self.viewLoaded = true
    }
}
extension SwiftRealmGridController: UICollectionViewDataSource {
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
}

extension SwiftRealmGridController: RBQFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(controller: RBQFetchedResultsController!) {
        self.updateBlocks = [UpdateBlock]()
    }
    
    public func controller(controller: RBQFetchedResultsController!, didChangeSection section: RBQFetchedResultsSectionInfo!, atIndex sectionIndex: UInt, forChangeType type: NSFetchedResultsChangeType) {
        
        if let collectionView = self.collectionView {
            
            if type == NSFetchedResultsChangeType.Insert {
                self.add({ () -> Void in
                    let insertedSection = NSIndexSet(index: Int(sectionIndex))
                    
                    collectionView.insertSections(insertedSection)
                })
            }
            else if type == NSFetchedResultsChangeType.Delete {
                self.add({ () -> Void in
                    let deletedSection = NSIndexSet(index: Int(sectionIndex))
                    
                    collectionView.deleteSections(deletedSection)
                })
            }
        }
    }
    
    public func controller(controller: RBQFetchedResultsController!, didChangeObject anObject: RBQSafeRealmObject!, atIndexPath indexPath: NSIndexPath!, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath!) {
        
        if let collectionView = self.collectionView {
            
            if type == NSFetchedResultsChangeType.Insert {
               self.add({ () -> Void in
                    collectionView.insertItemsAtIndexPaths([newIndexPath])
               })
            }
            else if type == NSFetchedResultsChangeType.Delete {
                self.add({ () -> Void in
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                })
            }
            else if type == NSFetchedResultsChangeType.Update {
                self.add({ () -> Void in
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                })
            }
            else if type == NSFetchedResultsChangeType.Move {
                self.add({ () -> Void in
                    collectionView.deleteItemsAtIndexPaths([indexPath])
                    collectionView.insertItemsAtIndexPaths([newIndexPath])
                })
            }
        }
    }
    
    public func controllerDidChangeContent(controller: RBQFetchedResultsController!) {
        weak var weakSelf = self
        
        self.collectionView?.performBatchUpdates({ () -> Void in
            weakSelf?.performUpdates()
        }, completion: nil)
    }
}
