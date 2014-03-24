//
//  MHBadgeView.m
//  MyHoard
//
//  Created by user on 23/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBadgeView.h"
#import "UIColor+customColors.h"

@implementation MHBadgeView

- (id)initWithValue:(NSNumber *)badgeValue withTextColor:(UIColor *)badgeTextColor withBackgroundColor:(UIColor *)badgeBackgroundColor withScale:(CGFloat)badgeScale {
    
    self = [super initWithFrame:CGRectMake(0, 0, 25, 25)];
    if (self) {
        
        self.contentScaleFactor = [[UIScreen mainScreen]scale];
        self.backgroundColor = [UIColor clearColor];
        self.badgeValue = badgeValue;
        _badgeBackgroundColor = [UIColor darkerYellow];
        _badgeTextColor = [UIColor darkerGray];
        _badgeCorner = 0.40;
        _badgeScale = badgeScale;
    }
    
    return self;
    
}

- (void)setBadgeValue:(NSNumber *)badgeValue {
    
    _badgeValue = badgeValue;
    
    NSString *badgeValueToString = [NSString stringWithFormat:@"%@", badgeValue];
    
    CGSize badgeValueSize = [badgeValueToString sizeWithFont:[UIFont boldSystemFontOfSize:12]];
    CGFloat offsetFactor = 10;
    
    if ([badgeValueToString length] >= 2) {
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, badgeValueSize.width + offsetFactor, self.frame.size.height);
        
    }
    
    [self setNeedsDisplay];
    
}

+ (MHBadgeView *)createBadgeWithValue:(NSNumber *)badgeValue withTextColor:(UIColor *)textColor withBackgroundColor:(UIColor *)backgroundColor withScale:(CGFloat)badgeScale {
    
    return [[self alloc] initWithValue:badgeValue withTextColor:textColor withBackgroundColor:backgroundColor withScale:badgeScale];
}

-(void) drawRoundedRect:(CGRect)rect {
    
    self.layer.cornerRadius = 12;
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
		CGFloat sizeOfFont = 13.5 * _badgeScale;
		if ([badgeValueToString length]<2) {
			sizeOfFont += sizeOfFont * 0.20;
		}
		UIFont *textFont = [UIFont boldSystemFontOfSize:sizeOfFont];
		CGSize textSize = [badgeValueToString sizeWithFont:textFont];
		[badgeValueToString drawAtPoint:CGPointMake((rect.size.width/2-textSize.width/2), (rect.size.height/2-textSize.height/2)) withFont:textFont];
	}
	
}

@end