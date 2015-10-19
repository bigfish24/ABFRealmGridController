//
//  MainGridController.m
//  ABFRealmGridControllerExample
//
//  Created by Adam Fish on 8/25/15.
//  Copyright (c) 2015 Adam Fish. All rights reserved.
//

#import "MainGridController.h"
#import "MainCollectionViewCell.h"
#import "NYTStory.h"

#import <TOWebViewController/TOWebViewController.h>
#import <Haneke/Haneke.h>

@interface MainGridController ()

@end

@implementation MainGridController

static NSString * const reuseIdentifier = @"MainCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.entityName = @"NYTStory";
    
    self.sortDescriptors = @[[RLMSortDescriptor sortDescriptorWithProperty:@"publishedDate" ascending:NO]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                             forIndexPath:indexPath];
    
    // Configure the cell
    NYTStory *story = [self objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = story.title;
    cell.dateLabel.text = [NYTStory stringFromDate:story.publishedDate];
    cell.excerptLabel.text = story.abstract;
    
    // Use Haneke image caching
    [cell.imageView hnk_setImageFromURL:story.storyImage.url];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NYTStory *story = [self objectAtIndexPath:indexPath];
    
    TOWebViewController *webController = [[TOWebViewController alloc] initWithURLString:story.urlString];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - <UICollectionViewFlowLayoutDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 250.0;
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
        CGFloat columns = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 3.0 : 2.0;
        
        CGFloat width = CGRectGetWidth(self.view.frame) / columns;
        
        return CGSizeMake(width, height);
    }
    else {
        CGFloat columns = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0 : 3.0;
        
        CGFloat width = CGRectGetWidth(self.view.frame) / columns;
        
        return CGSizeMake(width, height);
    }
}

#pragma mark - Actions

- (IBAction)didPressRefreshButton:(UIBarButtonItem *)sender
{
    [NYTStory loadLatestStoriesIntoRealm:[RLMRealm defaultRealm]
                              withAPIKey:@"388ce6e70d2a8e825757af7a0a67c397:13:59285541"];
}

@end
