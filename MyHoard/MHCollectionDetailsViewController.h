//
//  MHCollectionDetailsViewController.h
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MHCollectionDetailsCell.h"
#import "MHBaseViewController.h"
#import "MHCoreDataContext.h"
#import "MHItem.h"
#import "MHCollection.h"
#import "MHDatabaseManager.h"
#import "MHMedia.h"
#import "MHCollectionDetailsHeaderView.h"
#import "UIActionSheet+ButtonState.h"


@interface MHCollectionDetailsViewController : MHBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) MHCollection *collection;
@property (weak, nonatomic) IBOutlet UINavigationItem *collectionName;



@end
