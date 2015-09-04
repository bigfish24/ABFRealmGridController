//
//  NYTStory.h
//  ABFRealmGridControllerExample
//
//  Created by Adam Fish on 9/3/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <Realm/Realm.h>

#import "NYTStoryImage.h"

@class NYTStory;

@interface NYTStory : RLMObject

// Model

@property NSString *section;

@property NSString *subsection;

@property NSString *title;

@property NSString *abstract;

@property NSString *urlString;

@property NSString *byline;

@property NSString *itemType;

@property NSDate *updatedDate;

@property NSDate *createdDate;

@property NSDate *publishedDate;

@property NSString *materialTypeFacet;

@property NSString *kicker;

@property NSString *desFacetString;

@property NSString *orgFacetString;

@property NSString *perFacetString;

@property NSString *geoFacetString;

@property NYTStoryImage *storyImage;

// Formatted Accessors

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, strong) NSArray *desFacet;

@property (nonatomic, strong) NSArray *orgFacet;

@property (nonatomic, strong) NSArray *perFacet;

@property (nonatomic, strong) NSArray *geoFacet;

+ (instancetype)storyWithJSON:(NSDictionary *)json;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<NYTStory>
RLM_ARRAY_TYPE(NYTStory)
