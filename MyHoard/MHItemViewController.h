//
//  MHItemViewController.h
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MHItemCell.h"
#import "MHBaseViewController.h"
#import "MHCoreDataContext.h"
#import "MHItem.h"
#import "MHCollection.h"
#import "MHDatabaseManager.h"
#import "MHTagsView.h"

@interface MHItemViewController : MHBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) MHCollection *collection;
@property (weak, nonatomic) IBOutlet UILabel *collectionTitle;
@property (weak, nonatomic) IBOutlet MHTagsView *collectionTags;
@property (weak, nonatomic) IBOutlet UINavigationItem *collectionName;



@end
