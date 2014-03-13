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

@interface MHCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
