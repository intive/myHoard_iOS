//
//  MHLocalizationViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHLocalizationViewController.h"
#import "MHLocation.h"

@interface MHLocalizationViewController ()

@end

@implementation MHLocalizationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    _tableView.scrollEnabled = NO;
    [self.navigationController setNavigationBarHidden:YES];
    _tableView.backgroundColor = [UIColor locationTableViewBackground];
    _tableView.tintColor = [UIColor collectionNameFrontColor];
    self.view.backgroundColor=[UIColor locationTableViewBackground];
    _localizationText.backgroundColor=[UIColor locationFieldBackground];
    _lineSeparatingTableView.backgroundColor=[UIColor lighterYellow];
    _localizationText.textColor=[UIColor darkerYellow];
    [_tableView setSeparatorColor:[UIColor darkerYellow]];
    [_cancelButtonColor setTitleColor:[UIColor lighterYellow] forState:UIControlStateNormal];
    [self.localizationText becomeFirstResponder];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_localizations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    CLPlacemark *placemark = _localizations[indexPath.row];
    cell.imageView.image=[UIImage imageNamed:@"search.png"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    NSMutableString *sub=[[NSMutableString  alloc]init];
    
    if (placemark.thoroughfare.length)
    {
        [sub appendFormat:@"%@", placemark.thoroughfare];
    }
    if (placemark.subThoroughfare.length)
    {
        [sub appendFormat:@" %@", placemark.subThoroughfare];
    }
    if (placemark.thoroughfare.length || placemark.subThoroughfare.length)
    {
    [sub appendFormat:@", "];
    }
    if (placemark.postalCode.length)
    {
        [sub appendFormat:@"%@", placemark.postalCode];
    }
    if (placemark.locality.length)
    {
        [sub appendFormat:@" %@", placemark.locality];
    }
    if (placemark.locality.length || placemark.postalCode.length)
    {
        [sub appendFormat:@", "];
    }
    if (placemark.country.length)
    {
        [sub appendFormat:@"%@", placemark.country];
    }
    
    if (placemark.areasOfInterest.firstObject!=NULL) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@", placemark.areasOfInterest.firstObject];
    cell.detailTextLabel.text = sub;
    }else{
       cell.textLabel.text = sub;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLPlacemark *placemark = _localizations[indexPath.row];
    [[self delegate]setLocationName:placemark.description];
    [[self delegate]setLocationCoordinate:placemark.location.coordinate];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.localizationText) {
        [[MHLocation sharedInstance]geolocateWithCity:textField.text withStreet:nil withPostalCode:nil completionBlock:^(NSArray *object) {
            _localizations=object;
            NSLog(@"%d",[_localizations count]);
            [_tableView reloadData];
        }];

    }
    return YES;
}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
