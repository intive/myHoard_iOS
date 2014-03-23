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

- (void) drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect;

@end

@implementation MHBadgeView

- (id)initWithValue:(NSNumber *)badgeValue withTextColor:(UIColor *)badgeTextColor withBackgroundColor:(UIColor *)badgeBackgroundColor withScale:(CGFloat)badgeScale {
    
    self = [super initWithFrame:CGRectMake(0, 0, 25, 25)];
    if (self) {
        
        self.contentScaleFactor = [[UIScreen mainScreen]scale];
        self.backgroundColor = [UIColor clearColor];
        _badgeBackgroundColor = [UIColor darkerYellow];
        _badgeValue = badgeValue;
        _badgeTextColor = [UIColor darkerGray];
        _badgeCorner = 0.40;
        _badgeScale = badgeScale;

        [self autoResizeBadgeWithValue:badgeValue];
    }
    
    return self;
    
}

- (void)autoResizeBadgeWithValue:(NSNumber *)badgeValue {
    
    NSString *badgeValueToString = [NSString stringWithFormat:@"%@", badgeValue];

    CGSize returnAutoResizeValue;
    CGFloat rectWidth;
    CGFloat rectHeight;
    CGSize badgeValueSize = [badgeValueToString sizeWithFont:[UIFont boldSystemFontOfSize:12]];
    CGFloat spacing;
    
    if ([badgeValueToString length] >= 2) {
        
        spacing = [badgeValueToString length];
        rectWidth = 25 + (badgeValueSize.width + spacing);
        rectHeight = 25;
        returnAutoResizeValue = CGSizeMake(rectWidth * _badgeScale, rectHeight * _badgeScale);
    }else {
        
        returnAutoResizeValue = CGSizeMake(25 * _badgeScale, 25 * _badgeScale);
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, returnAutoResizeValue.width, returnAutoResizeValue.height);
    
    _badgeValue = badgeValue;
    [self setNeedsDisplay];
}

+ (MHBadgeView *)createBadgeWithValue:(NSNumber *)badgeValue withTextColor:(UIColor *)textColor withBackgroundColor:(UIColor *)backgroundColor withScale:(CGFloat)badgeScale {
    
    return [[self alloc] initWithValue:badgeValue withTextColor:textColor withBackgroundColor:backgroundColor withScale:badgeScale];
}

-(void) drawRoundedRectWithContext:(CGContextRef)context withRect:(CGRect)rect {
    
	CGContextSaveGState(context);
	
	CGFloat radius = CGRectGetMaxY(rect) * _badgeCorner;
	CGFloat offset = CGRectGetMaxY(rect) * 0.10;
	CGFloat maxX = CGRectGetMaxX(rect) - offset;
	CGFloat maxY = CGRectGetMaxY(rect) - offset;
	CGFloat minX = CGRectGetMinX(rect) + offset;
	CGFloat minY = CGRectGetMinY(rect) + offset;
    
    CGContextBeginPath(context);
	CGContextSetFillColorWithColor(context, [_badgeBackgroundColor CGColor]);
	CGContextAddArc(context, maxX-radius, minY+radius, radius, M_PI+(M_PI/2), 0, 0);
	CGContextAddArc(context, maxX-radius, maxY-radius, radius, 0, M_PI/2, 0);
	CGContextAddArc(context, minX+radius, maxY-radius, radius, M_PI/2, M_PI, 0);
	CGContextAddArc(context, minX+radius, minY+radius, radius, M_PI, M_PI+M_PI/2, 0);
	CGContextSetShadowWithColor(context, CGSizeMake(1.0,1.0), 3, [[UIColor blackColor] CGColor]);
    CGContextFillPath(context);
    
	CGContextRestoreGState(context);
    
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self drawRoundedRectWithContext:context withRect:rect];
    
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