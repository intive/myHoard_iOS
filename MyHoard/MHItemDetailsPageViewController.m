//
//  MHItemDetailsPageViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 08/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsPageViewController.h"
#import "MHImageCache.h"

@interface MHItemDetailsPageViewController ()

@end

@implementation MHItemDetailsPageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(doneButton:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    _pageImages= [[NSMutableArray alloc] init];
    for(MHMedia *media in _item.media) {
        [_pageImages addObject:[[MHImageCache sharedInstance] imageForKey:media.objKey]];
    }
    if (![_pageImages count]) {
        [_pageImages addObject:[UIImage imageNamed:@"gray"]];
    }
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    MHItemDetailsViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+50);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (MHItemDetailsViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    MHItemDetailsViewController *MHItemDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    MHItemDetailsViewController.img = self.pageImages[index];
    MHItemDetailsViewController.item= self.item;
    MHItemDetailsViewController.pageIndex = index;
    
    return MHItemDetailsViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((MHItemDetailsViewController *) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((MHItemDetailsViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (IBAction)doneButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Edit item", @"Delete item", nil];
    [actionSheet showInView:self.view];
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                   message:@"Do you want to delete the item?"
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
    
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"ChangeItemSettingsSegue" sender:_item];
            break;
        case 1:
            [alert show];
            break;
        default:
            break;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ChangeItemSettingsSegue"]) {
        UINavigationController *nc = segue.destinationViewController;
        MHItemDetailsViewController *vc = (MHItemDetailsViewController *)nc.visibleViewController;
        vc.item = _item;
    }
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex{
    __block MHWaitDialog *waitDialog = [[MHWaitDialog alloc]init];
    switch (buttonIndex) {
        case 1:
            [waitDialog show];
            if ([[MHAPI getInstance]userId]&&([self.item.collection.objType isEqualToString:collectionTypePrivate] || [self.item.collection.objType isEqualToString:collectionTypePublic])){
                MHCollection *acollection = self.item.collection;
                self.item.collection = nil;
                self.item.objStatus = @"deleted";
                NSArray *itemMedia = [MHDatabaseManager allMediaInItem:self.item];
                [MHDatabaseManager removeMediaInItem:self.item];
                for (int i=0; i<[itemMedia count]; i++){
                    MHMedia *media = [itemMedia objectAtIndex:i];
                    [[MHImageCache sharedInstance]cacheImage:nil forKey:media.objKey];
                }
                [MHDatabaseManager removeItemWithObjName:self.item.objName inCollection:acollection];
                [[MHAPI getInstance] deleteItemWithId: self.item completionBlock:^(id object, NSError *error){
                    if (error){
                        [waitDialog dismiss];
                        UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:error.localizedDescription
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                        [err show];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        for (int i=0; i<[itemMedia count]; i++){
                            MHMedia *media = [itemMedia objectAtIndex:i];
                            [[MHAPI getInstance]deleteMedia:media completionBlock:^(id object, NSError *error){
                                if (error){
                                    [waitDialog dismiss];
                                    UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:error.localizedDescription
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                                    [err show];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
                                else
                                    [waitDialog dismiss];
                            }];
                        }
                        
                        [[MHAPI getInstance]updateCollection:acollection completionBlock:^(id object, NSError *error){
                            if (error){
                                [waitDialog dismiss];
                                UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                              message:error.localizedDescription
                                                                             delegate:nil
                                                                    cancelButtonTitle:@"OK"
                                                                    otherButtonTitles:nil];
                                [err show];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                            else
                                [waitDialog dismiss];
                        }];
                        [waitDialog dismiss];
                        [self.navigationController popViewControllerAnimated:YES];
                    };
                    
                }];
                
            }
            else
            {
                MHCollection *acollection = self.item.collection;
                self.item.collection = nil;
                NSArray *itemMedia = [MHDatabaseManager allMediaInItem:self.item];
                [MHDatabaseManager removeMediaInItem:self.item];
                for (int i=0; i<[itemMedia count]; i++){
                    MHMedia *media = [itemMedia objectAtIndex:i];
                    [[MHImageCache sharedInstance]cacheImage:nil forKey:media.objKey];
                }
                [MHDatabaseManager removeItemWithObjName:self.item.objName inCollection:acollection];
                [waitDialog dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
            
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
