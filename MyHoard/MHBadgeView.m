//
//  MHBadgeView.m
//  MyHoard
//
//  Created by user on 23/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBadgeView.h"
#import "UIColor+customColors.h"

@interface MHBadgeView ()

@property (nonatomic, readonly) NSInteger maxBadgeValue;

@end

@implementation MHBadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {

    self.backgroundColor = [UIColor clearColor];
    self.badgeValue = _badgeValue;
    _badgeBackgroundColor = [UIColor badgeBackgroundColor];
    _badgeTextColor = [UIColor darkerGray];
    _badgeCorner = 10.0;
    _badgeScale = 1.0;
    _maxBadgeValue = 99;
    _badgePositionX = 95;
    _badgePositionY = 100;
    
    _offsetFactor = 10;
    
#pragma mark - for independent positioning
    
    _badgeLayoutSubviewLengthLimit = 2;
    _badgeLayoutSubviewLengthMultiplier = 5;
    
    self.layer.cornerRadius = _badgeCorner;
    self.layer.backgroundColor = [_badgeBackgroundColor CGColor];
    self.layer.shadowRadius = 8;
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.shadowOpacity = 0.5;

}

- (CGFloat)fontSize {
    return 10 * _badgeScale;
}

- (CGSize)intrinsicContentSize {
    NSString *badgeValueToString = [NSString stringWithFormat:@"%@", _badgeValue];
    
    CGSize badgeValueSize = [badgeValueToString sizeWithFont:[UIFont boldSystemFontOfSize:[self fontSize]]];
    
    if ([badgeValueToString length] > _badgeLayoutSubviewLengthLimit) {
        return CGSizeMake( badgeValueSize.width + _offsetFactor, 20);
    } else {
        return CGSizeMake(20, 20);
    }
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    _badgeValue = badgeValue;
	[self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
    NSString *badgeValueToString = [NSString stringWithFormat:@"%@", _badgeValue];
	
	if ([badgeValueToString length]>0) {
		[_badgeTextColor set];
		CGFloat sizeOfFont = [self fontSize];
        
        if ([_badgeValue integerValue] > _maxBadgeValue) {
            badgeValueToString = [NSString stringWithFormat:@"%ld+", (long)_maxBadgeValue];
        }
        
		UIFont *textFont = [UIFont boldSystemFontOfSize:sizeOfFont];
		CGSize textSize = [badgeValueToString sizeWithFont:textFont];
		[badgeValueToString drawAtPoint:CGPointMake((rect.size.width/2-textSize.width/2), (rect.size.height/2-textSize.height/2)) withFont:textFont];
        
	}
	
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self invalidateIntrinsicContentSize];
}

@end