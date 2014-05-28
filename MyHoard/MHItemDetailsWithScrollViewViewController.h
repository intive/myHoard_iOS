//
//  MHItemDetailsWithScrollViewViewController.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 22/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHItemDetailsWithScrollViewViewController : UIViewController <UIScrollViewDelegate> {
	BOOL pageControlBeingUsed;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;


- (IBAction)changePage;
@end
