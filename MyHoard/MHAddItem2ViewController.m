//
//  MHAddItem2ViewController.m
//  
//
//  Created by Konrad Gnoinski on 11/03/14.
//
//

#import "MHAddItem2ViewController.h"
#import "MHBrowseCollectionViewController.h"
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@interface MHAddItem2ViewController ()
@property (readwrite) CGFloat animatedDistance;
@end

@implementation MHAddItem2ViewController

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
    self.titleBackground.backgroundColor = [UIColor appBackgroundColor];
    self.comentaryBackground.backgroundColor = [UIColor appBackgroundColor];
    self.localizationBackground.backgroundColor = [UIColor appBackgroundColor];
    self.collectionBackground.backgroundColor = [UIColor appBackgroundColor];
    self.titleLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.commentaryLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.collectionLabel.textColor = [UIColor collectionNameFrontColor];
    self.localizationLabel.textColor = [UIColor collectionNameFrontColor];
    self.collectionNoneLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.localizationNoneLabel.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.titleTextField.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
    self.commentaryTextField.textColor = [UIColor colorWithRed:0.6535 green:0.5085 blue:0.0978 alpha:1.0];
   // [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [textField resignFirstResponder];
        [self.commentaryTextField becomeFirstResponder];
    }
    else if (textField == self.commentaryTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)dismissKeyboard {
    [_titleTextField resignFirstResponder];
    [_commentaryTextField resignFirstResponder];
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

- ( void ) viewDidAppear:(BOOL)animated{
    //if (_collectionNameString == NULL) {
        self.collectionNoneLabel.text=_collectionNameString;
    NSLog(@"apeared");
    //}
}

/*- (void) update{
    if(){
        
    }
}*/
- (IBAction)collectionButton:(id)sender {
    MHBrowseCollectionViewController *itdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"browse"];
    [self presentViewController:itdvc animated:YES completion:nil];}

- (IBAction)backButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES ];
}

- (IBAction)doneButton:(id)sender {
}

-(void)setCollectionName:(NSString *)collectionName{
    _collectionNameString = collectionName;
}
@end
