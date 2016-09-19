//
//  RealmGridController.swift
//  RealmGridController
//
//  Created by Adam Fish on 9/4/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftFetchedResultsController

typealias UpdateBlock = () -> Void

open class RealmGridController: UICollectionViewController {
    // MARK: Properties
    
    /// The name of the Realm Object managed by the grid controller
    @IBInspectable open var entityName: String? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// The section name key path used to create the sections. Can be nil if no sections.
    @IBInspectable open var sectionNameKeyPath: String? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// The base predicet to to filter the Realm Objects on
    open var basePredicate: NSPredicate? {
        didSet {
            self.updateFetchedResultsController()
        }
    }
    
    /// Array of SortDescriptors
    ///
    /// http://realm.io/docs/cocoa/0.89.2/#ordering-results
    open var sortDescriptors: [SortDescriptor]? {
        didSet {
            
            if let descriptors = self.sortDescriptors {
                
                var rlmSortDescriptors = [RLMSortDescriptor]()
                
                for sortDesc in descriptors {
                    
                    let rlmSortDesc = RLMSortDescriptor(property: sortDesc.property, ascending: sortDesc.ascending)
                    
                    rlmSortDescriptors.append(rlmSortDesc)
                }
                
                self.rlmSortDescriptors = rlmSortDescriptors
            }
            
            self.updateFetchedResultsController()
        }
    }
    
    /// The configuration for the Realm in which the entity resides
    ///
    /// Default is [RLMRealmConfiguration defaultConfiguration]
    open var realmConfiguration: Realm.Configuration? {
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
    open var realm: Realm? {
        if let configuration = self.realmConfiguration {
            return try! Realm(configuration: configuration)
        }
        
        return nil
    }
    
    /// The underlying RBQFetchedResultsController
    open var fetchedResultsController: RBQFetchedResultsController {
        return internalFetchedResultsController
    }
    
    // MARK: Object Retrieval
    
    /**
     Retrieve the RLMObject for a given index path
     
     :warning: Returned object is not thread-safe.
     
     :param: indexPath the index path of the object
     
     :returns: RLMObject
     */
    open func objectAtIndexPath<T: Object>(_ type: T.Type, indexPath: IndexPath) -> T? {
        if let anObject: AnyObject = self.fetchedResultsController.object(at: indexPath) as AnyObject? {
            return unsafeBitCast(anObject, to: T.self)
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
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        baseInit()
    }
    
    fileprivate func baseInit() {
        self.internalFetchedResultsController = RBQFetchedResultsController()
        self.internalFetchedResultsController.delegate = self
    }
    
    // MARK: Private Functions
    
    fileprivate var updateBlocks = [UpdateBlock]()
    
    fileprivate var internalConfiguration: Realm.Configuration?
    
    fileprivate var internalFetchedResultsController: RBQFetchedResultsController!
    
    fileprivate var rlmSortDescriptors: [RLMSortDescriptor]?
    
    fileprivate var rlmRealm: RLMRealm? {
        if let realmConfiguration = self.realmConfiguration {
            let configuration = self.toRLMConfiguration(realmConfiguration)
            
            return try! RLMRealm(configuration: configuration)
        }
        
        return nil
    }
    
    fileprivate func updateFetchedResultsController() {
        objc_sync_enter(self)
        if let fetchRequest = self.tableFetchRequest(self.entityName, inRealm: self.rlmRealm, predicate:self.basePredicate) {
            
            self.fetchedResultsController.updateFetchRequest(fetchRequest, sectionNameKeyPath: self.sectionNameKeyPath, andPerformFetch: true)
            
            if self.isViewLoaded {
                self.runOnMainThread({ [weak self] () -> Void in
                    self?.collectionView?.reloadData()
                    })
            }
        }
        objc_sync_exit(self)
    }
    
    fileprivate func tableFetchRequest(_ entityName: String?, inRealm realm: RLMRealm?, predicate: NSPredicate?) -> RBQFetchRequest? {
        
        if entityName != nil && realm != nil {
            
            let fetchRequest = RBQFetchRequest(entityName: entityName!, in: realm!, predicate: predicate)
            
            fetchRequest.sortDescriptors = self.rlmSortDescriptors
            
            return fetchRequest
        }
        
        return nil
    }
    
    fileprivate func toRLMConfiguration(_ configuration: Realm.Configuration) -> RLMRealmConfiguration {
        let rlmConfiguration = RLMRealmConfiguration()
        
        if (configuration.fileURL != nil) {
            rlmConfiguration.fileURL = configuration.fileURL
        }
        
        if (configuration.inMemoryIdentifier != nil) {
            rlmConfiguration.inMemoryIdentifier = configuration.inMemoryIdentifier
        }
        
        rlmConfiguration.encryptionKey = configuration.encryptionKey
        rlmConfiguration.readOnly = configuration.readOnly
        rlmConfiguration.schemaVersion = configuration.schemaVersion
        return rlmConfiguration
    }
    
    fileprivate func runOnMainThread(_ block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        }
        else {
            DispatchQueue.main.async(execute: { () -> Void in
                block()
            })
        }
    }
    
    fileprivate func add(_ updateBlock: @escaping UpdateBlock) {
        self.updateBlocks.append(updateBlock)
    }
    
    fileprivate func performUpdates() {
        for updateBlock in self.updateBlocks {
            updateBlock()
        }
    }
}

extension RealmGridController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.entityName != nil {
            self.fetchedResultsController.performFetch()
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.collectionViewLayout.invalidateLayout()
    }
}

extension RealmGridController {
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchedResultsController.numberOfRows(forSectionIndex: section)
    }
}

extension RealmGridController: RBQFetchedResultsControllerDelegate {
    public func controllerWillChangeContent(_ controller: RBQFetchedResultsController) {
        self.updateBlocks = [UpdateBlock]()
    }
    
    public func controller(_ controller: RBQFetchedResultsController, didChangeSection section: RBQFetchedResultsSectionInfo, at sectionIndex: UInt, for type: NSFetchedResultsChangeType) {
        
        if let collectionView = self.collectionView {
            
            if type == NSFetchedResultsChangeType.insert {
                self.add({ () -> Void in
                    let insertedSection = IndexSet(integer: Int(sectionIndex))
                    
                    collectionView.insertSections(insertedSection)
                })
            }
            else if type == NSFetchedResultsChangeType.delete {
                self.add({ () -> Void in
                    let deletedSection = IndexSet(integer: Int(sectionIndex))
                    
                    collectionView.deleteSections(deletedSection)
                })
            }
        }
    }
    
    public func controller(_ controller: RBQFetchedResultsController, didChange anObject: RBQSafeRealmObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let collectionView = self.collectionView {
            
            if type == NSFetchedResultsChangeType.insert {
                self.add({ () -> Void in
                    collectionView.insertItems(at: [newIndexPath!])
                })
            }
            else if type == NSFetchedResultsChangeType.delete {
                self.add({ () -> Void in
                    collectionView.deleteItems(at: [indexPath!])
                })
            }
            else if type == NSFetchedResultsChangeType.update {
                self.add({ () -> Void in
                    collectionView.reloadItems(at: [indexPath!])
                })
            }
            else if type == NSFetchedResultsChangeType.move {
                self.add({ () -> Void in
                    collectionView.deleteItems(at: [indexPath!])
                    collectionView.insertItems(at: [newIndexPath!])
                })
            }
        }
    }
    
    public func controllerDidChangeContent(_ controller: RBQFetchedResultsController){
        weak var weakSelf = self
        
        self.collectionView?.performBatchUpdates({ () -> Void in
            weakSelf?.performUpdates()
            }, completion: nil)
    }
}
