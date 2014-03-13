//
//  MHAddCollectionViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAddCollectionViewController.h"
#import "MHDatabaseManager.h"
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@interface MHAddCollectionViewController ()
@property (readwrite) CGFloat animatedDistance;
@end

@implementation MHAddCollectionViewController

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
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.view.backgroundColor = [UIColor colorWithRed:0.09375 green:0.09375 blue:0.09375 alpha:1.0];
    self.nameBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.tagsBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.descriptionBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.questionBackgroundView.backgroundColor = [UIColor appBackgroundColor];
    self.nameLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.tagsLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];

    self.descriptionLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];

    self.questionLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];

    self.nameTextField.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.descriptionTextField.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.tagsTextField.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.questionTextField.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)add:(id)sender {
    if ([self.questionTextField.text isEqualToString:@""] || [self.nameTextField.text isEqualToString:@""] || [self.descriptionTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error" message:@"Some field is still blank" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }else{
    [MHDatabaseManager insertCollectionWithObjId:self.questionTextField.text objName:self.nameTextField.text objDescription:self.descriptionTextField.text objTags:nil objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
    [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [textField resignFirstResponder];
        [self.tagsTextField becomeFirstResponder];
    }
    else if (textField == self.tagsTextField) {
        [textField resignFirstResponder];
        [self.descriptionTextField becomeFirstResponder];
    }
    else if (textField == self.descriptionTextField) {
        [textField resignFirstResponder];
        [self.questionTextField becomeFirstResponder];
    }
    else if (textField == self.questionTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [_nameTextField resignFirstResponder];
    [_tagsTextField resignFirstResponder];
    [_descriptionTextField resignFirstResponder];
    [_questionTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    _animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += _animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

@end
