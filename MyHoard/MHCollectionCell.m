//
//  MHCollectionCell.m
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollectionCell.h"

@implementation MHCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor collectionThumbnailOutlineColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
