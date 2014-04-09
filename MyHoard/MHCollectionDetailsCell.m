//
//  MHCollectionDetailsCell.h
//  MyHoard
//
//  Created by Kacper Tłusty on 24.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollectionDetailsCell.h"

@implementation MHCollectionDetailsCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor collectionThumbnailOutlineColor];
        self.itemTitle.textColor = [UIColor collectionNameFrontColor];
        self.itemComment.textColor = [UIColor tagFrontColor];
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
