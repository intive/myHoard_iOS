//
//  MHSliderMenuViewController.m
//  MyHoard
//
//  Created by user on 09/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSliderMenuViewController.h"
#import "MHSliderMenuTableCell.h"
#import "MHAPI.h"
#import "MHWaitDialog.h"
#import "MHSynchronizer.h"
#import "MHProgressView.h"

@interface MHSliderMenuViewController()

@property (nonatomic, strong) MHProgressView *progress;

@end

@implementation MHSliderMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)loadView {
    
    NSString* menu = @"Menu";
    
    UIFont* headerFont = [UIFont boldSystemFontOfSize:16];
    CGFloat menuSlideValue = 270;
    CGFloat headerPadding = (menuSlideValue / 2) - ([menu sizeWithFont:headerFont].width / 2);
    
    NSDictionary *options = @{
                              AMOptionsTableOffsetY : @(-20),
                              AMOptionsTableInsetX : @(0),
                              AMOptionsEnableGesture : @(YES),
                              AMOptionsEnableShadow : @(YES),
                              AMOptionsSetButtonDone : @(NO),
                              AMOptionsUseBorderedButton : @(NO),
                              AMOptionsButtonIcon : [UIImage imageNamed:@"hamburger"],
                              AMOptionsUseDefaultTitles : @(YES),
                              AMOptionsSlideValue : @(menuSlideValue),
                              AMOptionsBackground : [UIColor clearColor],
                              AMOptionsSelectionBackground : [UIColor clearColor],
                              AMOptionsImagePadding : @(40),
                              AMOptionsImageLeftPadding : @(0),
                              AMOptionsTextPadding : @(20),
                              AMOptionsBadgePosition : @(220),
                              AMOptionsNavbarTranslucent: @NO,
                              AMOptionsHeaderHeight : @(64),
                              AMOptionsHeaderFont : headerFont,
                              AMOptionsHeaderFontColor : [UIColor blackColor],
                              AMOptionsHeaderShadowColor : [UIColor clearColor],
                              AMOptionsHeaderPadding : @(headerPadding),
                              AMOptionsHeaderGradientUp : [UIColor lighterYellow],
                              AMOptionsHeaderGradientDown : [UIColor lighterYellow],
                              AMOptionsHeaderSeparatorUpper : [UIColor clearColor],
                              AMOptionsHeaderSeparatorLower : [UIColor clearColor],
                              AMOptionsCellFont : [UIFont systemFontOfSize:14],
                              AMOptionsCellBadgeFont : [UIFont systemFontOfSize:14],
                              AMOptionsCellFontColor : [UIColor lighterGray],
                              AMOptionsCellBackground : [UIColor lighterYellow],
                              AMOptionsCellSeparatorUpper : [UIColor clearColor],
                              AMOptionsCellSeparatorLower : [UIColor clearColor],
                              AMOptionsCellShadowColor : [UIColor clearColor],
                              AMOptionsImageHeight : @(22),
                              AMOptionsImageOffsetByY : @(11),
                              AMOptionsCellBadgeFontColor : [UIColor whiteColor],
                              AMOptionsCellBadgeBackColor : [UIColor blackColor],
                              AMOptionsDisableMenuScroll: @NO,
                              AMOptionsAnimationShrink : @YES,
                              AMOptionsAnimationShrinkValue : @0.3,
                              AMOptionsAnimationDarken : @YES,
                              AMOptionsAnimationDarkenValue : @0.7,
                              AMOptionsAnimationDarkenColor : [UIColor blackColor],
                              AMOptionsAnimationSlide : @NO,
                              AMOptionsAnimationSlidePercentage : @0.3f,
                              AMOptionsTableHeaderClass: @"MHSliderMenuHeader",
                              AMOptionsTableCellClass: @"MHSliderMenuTableCell",
                              AMOptionsTableCellHeight: @44,
                              AMOptionsTableIconMaxSize: @44,
                              AMOptionsSlideoutTime: @0.3,
                              AMOptionsTableBadgeHeight: @20,
                              AMOptionsSlideShadowOffset: @(-6),
                              AMOptionsSlideShadowOpacity: @0.4,
                              AMOptionsBadgeShowTotal: @NO,
                              AMOptionsBadgeGlobalFont: [UIFont systemFontOfSize:8],
                              AMOptionsBadgeGlobalPositionX: @20,
                              AMOptionsBadgeGlobalPositionY: @(-5),
                              AMOptionsBadgeGlobalPositionW: @16,
                              AMOptionsBadgeGlobalPositionH: @16,
                              AMOptionsBadgeGlobalTextColor: [UIColor whiteColor],
                              AMOptionsBadgeGlobalBackColor: [UIColor redColor],
                              AMOptionsBadgeGlobalShadowColor: [UIColor clearColor],
                              AMOptionsShowCellSeparatorLowerBeforeHeader: @(NO),
                              AMOptionsNavBarImage : [NSNull null],
                              };
    
    [self setSlideoutOptions:options];

    [super loadView];
}

- (void)viewDidLoad
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
	UIViewController* controller;
	
	[self addSectionWithTitle:@"Menu"];
	
	controller = [storyboard instantiateViewControllerWithIdentifier:@"MHSearchViewController"];
	[self addViewControllerToLastSection:controller tagged:1 withTitle:@"Search" andIcon:@"search"];
    
    if ([[MHAPI getInstance]activeSession]) {
        controller = [storyboard instantiateViewControllerWithIdentifier:@"MHAccountViewController"];
        [self addViewControllerToLastSection:controller tagged:2 withTitle:@"Profile" andIcon:@"profile"];
    }
    
	controller = [storyboard instantiateViewControllerWithIdentifier:@"MHCollectionViewController"];
	[self addViewControllerToLastSection:controller tagged:3 withTitle:@"Collections" andIcon:@"collection"];
	controller = [storyboard instantiateViewControllerWithIdentifier:@"MHFriendsViewController"];
	[self addViewControllerToLastSection:controller tagged:4 withTitle:@"Friends" andIcon:@"friends"];
    
    __block UINavigationController* nc = self.navigationController;
    __block MHWaitDialog *waitDialog = [[MHWaitDialog alloc]init];
    id progressDelegate = self;
    
    if ([[MHAPI getInstance]activeSession]) {
        [self addActionToLastSection:^{
            [waitDialog show];
            MHSynchronizer *sync = [[MHSynchronizer alloc]initWithAPI:[MHAPI getInstance]];
            [sync synchronize:^(NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:error.localizedDescription
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    
                    [alert show];
                }
                [waitDialog dismiss];
            } withProgress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                [progressDelegate showProgress:[NSNumber numberWithFloat:totalBytesRead/totalBytesExpectedToRead]];
                if (totalBytesRead == totalBytesExpectedToRead) {
                    [progressDelegate dismissProgress];
                }
            }];
        } tagged:5 withTitle:@"Synchronization" andIcon:@""];
    }
    
	[self addActionToLastSection:^{
        [[MHAPI getInstance] logout:^(id object, NSError *error) {
            [nc popToRootViewControllerAnimated:YES];
        }];
	}
                          tagged:6
                       withTitle:@"Logout"
                         andIcon:@"logout.png"];
    
    self.view.backgroundColor = [UIColor lighterYellow];
    [self setStartingControllerTag:3];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showProgress:(NSNumber *)progress {
    if (progress) {
        [_progress showWithProgress:progress];
    }
}

- (void)dismissProgress {
    [_progress dismiss];
}

@end
