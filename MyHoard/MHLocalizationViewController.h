//
//  MHLocalizationViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol passLocationName <NSObject>

-(void)setLocationName:(NSString *)collectionName;
@end

@interface MHLocalizationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak)id <passLocationName> delegate;
@property (nonatomic, strong) NSArray *localizations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *localizationText;
@property (weak, nonatomic) IBOutlet UIButton *cancelButtonColor;
@property (weak, nonatomic) IBOutlet UIView *lineSeparatingTableView;
- (IBAction)cancelButton:(id)sender;

@end
