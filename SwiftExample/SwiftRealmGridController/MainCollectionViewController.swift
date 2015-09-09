//
//  MainCollectionViewController.swift
//  SwiftRealmGridController
//
//  Created by Adam Fish on 9/8/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftFetchedResultsController

let reuseIdentifier = "DefaultCell"

class MainCollectionViewController: SwiftRealmGridController {
    
    var dateFormatter: NSDateFormatter!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.sortDescriptors = [SortDescriptor(property: "publishedDate", ascending: false)]
        
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
    
        // Configure the cell
        let anObject = self.objectAtIndexPath(NYTStory.self, indexPath: indexPath)
        
        cell.titleLabel.text = anObject?.title
        cell.excerptLabel.text = anObject?.abstract
        
        if let date = anObject?.publishedDate {
            cell.dateLabel.text = self.dateFormatter.stringFromDate(date)
        }
        cell.imageView.image = anObject?.storyImage?.image
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    @IBAction func didPressRefreshButton(sender: UIBarButtonItem) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            let nytSections =
            [
                "home",
                "world",
                "national",
                "politics",
                "nyregion",
                "business",
                "opinion",
                "technology",
                "science",
                "health",
                "sports",
                "arts",
                "fashion",
                "dining",
                "travel",
                "magazine",
                "realestate"
            ]
            
            for section in nytSections {
                let urlString = "http://api.nytimes.com/svc/topstories/v1/\(section).json?api-key=388ce6e70d2a8e825757af7a0a67c397:13:59285541"
                
                let url = NSURL(string: urlString)!
                
                let topStoriesRequest = NSURLRequest(URL: url)
                
                NSURLConnection.sendAsynchronousRequest(topStoriesRequest, queue: NSOperationQueue(), completionHandler: { (response, data, connectionError) -> Void in
                    
                    if connectionError != nil {
                        return
                    }
                    
                    if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                        if let results = json["results"] as? [NSDictionary] {
                            
                            for storyJSON in results {
                                if let story = NYTStory.story(storyJSON) {
                                    Realm().write({ () -> Void in
                                        Realm().addWithNotification(story, update: true)
                                    })
                                }
                            }
                        }
                    }
                })
            }
        });
    }

}

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var excerptLabel: UILabel!
}
