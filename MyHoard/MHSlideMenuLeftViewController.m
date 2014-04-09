//
//  MHSlideMenuLeftViewController.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 09/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSlideMenuLeftViewController.h"

@interface MHSlideMenuLeftViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray* _elements;
}
@end

@implementation MHSlideMenuLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _elements = @[@{ @"segue" : @"mainSegue",
                     @"image" : @"collection_y",
                     @"title" : @"Collections",
                     },
                  @{ @"segue" : @"profileSegue",
                     @"image" : @"profile",
                     @"title" : @"Profile",
                     },
                  @{ @"segue" : @"logoutSegue",
                     @"image" : @"",
                     @"title" : @"Logout",
                     }];

    self.view.backgroundColor = [UIColor appBackgroundColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _elements.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"slideMenuCell"];
    
    cell.textLabel.text = [_elements[indexPath.row] objectForKey:@"title"];
    cell.textLabel.textColor = [UIColor lighterYellow];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = [UIImage imageNamed:[_elements[indexPath.row] objectForKey:@"image"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *segueIdentifier = [_elements[indexPath.row] objectForKey:@"segue"];
    if (segueIdentifier.length) {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    v.backgroundColor = [UIColor lighterYellow];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, [self.mainVC leftMenuWidth], 44)];
    label.textColor = [UIColor blackColor];
    label.text = @"Menu";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:16];
    [v addSubview:label];
    
    return v;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init]; //returning empty view as footer prevents table view from drawing empty cells with separators.
}

@end
