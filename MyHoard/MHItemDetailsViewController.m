//
//  MHItemDetailsViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsViewController.h"
#import "UIImage+Gallery.h"
#import "MHImageCache.h"

@interface MHItemDetailsViewController ()

@property (nonatomic) BOOL ifHide;

@end

@implementation MHItemDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _ifHide = YES;
    
    _bottomView.backgroundColor = [UIColor collectionThumbnailOutlineColor];
    _bottomView.alpha = 0.6f;
    
    _itemCommentLabel.text = _item.objDescription;
    _itemCommentLabel.textColor = [UIColor tagFrontColor];
    
    _itemTitleLabel.text = _item.objName;
    _itemTitleLabel.textColor = [UIColor collectionNameFrontColor];
    for(MHMedia *media in _item.media) {
        _frontImage.image = [[MHImageCache sharedInstance] imageForKey:media.objKey];
        break; //just read first item
    }
    _itemTitle.title = _item.objName;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

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

- (IBAction)showOrHide:(id)sender
{
    if (_ifHide) {
        _ifHide = NO;
        [UIView animateWithDuration:1.0 animations:^{
            [_bottomView setFrame:CGRectMake(0, 250, 320, 400)];
            [_dragTopButton setImage:[UIImage imageNamed:@"down_g"] forState:UIControlStateNormal];

        }];

    } else {
        _ifHide = YES;
        [UIView animateWithDuration:1.0 animations:^{
            [_bottomView setFrame:CGRectMake(0, 380, 320, 400)];
            [_dragTopButton setImage:[UIImage imageNamed:@"up_g"] forState:UIControlStateNormal];
        }];
    }
}

- (IBAction)swipeToTop:(id)sender
{
    if (_ifHide) {
        _ifHide = NO;
        [UIView animateWithDuration:1.0 animations:^{
            [_bottomView setFrame:CGRectMake(0, 250, 320, 400)];
            [_dragTopButton setImage:[UIImage imageNamed:@"down_g"] forState:UIControlStateNormal];
            
        }];
        
    }
}

- (IBAction)swipeToBottom:(id)sender
{
    if (!_ifHide){
        _ifHide = YES;
        [UIView animateWithDuration:0.5 animations:^{
            [_bottomView setFrame:CGRectMake(0, 380, 320, 400)];
            [_dragTopButton setImage:[UIImage imageNamed:@"up_g"] forState:UIControlStateNormal];
        }];
    }
}

@end
