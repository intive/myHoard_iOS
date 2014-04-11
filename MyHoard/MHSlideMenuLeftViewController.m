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

    _elements = @[@{ @"segue" : @"collectionSegue",
                     @"image" : @"collection_y",
                     @"title" : @"Collections",
                     },
                  @{ @"segue" : @"profileSegue",
                     @"image" : @"profile_y",
                     @"title" : @"Profile",
                     },
                  @{ @"segue" : @"",
                     @"image" : @"friends_y",
                     @"title" : @"Friends",
                     },
                  @{ @"segue" : @"",
                     @"image" : @"notifications_y",
                     @"title" : @"Notifications",
                     },
                  @{ @"segue" : @"",
                     @"image" : @"search_y",
                     @"title" : @"Search",
                     },
                  @{ @"segue" : @"mainSegue",
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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"slideMenuCell" forIndexPath:indexPath];
    
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor clearColor];

    cell.textLabel.text = [_elements[indexPath.row] objectForKey:@"title"];
    cell.textLabel.textColor = [UIColor lighterYellow];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    cell.imageView.image = [UIImage imageNamed:[_elements[indexPath.row] objectForKey:@"image"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *segueIdentifier = [_elements[indexPath.row] objectForKey:@"segue"];
    NSLog(@"performSegue with identifier: %@", segueIdentifier);
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
