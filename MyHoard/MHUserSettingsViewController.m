//
//  MHUserSettingsViewController.m
//  MyHoard
//
//  Created by user on 3/6/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHUserSettingsViewController.h"

@interface MHUserSettingsViewController ()

@end

@implementation MHUserSettingsViewController

- (void)viewDidLoad
{
    _serverChoice= [[NSMutableArray alloc]init];
    [_serverChoice addObject:@"Java_one"];
    [_serverChoice addObject:@"Java_two"];
    [_serverChoice addObject:@"Python"];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [_tagsView animateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)defaultServerPreferences {
    
    _defaults = [NSUserDefaults standardUserDefaults];
    return [_defaults objectForKey:@"server_preference"];
}

- (IBAction)serverPreference:(id)sender {
    
    _selectedServer = [[NSString alloc]initWithString:[self defaultServerPreferences]];
    NSUInteger selectedRow = [_serverChoice indexOfObject:_selectedServer];
    [_defaultServerPicker selectRow:selectedRow inComponent:0 animated:YES];
    
}

- (IBAction)setServerPreference:(id)sender {
    
    _defaults = [NSUserDefaults standardUserDefaults];
    [_defaults setObject:_selectedServer forKey:@"server_preference"];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"User Settings Saved" message:@"Default server updated" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    _selectedServer = [_serverChoice objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [_serverChoice count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [_serverChoice objectAtIndex:row];
}
@end
