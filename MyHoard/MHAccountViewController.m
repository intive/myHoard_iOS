//
//  MHAccountViewController.m
//  MyHoard
//
//  Created by user on 04/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAccountViewController.h"

@interface MHAccountViewController ()

@end

@implementation MHAccountViewController

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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    self.disableMHHamburger = YES;
    [self addLeftMenuButton];
    
    [self loginLabelTitle];
    
    [self profilePictureViewShape];
    [self friendPictureViewShape];
    _loginLabel.textColor = [UIColor collectionNameFrontColor];
    _collectionsLabel.textColor = [UIColor collectionNameFrontColor];
    _photosLabel.textColor = [UIColor collectionNameFrontColor];
    _commentaryLabel.textColor = [UIColor lightGrayColor];
    _lineOne.backgroundColor = [UIColor lightGrayColor];
    _lineTwo.backgroundColor = [UIColor lightGrayColor];
    
    _numberOfCollections.layer.cornerRadius = 22.0;
    _numberOfPhotos.layer.cornerRadius = 22.0;

    [self badgeLayoutPositioning];
}

- (void)profilePictureViewShape {
    
    _profilePictureView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    _profilePictureView.layer.cornerRadius = 75;
    _profilePictureView.layer.borderWidth = 2.0;
    _profilePictureView.layer.masksToBounds = YES;
    _profilePictureView.layer.borderColor=[[UIColor badgeBackgroundColor] CGColor];
    
    [self refreshImageData];
    
    [_profilePictureView layoutIfNeeded];
    [_profilePictureView setNeedsDisplay];
}

- (void)refreshImageData {
    
    NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/libraryProfilePhoto.png"];
    
    if (![imagePath length]) {
        _profilePictureView.image = [UIImage imageNamed:@"profile.png"];
    }else {
        _profilePictureView.image = [UIImage imageWithContentsOfFile:imagePath];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self refreshImageData];
}

- (void)friendPictureViewShape {
    
    _friendImageView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    _friendImageView.layer.cornerRadius = 22.0;
    _friendImageView.layer.borderWidth = 2.0;
    _friendImageView.layer.masksToBounds = YES;
    _friendImageView.layer.borderColor=[[UIColor blackColor] CGColor];
    _friendImageView.image = [UIImage imageNamed:@"friends.png"];
}

- (NSInteger)collectionsNumber {
    
    NSArray *array = [MHDatabaseManager allCollections];
    return [array count];
}

- (NSInteger)photosNumber {
    
    NSArray *array = [MHDatabaseManager allCollections];
    NSInteger numberOfPhotos = 0;
    
    for (MHCollection *eachCollection in array) {
        for (MHItem *item in eachCollection.items) {
            numberOfPhotos += item.media.count;
        }
    }
    
    return numberOfPhotos;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loginLabelTitle {
    
    [[MHAPI getInstance]readUserWithCompletionBlock:^(MHUserProfile *object, NSError *error) {
        if (!error) {
            _loginLabel.text = object.email;
        }else {
            NSLog(@"%@", error);
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            
            [alert show];
        }
    }];
}

- (void)badgeLayoutPositioning {
    
    if (![self collectionsNumber]) {
        _numberOfCollections.badgeValue = @0;
    }else {
        _numberOfCollections.badgeValue = [NSNumber numberWithInteger:[self collectionsNumber]];
        [_numberOfCollections layoutIfNeeded];
    }
    
    if (![self photosNumber]) {
        _numberOfPhotos.badgeValue = @0;
    }else {
        _numberOfPhotos.badgeValue = [NSNumber numberWithInteger:[self photosNumber]];
        [_numberOfPhotos layoutIfNeeded];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
