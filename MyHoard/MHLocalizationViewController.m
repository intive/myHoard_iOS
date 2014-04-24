//
//  MHLocalizationViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHLocalizationViewController.h"
#import "MHLocation.h"
#import "Address.h"

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
    [[MHLocation sharedInstance]startGettingLocation];
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
    _placesfinder = [[MJPlacesFinder alloc] init];
    _placesfinder.delegate = self;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
    [self.localizationText becomeFirstResponder];
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
    if ([[_localizations objectAtIndex:indexPath.row] isKindOfClass:[Address class]]) {
        Address *address = [_localizations objectAtIndex:indexPath.row];
        cell.imageView.image=[UIImage imageNamed:@"search.png"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if([address title]){
            cell.textLabel.text = [address title];
        }else{
            cell.textLabel.text = [address subtitle];
        }
        cell.detailTextLabel.text = [address subtitle];
    }else{
        CLPlacemark *placemark = _localizations[indexPath.row];
        cell.imageView.image=[UIImage imageNamed:@"search.png"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
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
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_localizations[indexPath.row] isKindOfClass:[Address class]]) {
            Address *address = [_localizations objectAtIndex:indexPath.row];
            [self.delegate selectedLocationName:[address title]];
            [self.delegate selectedLocationCoordinate:address.coordinate];
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            CLPlacemark *placemark = _localizations[indexPath.row];
#warning using description in this place is not the best idea. The address should be composed using data in placemark.addressDictionary
            [self.delegate selectedLocationName:placemark.description];
            [self.delegate selectedLocationCoordinate:placemark.location.coordinate];
            [self.navigationController setNavigationBarHidden:NO];
            [self.navigationController popViewControllerAnimated:YES];
        }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    _localizations=nil;
    if (textField == self.localizationText) {
        CLLocationCoordinate2D loc=[[MHLocation sharedInstance]currentLocation].coordinate;
        [_placesfinder findPlacesNamed:_localizationText.text near: loc withRadius:1000.0];
        [[MHLocation sharedInstance]geolocateWithCity:textField.text withStreet:nil withPostalCode:nil completionBlock:^(NSArray *object) {
            _localizations=[NSMutableArray arrayWithArray:object];
            [_localizations addObjectsFromArray:_places];
            [_tableView reloadData];
        }];

    }
    return YES;
}

- (void)placesFinder:(MJPlacesFinder *)placesFinder didFindPlaces:(NSArray *)places{
    _places=nil;
    _places=places;
    [_localizations addObjectsFromArray:_places];
    [_tableView reloadData];
}

- (void)placesFinder:(MJPlacesFinder *)placesFinder didFailWithError:(NSError *)error{
    _places=nil; 
    _localizations=nil;
    NSLog(@"no placmarks from google");
}

- (IBAction)cancelButton:(id)sender {
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
