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
    
    [self profilePictureViewShape];
    [self friendPictureViewShape];
    _loginLabel.textColor = [UIColor collectionNameFrontColor];
    _collectionsLabel.textColor = [UIColor collectionNameFrontColor];
    _photosLabel.textColor = [UIColor collectionNameFrontColor];
    _commentaryLabel.textColor = [UIColor lightGrayColor];
    _lineOne.backgroundColor = [UIColor lightGrayColor];
    _lineTwo.backgroundColor = [UIColor lightGrayColor];
    
    
    _numberOfCollections.badgeValue = @23;
    _numberOfCollections.badgeCorner = 22.0;
    [_numberOfCollections layoutIfNeeded];
    
    _numberOfPhotos.badgeValue = @23;
    _numberOfPhotos.badgeCorner = 22.0;
    [_numberOfPhotos layoutIfNeeded];
}

- (void)profilePictureViewShape {
    
    _profilePictureView.layer.backgroundColor=[[UIColor clearColor] CGColor];
    _profilePictureView.layer.cornerRadius = 75;
    _profilePictureView.layer.borderWidth = 2.0;
    _profilePictureView.layer.masksToBounds = YES;
    _profilePictureView.layer.borderColor=[[UIColor badgeBackgroundColor] CGColor];
    _profilePictureView.image = [UIImage imageNamed:@"profile.png"];
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
    
    NSArray *array = [MHDatabaseManager getAllCollections];
    return [array count];
}

- (NSInteger)photosNumber {
    
    NSArray *array = [MHDatabaseManager getAllCollections];
    NSInteger numberOfPhotos = 0;
    
    for (MHCollection *eachCollection in array) {
        numberOfPhotos += [eachCollection.objItemsNumber integerValue];
    }
    
    return numberOfPhotos;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
