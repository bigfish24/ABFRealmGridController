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
import TOWebViewController
import Haneke

let reuseIdentifier = "DefaultCell"

class MainCollectionViewController: RealmGridController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.entityName = "NYTStory"

        // Do any additional setup after loading the view.
        self.sortDescriptors = [SortDescriptor(property: "publishedDate", ascending: false)]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MainCollectionViewCell
    
        // Configure the cell
        let aStory = self.objectAtIndexPath(NYTStory.self, indexPath: indexPath)
        
        cell.titleLabel.text = aStory?.title
        cell.excerptLabel.text = aStory?.abstract
        
        if let date = aStory?.publishedDate {
            cell.dateLabel.text = NYTStory.stringFromDate(date)
        }
        
        if let imageURL = aStory?.storyImage?.url {
            cell.imageView.hnk_setImageFromURL(imageURL)
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let story = self.objectAtIndexPath(NYTStory.self, indexPath: indexPath)
        
        if let urlString = story?.urlString {
            let webController = TOWebViewController(URLString: urlString)
            
            let navController = UINavigationController(rootViewController: webController)
            
            self.navigationController?.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let height: CGFloat = 250.0
        
        if UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.Portrait {
            let columns: CGFloat = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 3.0 : 2.0
            
            let width = CGRectGetWidth(self.view.frame) / columns
            
            return CGSizeMake(width, height)
        }
        else {
            let columns: CGFloat = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ? 4.0 : 3.0
            
            let width = CGRectGetWidth(self.view.frame) / columns
            
            return CGSizeMake(width, height)
        }
    }
    
    // MARK: Private

    @IBAction func didPressRefreshButton(sender: UIBarButtonItem) {
        NYTStory.loadLatestStories(intoRealm: try! Realm(), withAPIKey: "388ce6e70d2a8e825757af7a0a67c397:13:59285541")
    }
}

class MainCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var excerptLabel: UILabel!
}
