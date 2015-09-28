//
//  RealmGridController.swift
//  RealmGridController
//
//  Created by Adam Fish on 9/4/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

import UIKit
import RealmSwift
import RBQFetchedResultsController

typealias UpdateBlock = () -> Void

public class RealmGridController: UICollectionViewController, RBQFetchedResultsControllerDelegate {
    // MARK: Properties
    
    /// The name of the Realm Object managed by the grid controller
    @IBInspectable public var entityName: String? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// The section name key path used to create the sections. Can be nil if no sections.
    @IBInspectable public var sectionNameKeyPath: String? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// The base predicet to to filter the Realm Objects on
    public var basePredicate: NSPredicate? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// Array of SortDescriptors
    ///
    /// http://realm.io/docs/cocoa/0.89.2/#ordering-results
    public var sortDescriptors: [SortDescriptor]? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// The configuration for the Realm in which the entity resides
    ///
    /// Default is [RLMRealmConfiguration defaultConfiguration]
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
    
    /// The Realm in which the given entity resides in
    public var realm: Realm? {
        if let configuration = self.realmConfiguration {
            return try! Realm(configuration: configuration)
        }
        
        return nil
    }
    
    // MARK: Object Retrieval
    
    /**
    Retrieve the RLMObject for a given index path
    
    :warning: Returned object is not thread-safe.
    
    :param: indexPath the index path of the object
    
    :returns: RLMObject
    */
    public func objectAtIndexPath<T: Object>(type: T.Type, indexPath: NSIndexPath) -> T? {
        if let anObject: AnyObject = self.fetchedResultsController.objectAtIndexPath(indexPath) {
            return unsafeBitCast(anObject, T.self)
        }
        
        return nil
    }
    
    // MARK: Initializers
    
    required public init?(coder aDecoder: NSCoder) {
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
    
    // MARK: Private Functions
    
    private var viewLoaded: Bool = false
    
    private var updateBlocks = [UpdateBlock]()
    
    private var internalConfiguration: Realm.Configuration?
    
    public var fetchedResultsController: RBQFetchedResultsController!
    
    private var rlmRealm: RLMRealm? {
        if let realmConfiguration = self.realmConfiguration {
            let configuration = self.toRLMConfiguration(realmConfiguration)
            
            return try! RLMRealm(configuration: configuration)
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                
                if let realm = self.rlmRealm {
                    
                    let fetchRequest = RBQFetchRequest(entityName: self.entityName!, inRealm: realm, predicate: self.basePredicate)
                    
                    self.fetchedResultsController.updateFetchRequest(fetchRequest, sectionNameKeyPath: self.sectionNameKeyPath, andPeformFetch: self.viewLoaded)
                    
                    if self.viewLoaded {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.collectionView?.reloadData()
                        })
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

extension RealmGridController {
    public override func viewDidLoad() {
        if self.entityName != nil {
            self.fetchedResultsController.performFetch()
        }
        
        self.viewLoaded = true
    }
}
extension RealmGridController {
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRowsForSectionIndex(section)
    }
}

extension RealmGridController {
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
