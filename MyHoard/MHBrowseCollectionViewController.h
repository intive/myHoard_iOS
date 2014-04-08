//
//  MHBrowseCollectionViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHCollection.h"

@protocol CollectionSelectorDelegate <NSObject>

- (void)collectionSelected:(MHCollection *)collection;

@end

@interface MHBrowseCollectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak) id <CollectionSelectorDelegate> delegate;

- (IBAction)cancelButton:(id)sender;
- (IBAction)addButton:(id)sender;

@end
