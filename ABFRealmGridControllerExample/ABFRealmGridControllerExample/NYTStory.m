//
//  NYTStory.m
//  ABFRealmGridControllerExample
//
//  Created by Adam Fish on 9/3/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "NYTStory.h"

#import <RBQFetchedResultsController/RLMRealm+Notifications.h>

@implementation NYTStory
@synthesize desFacet = _desFacet,
orgFacet = _orgFacet,
perFacet = _perFacet,
geoFacet = _geoFacet;

#pragma mark - RLMObject

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"section" : @"",
             @"subsection" : @"",
             @"title" : @"",
             @"abstract" : @"",
             @"urlString" : @"",
             @"byline" : @"",
             @"itemType" : @"",
             @"updatedDate" : [NSDate distantPast],
             @"createdDate" : [NSDate distantPast],
             @"publishedDate" : [NSDate distantPast],
             @"materialTypeFacet" : @"",
             @"kicker" : @"",
             @"desFacetString" : @"",
             @"orgFacetString" : @"",
             @"perFacetString" : @"",
             @"geoFacetString" : @""
             };
}

+ (NSString *)primaryKey
{
    return @"title";
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"url",
             @"desFacet",
             @"orgFacet",
             @"perFacet",
             @"geoFacet"];
}

#pragma mark - Public Class

+ (void)loadLatestStoriesIntoRealm:(RLMRealm *)realm
                        withAPIKey:(NSString *)apiKey
{
    // Grab config so we can open new instance across threads
    RLMRealmConfiguration *config = realm.configuration;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *nytSections = @[@"home",
                                 @"world",
                                 @"national",
                                 @"politics",
                                 @"nyregion",
                                 @"business",
                                 @"opinion",
                                 @"technology",
                                 @"science",
                                 @"health",
                                 @"sports",
                                 @"arts",
                                 @"fashion",
                                 @"dining",
                                 @"travel",
                                 @"magazine",
                                 @"realestate",
                                 ];
        
        for (NSString *section in nytSections) {
            NSString *urlString =
            [NSString stringWithFormat:@"http://api.nytimes.com/svc/topstories/v1/%@.json?api-key=%@",section,apiKey];
            
            NSURL *topStoryURL = [NSURL URLWithString:urlString];
            
            NSURLRequest *topStoriesRequest = [NSURLRequest requestWithURL:topStoryURL];
            
            [NSURLConnection sendAsynchronousRequest:topStoriesRequest
                                               queue:[[NSOperationQueue alloc] init]
                                   completionHandler:^(NSURLResponse *response,
                                                       NSData *data,
                                                       NSError *connectionError) {
                                       if (connectionError) {
                                           return;
                                       }
                                       
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                                            options:0
                                                                                              error:nil];
                                       
                                       NSArray *results = json[@"results"];
                                       
                                       RLMRealm *aRealm = [RLMRealm realmWithConfiguration:config
                                                                                     error:nil];
                                       
                                       [aRealm beginWriteTransaction];
                                       for (NSDictionary *storyJSON in results) {
                                           NYTStory *story = [NYTStory storyWithJSON:storyJSON];
                                           
                                           if (story) {
                                               [aRealm addOrUpdateObjectWithNotification:story];
                                           }
                                       }
                                       [aRealm commitWriteTransaction];
                                   }];
        }
    });
}

+ (instancetype)storyWithJSON:(NSDictionary *)json
{
    NYTStory *story = [[NYTStory alloc] init];
    
    story.section = json[@"section"];
    story.subsection = json[@"subsection"];
    story.title = json[@"title"];
    story.abstract = json[@"abstract"];
    story.urlString = json[@"url"];
    story.byline = json[@"byline"];
    story.itemType = json[@"item_type"];
    
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    NSString *updateDateString = json[@"updated_date"];
    NSString *createdDateString = json[@"created_date"];
    NSString *publishedDateString = json[@"published_date"];
    
    if (updateDateString) {
        updateDateString = [self cleanDateString:updateDateString];
                            
        story.updatedDate = [dateFormatter dateFromString:updateDateString];
    }
    if (createdDateString) {
        createdDateString = [self cleanDateString:createdDateString];
        
        story.createdDate = [dateFormatter dateFromString:createdDateString];
    }
    if (publishedDateString) {
        publishedDateString = [self cleanDateString:publishedDateString];
        
        story.publishedDate = [dateFormatter dateFromString:publishedDateString];
    }
    
    story.materialTypeFacet = json[@"material_type_facet"];
    story.kicker = json[@"kicker"];
    
    id desFacet = json[@"des_facet"];
    
    if ([desFacet isKindOfClass:[NSString class]]) {
        story.desFacetString = desFacet;
    }
    else if ([desFacet isKindOfClass:[NSArray class]]) {
        story.desFacet = desFacet;
    }
    
    id orgFacet = json[@"org_facet"];
    
    if ([orgFacet isKindOfClass:[NSString class]]) {
        story.orgFacetString = orgFacet;
    }
    else if ([orgFacet isKindOfClass:[NSArray class]]) {
        story.orgFacet = orgFacet;
    }
    
    id perFacet = json[@"per_facet"];
    
    if ([perFacet isKindOfClass:[NSString class]]) {
        story.perFacetString = perFacet;
    }
    else if ([perFacet isKindOfClass:[NSArray class]]) {
        story.perFacet = perFacet;
    }
    
    id geoFacet = json[@"geo_facet"];
    
    if ([geoFacet isKindOfClass:[NSString class]]) {
        story.geoFacetString = geoFacet;
    }
    else if ([geoFacet isKindOfClass:[NSArray class]]) {
        story.geoFacet = geoFacet;
    }
    
    NSArray *imageArray = json[@"multimedia"];
    
    if ([imageArray isKindOfClass:[NSArray class]]) {
        if (imageArray.count > 0) {
           
            NSDictionary *imageDict = nil;
            
            if (imageArray.count) {
                if (imageArray.count > 1) {
                    imageDict = imageArray[1];
                }
                else {
                    imageDict = imageArray[0];
                }
            }
            
            if (imageDict) {
                NYTStoryImage *storyImage = [NYTStoryImage storyImageFromJSON:imageDict];
                
                // Create references
                story.storyImage = storyImage;
                
                return story;
            }
            
            return nil;
        }
    }
    
    return nil;
}

static NSDateFormatter *stringFormatter;
+ (NSString *)stringFromDate:(NSDate *)date
{
    if (!stringFormatter) {
        stringFormatter = [[NSDateFormatter alloc] init];
        stringFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    return [stringFormatter stringFromDate:date];
}

#pragma mark - Private Class

static NSDateFormatter *aDateFormatter;
+ (NSDateFormatter *)dateFormatter
{
    if (!aDateFormatter) {
        aDateFormatter = [[NSDateFormatter alloc] init];
        [aDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    }
    
    return aDateFormatter;
}

+ (NSString *)cleanDateString:(NSString *)dateString
{
    dateString = [dateString stringByReplacingOccurrencesOfString:@":"
                                                       withString:@""
                                                          options:0
                                                            range:NSMakeRange([dateString length] - 5,5)];
    
    return dateString;
}

#pragma mark - Setters

- (void)setDesFacet:(NSArray *)desFacet
{
    self.desFacetString = [desFacet componentsJoinedByString:@","];
}

- (void)setOrgFacet:(NSArray *)orgFacet
{
    self.orgFacetString = [orgFacet componentsJoinedByString:@","];
}

- (void)setPerFacet:(NSArray *)perFacet
{
    self.perFacetString = [perFacet componentsJoinedByString:@","];
}

- (void)setGeoFacet:(NSArray *)geoFacet
{
    self.geoFacetString = [geoFacet componentsJoinedByString:@","];
}

#pragma mark - Getters

- (NSURL *)url
{
    return [NSURL URLWithString:self.urlString];
}

- (NSArray *)desFacet
{
    return [self.desFacetString componentsSeparatedByString:@","];
}

- (NSArray *)orgFacet
{
    return [self.orgFacetString componentsSeparatedByString:@","];
}

- (NSArray *)perFacet
{
    return [self.perFacetString componentsSeparatedByString:@","];
}

- (NSArray *)geoFacet
{
    return [self.geoFacetString componentsSeparatedByString:@","];
}

@end
