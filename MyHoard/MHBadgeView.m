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
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    
    _badgeValue = badgeValue;
}

-(void) drawRoundedRect:(CGRect)rect {
    
    self.layer.cornerRadius = _badgeCorner;
    self.layer.backgroundColor = [_badgeBackgroundColor CGColor];
    self.layer.shadowRadius = 8;
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.shadowOpacity = 0.5;
}

- (void)drawRect:(CGRect)rect {
	
	[self drawRoundedRect:rect];
    
    NSString *badgeValueToString = [NSString stringWithFormat:@"%@", _badgeValue];
	
	if ([badgeValueToString length]>0) {
		[_badgeTextColor set];
		CGFloat sizeOfFont = 10 * _badgeScale;
        
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
    
    self.frame = self.bounds;
    
    NSString *badgeValueToString = [NSString stringWithFormat:@"%@", _badgeValue];
    
    CGSize badgeValueSize = [badgeValueToString sizeWithFont:[UIFont boldSystemFontOfSize:10]];
    CGFloat offsetFactor = 10;
    
    if ([badgeValueToString length] > 2) {
        
        self.frame = CGRectMake(95 - ([badgeValueToString length] - 2)*5, 100, badgeValueSize.width + offsetFactor, self.frame.size.height);
        
    }else {
        
        self.frame = CGRectMake(95, 100, self.frame.size.width, self.frame.size.height);
    }
}

@end