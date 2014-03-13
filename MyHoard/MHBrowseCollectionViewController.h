//
//  MHBrowseCollectionViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHCollection.h"

@protocol passCollectionName <NSObject>

-(void)setCollectionName:(NSString *)collectionName;
@end

@interface MHBrowseCollectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain)id <passCollectionName> delegate;
@property (nonatomic,strong)NSString *collectionNameString;
@property (nonatomic, strong) NSMutableArray *collections;
@property (nonatomic, strong) MHCollection* lastSelectedCollection;

@end