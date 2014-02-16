//
//  MHItemDetailsViewController.h
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHItemDetailsViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *itemNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *itemIdTextField;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
