//
//  MHCollectionViewController.h
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHCollectionCell.h"
#import <CoreData/CoreData.h>
#import "MHCollection.h"
#import "MHCoreDataContext.h"
#import "MHBaseViewController.h"
#import "MHBadgeView.h"
#import "UIActionSheet+ButtonState.h"
#import "MHDatabaseManager.h"
#import "MHMedia+Images.h"

@interface MHCollectionViewController : MHBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end