//
//  NYTStory.swift
//  SwiftRealmGridController
//
//  Created by Adam Fish on 9/8/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

import RealmSwift

class NYTStory: Object {
    dynamic var section = ""
    
    dynamic var subsection = ""
    
    dynamic var title = ""
    
    dynamic var abstract = ""
    
    dynamic var urlString = ""
    
    dynamic var byline = ""
    
    dynamic var itemType = ""
    
    dynamic var updatedDate = NSDate.distantPast()
    
    dynamic var createdDate: NSDate = NSDate.distantPast()
    
    dynamic var publishedDate = NSDate.distantPast()
    
    dynamic var materialTypeFacet = ""
    
    dynamic var kicker = ""
    
    dynamic var storyImage: NYTStoryImage?
    
    var url: NSURL {
        return NSURL(string: self.urlString)!
    }
    
    class func story(json: NSDictionary) -> NYTStory? {
        let story = NYTStory()
        
        if let section = json["section"] as? String {
            story.section = section
        }
        if let subsection = json["subsection"] as? String {
            story.subsection = subsection
        }
        if let title = json["title"] as? String {
            story.title = title
        }
        if let abstract = json["abstract"] as? String {
            story.abstract = abstract
        }
        if let urlString = json["url"] as? String {
            story.urlString = urlString
        }
        if let byline = json["byline"] as? String {
            story.byline = byline
        }
        if let itemType = json["item_type"] as? String {
            story.itemType = itemType
        }
        
        let dateFormatter = NYTStory.dateFormatter()
        
        if let updatedDateString = json["updated_date"] as? String {
            
            let cleanedString = NYTStory.cleanDateString(updatedDateString)
            
            if let updatedDate = dateFormatter.dateFromString(cleanedString) {
                story.updatedDate = updatedDate
            }
        }
        
        if let createdDateString = json["created_date"] as? String {
            
            let cleanedString = NYTStory.cleanDateString(createdDateString)
            
            if let updatedDate = dateFormatter.dateFromString(cleanedString) {
                story.createdDate = updatedDate
            }
        }
        
        if let publishedDateString = json["published_date"] as? String {
            
            let cleanedString = NYTStory.cleanDateString(publishedDateString)
            
            if let updatedDate = dateFormatter.dateFromString(cleanedString) {
                story.publishedDate = updatedDate
            }
        }

        if let materialTypeFacet = json["material_type_facet"] as? String {
            story.materialTypeFacet = materialTypeFacet
        }
        
        if let kicker = json["kicker"] as? String {
            story.kicker = kicker
        }
        
        
        if let imageArray = json["multimedia"] as? NSArray {
            if imageArray.count > 0 {
                
                if let imageDict = imageArray[1] as? NSDictionary {
                    
                    story.storyImage = NYTStoryImage.storyImage(imageDict)
                    
                    return story;
                }
            }
        }
        
        return nil;
    }
    
    class func dateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
        
        return dateFormatter
    }
    
    private class func cleanDateString(dateString: String) -> String {
        let string = dateString as NSString
        
        let cleanedString = string.stringByReplacingOccurrencesOfString(":", withString: "", options:NSStringCompareOptions.LiteralSearch, range: NSMakeRange(string.length - 5, 5))
        
        return cleanedString
    }

    override static func ignoredProperties() -> [String] {
        return ["url"]
    }
    
    override static func primaryKey() -> String? {
        return "title"
    }
}

class NYTStoryImage: Object {
    
    dynamic var urlString = ""
    
    dynamic var format = ""
    
    dynamic var height: Double = 0
    
    dynamic var width: Double = 0
    
    dynamic var type = ""
    
    dynamic var subtype = ""
    
    dynamic var caption = ""
    
    dynamic var copyright = ""
    
    var url: NSURL {
        return NSURL(string: self.urlString)!
    }
    
    override static func ignoredProperties() -> [String] {
        return ["url","image"]
    }
    
    class func storyImage(json: NSDictionary) -> NYTStoryImage? {
        let storyImage = NYTStoryImage()
        
        if let property = json["url"] as? String {
            storyImage.urlString = property
        }
        
        if let property = json["format"] as? String {
            storyImage.format = property
        }
        
        if let property = json["height"] as? Double {
            storyImage.height = property
        }
        
        if let property = json["width"] as? Double {
            storyImage.width = property
        }
        
        if let property = json["type"] as? String {
            storyImage.type = property
        }
        
        if let property = json["subtype"] as? String {
            storyImage.subtype = property
        }
        
        if let property = json["caption"] as? String {
            storyImage.caption = property
        }
        
        if let property = json["copyright"] as? String {
            storyImage.copyright = property
        }

        return storyImage;
    }
}
