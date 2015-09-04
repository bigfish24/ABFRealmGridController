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

#import <RBQFetchedResultsController/RBQFetchedResultsController.h>
#import <RBQFetchedResultsController/RLMObject+Notifications.h>
#import <RBQFetchedResultsController/RLMRealm+Notifications.h>

@interface MainGridController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation MainGridController

static NSString * const reuseIdentifier = @"MainCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
    
    self.sortDescriptors = @[[RLMSortDescriptor sortDescriptorWithProperty:@"publishedDate" ascending:NO]];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NYTStory *story = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = story.title;
    cell.dateLabel.text = [self.dateFormatter stringFromDate:story.publishedDate];
    cell.excerptLabel.text = story.abstract;
    cell.imageView.image = story.storyImage.image;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (IBAction)didPressRefreshButton:(UIBarButtonItem *)sender
{
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
            NSString *urlString = [NSString stringWithFormat:@"http://api.nytimes.com/svc/topstories/v1/%@.json?api-key=388ce6e70d2a8e825757af7a0a67c397:13:59285541",section];
            
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
                                       
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       
                                       NSArray *results = json[@"results"];
                                       
                                       for (NSDictionary *storyJSON in results) {
                                           NYTStory *story = [NYTStory storyWithJSON:storyJSON];
                                           
                                           if (story) {
                                               [[RLMRealm defaultRealm] transactionWithBlock:^{
                                                   [[RLMRealm defaultRealm] addOrUpdateObjectWithNotification:story];
                                               }];
                                           }
                                       }
                                   }];
            
        }
    });
}

@end
