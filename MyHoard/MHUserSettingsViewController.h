//
//  MHUserSettingsViewController.h
//  MyHoard
//
//  Created by user on 3/6/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHTagsView.h"

@interface MHUserSettingsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSMutableArray *serverChoice;
@property (strong, nonatomic) NSString *selectedServer;
@property (strong, nonatomic) NSUserDefaults *defaults;

@property (weak, nonatomic) IBOutlet MHTagsView *tagsView;
@property (weak, nonatomic) IBOutlet UIPickerView *defaultServerPicker;
@property (weak, nonatomic) IBOutlet UIButton *defaultServerButton;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultServerButton;
- (IBAction)serverPreference:(id)sender;
- (IBAction)setServerPreference:(id)sender;



@end
