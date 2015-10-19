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

// Convenience Accessors

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, strong) NSArray *desFacet;

@property (nonatomic, strong) NSArray *orgFacet;

@property (nonatomic, strong) NSArray *perFacet;

@property (nonatomic, strong) NSArray *geoFacet;


@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

/**
 Requests the latest stories from the New York Times 
 and then persists them into a given Realm.
 
 @warning Requires API Key, get one here: http://developer.nytimes.com/
 
 @param realm	a Realm instance to save the stories to
 @param apiKey	a current API key from New York Times Developer Network
 */
+ (void)loadLatestStoriesIntoRealm:(RLMRealm *)realm
                        withAPIKey:(NSString *)apiKey;

/**
 Creates a new instance of NYTStory from JSON response
 
 @param json	JSON representation of NYTStory
 
 @return a new instance of NYTStory
 */
+ (instancetype)storyWithJSON:(NSDictionary *)json;

/**
 Returns a string from one of the model's date
 
 @param date	an NSDate
 
 @return an instance of NSString
 */
+ (NSString *)stringFromDate:(NSDate *)date;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<NYTStory>
RLM_ARRAY_TYPE(NYTStory)
