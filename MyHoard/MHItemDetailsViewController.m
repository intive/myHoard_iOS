//
//  MHItemDetailsViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 13.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHItemDetailsViewController.h"
#import "UIImage+Gallery.h"

@interface MHItemDetailsViewController ()

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
    _bottomView = [[MHDragUpView alloc] initWithFrame:CGRectMake(0, 350, 320, 400)];
    _bottomView.title.text = _item.objName;
    _bottomView.comment.text = _item.objDescription;
    [self.view addSubview:_bottomView];
    for(MHMedia *media in _item.media) {
        [UIImage thumbnailForAssetPath:media.objLocalPath completion:^(UIImage *image) {
            _frontImage.image = image;
        }];
        break; //just read first item
    }
    _itemTitle.title = _item.objName;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![_bottomView visible]) {
        [_bottomView show];
    } else {
        [_bottomView hide];
    }
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
