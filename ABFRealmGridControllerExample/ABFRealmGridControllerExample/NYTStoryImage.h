//
//  NYTStoryImage.h
//  ABFRealmGridControllerExample
//
//  Created by Adam Fish on 9/3/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import <Realm/Realm.h>
#import <UIKit/UIKit.h>

@interface NYTStoryImage : RLMObject

// Model

@property NSString *urlString;

@property NSString *format;

@property NSInteger height;

@property NSInteger width;

@property NSString *type;

@property NSString *subtype;

@property NSString *caption;

@property NSString *copyright;

@property NSData *imageData;

// Formatted Accessors

@property (nonatomic, readonly) NSURL *url;

@property (nonatomic, readonly) UIImage *image;

// Sends synchronous request for image data
+ (instancetype)storyImageFromJSON:(NSDictionary *)json;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<NYTStoryImage>
RLM_ARRAY_TYPE(NYTStoryImage)
