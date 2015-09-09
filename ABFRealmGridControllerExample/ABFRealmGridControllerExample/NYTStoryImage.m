//
//  NYTStoryImage.m
//  ABFRealmGridControllerExample
//
//  Created by Adam Fish on 9/3/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "NYTStoryImage.h"

@implementation NYTStoryImage

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"urlString" : @"",
             @"format" : @"",
             @"type" : @"",
             @"subtype" : @"",
             @"caption" : @"",
             @"copyright" : @"",
             };
}

// Specify properties to ignore (Realm won't persist these)

+ (NSArray *)ignoredProperties
{
    return @[@"image",
             @"url"
             ];
}

+ (instancetype)storyImageFromJSON:(NSDictionary *)json
{
    NYTStoryImage *storyImage = [[NYTStoryImage alloc] init];
    
    storyImage.urlString = json[@"url"];
    storyImage.format = json[@"format"];
    storyImage.height = ((NSNumber *)json[@"height"]).integerValue;
    storyImage.width = ((NSNumber *)json[@"width"]).integerValue;
    storyImage.type = json[@"type"];
    storyImage.subtype = json[@"subtype"];
    storyImage.caption = json[@"caption"];
    storyImage.copyright = json[@"copyright"];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:storyImage.url];
    
    storyImage.imageData = [NSURLConnection sendSynchronousRequest:imageRequest
                                                 returningResponse:nil
                                                             error:nil];
    
    return storyImage;
}

#pragma mark - Getters

- (UIImage *)image
{
    return [UIImage imageWithData:self.imageData];
}

- (NSURL *)url
{
    return [NSURL URLWithString:self.urlString];
}

@end
