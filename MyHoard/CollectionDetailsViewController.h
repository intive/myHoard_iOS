//
//  CollectionDetailsViewController.h
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionDetailsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *collectionNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *collectionIdTextField;


- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
