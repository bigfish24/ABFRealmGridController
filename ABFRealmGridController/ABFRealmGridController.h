//
//  ABFRealmGridController.h
//  ABFRealmGridControllerExample
//
//  Created by Adam Fish on 8/25/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RLMRealm, RLMRealmConfiguration, RBQFetchedResultsController;

@interface ABFRealmGridController : UICollectionViewController

/**
 *  The entity (Realm object) name
 */
@property (nonatomic, strong) IBInspectable NSString *entityName;

/**
 *  Predicate supported by Realm
 *
 *  http://realm.io/docs/cocoa/0.89.2/#querying-with-predicates
 */
@property (nonatomic, strong) NSPredicate *basePredicate;

/**
 *  Array of RLMSortDescriptors
 *
 *  http://realm.io/docs/cocoa/0.89.2/#ordering-results
 */
@property (nonatomic, strong) NSArray *sortDescriptors;

/**
 *  The section name key path used to create the sections. Can be nil if no sections.
 */
@property (nonatomic, strong) IBInspectable NSString *sectionNameKeyPath;

/**
 *  The configuration for the Realm in which the entity resides
 *
 *  Default is [RLMRealmConfiguration defaultConfiguration]
 */
@property (nonatomic, strong) RLMRealmConfiguration *realmConfiguration;

/**
 *  The Realm in which the given entity resides in
 */
@property (nonatomic, readonly) RLMRealm *realm;

/**
 *  The underlying RBQFetchedResultsController
 */
@property (readonly, nonatomic) RBQFetchedResultsController *fetchedResultsController;

/**
 *  Retrieve the RLMObject for a given index path
 *
 *  @warning Returned object is not thread-safe.
 *
 *  @param indexPath the index path of the object
 *
 *  @return RLMObject
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
