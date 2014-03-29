//
//  MHCollectionCell.h
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHBadgeView.h"
#import "MHKenBurns.h"
#import "MHTagsView.h"

@interface MHCollectionCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *collectionTitle;
@property (weak, nonatomic) IBOutlet MHBadgeView *badgeView;
@property (weak, nonatomic) IBOutlet MHKenBurns *kenBurnsView;
@property (weak, nonatomic) IBOutlet MHTagsView *tagsView;

@end
