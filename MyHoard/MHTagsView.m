//
//  MHTagsView.m
//  MyHoard
//
//  Created by user on 11/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHTagsView.h"

@implementation MHTagsView

- (void)baseInit {
    
    _aslabelone = [[CBAutoScrollLabel alloc]init];
    _aslabeltwo = [[CBAutoScrollLabel alloc]init];
    
    _duration = 1.0;
    _delay = 3.5;

    _indexLabelOne = 0;
    _indexLabelTwo = 1;
    
#pragma Different tag types for testing (all working properly)
    
    //two kinds %2 == 1
    //_tagList = [NSArray arrayWithObjects:@"#jkljkljkljkljkljklljkljghjghjghjghj", @"#LabelTwo", @"#LabelOne", @"#LabelTwo", @"#TagFourjusttoseeinfyoucanscroll", @"#LabelTwo", @"#hakunamatanahosannnapannaannna", nil];
    
    //short ones
    //_tagList = [NSArray arrayWithObjects:@"#TagOne", @"#TagTwo", @"#TagThree", @"#TagFour", @"#TagFive", nil];
    
    //long ones
    //_tagList = [NSArray arrayWithObjects:@"#jkljkljkljkljkljklljkljghjghjghjghj", @"#qweqweqweqweqweqweqweqweqeqwe", @"#fghgfhfghfghfghfghfghfgh", @"#cbvcvbcvbcvbcvbcvbcvbcvbcvb", @"#TagFourjusttoseeinfyoucanscroll", @"#iopiopiopiopiopiopiopio", @"#hakunamatanahosannnapannaannna", nil];
    
    //two kinds %2 == 0
    _tagList = [NSArray arrayWithObjects:@"#jkljkljkljkljkljklljkljghjghjghjghj", @"#LabelTwo", @"#fghgfhfghfghfghfghfghfgh", @"#LabelTwo", @"#TagFourjusttoseeinfyoucanscroll", @"#LabelTwo", @"#hakunamatanahosannnapannaannna", @"#LabelTwo", nil];

    //two kinds mix
    //_tagList = [NSArray arrayWithObjects:@"#jkljkljkljkljkljklljkljghjghjghjghj", @"#TagOne", @"#TagTwo", @"#LabelTwo", @"#TagFourjusttoseeinfyoucanscroll", @"#LabelTwo", @"#hakunamatanahosannnapannaannna", @"#LabelTwo", nil];
    
#pragma label one
    
    _aslabelone.textColor = [UIColor blueColor];
    _aslabelone.labelSpacing = 35;
    _aslabelone.pauseInterval = 1.7;
    _aslabelone.scrollSpeed = 30;
    _aslabelone.textAlignment = NSTextAlignmentCenter;
    _aslabelone.fadeLength = 12.f;
    _aslabelone.scrollDirection = CBAutoScrollDirectionLeft;
    _aslabelone.frame = CGRectMake(0, 0, 145, 50);
    
#pragma label two
    
    _aslabeltwo.textColor = [UIColor blueColor];
    _aslabeltwo.labelSpacing = 35;
    _aslabeltwo.pauseInterval = 1.7;
    _aslabeltwo.scrollSpeed = 30;
    _aslabeltwo.textAlignment = NSTextAlignmentCenter;
    _aslabeltwo.fadeLength = 12.f;
    _aslabeltwo.scrollDirection = CBAutoScrollDirectionLeft;
    _aslabeltwo.frame = CGRectMake(0, 0, 145, 50);

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
        [self addSubview:_aslabelone];
        [self addSubview:_aslabeltwo];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        [self baseInit];
        [self addSubview:_aslabelone];
        [self addSubview:_aslabeltwo];
    }
    return self;
}

- (void)checkLabelIndexing {
    
    if ([_tagList count] % 2 == 0) {
        
        if (_indexLabelOne == [_tagList count] || _indexLabelOne == [_tagList count]-1 || _indexLabelOne == [_tagList count]-2) {
            _indexLabelOne = -2;
            if ([_aslabeltwo.text isEqualToString:[NSString stringWithFormat:@"%@", [_tagList lastObject]]]) {
                _indexLabelTwo = -1;
                _indexLabelOne = -2;
            }
        }
        
        if (_indexLabelTwo == [_tagList count]-2 || _indexLabelTwo == [_tagList count]-1) {
            _indexLabelTwo = -1;
            if ([_aslabelone.text isEqualToString:[NSString stringWithFormat:@"%@", [_tagList lastObject]]]) {
                _indexLabelOne = -1;
                _indexLabelTwo = -2;
            }
        }
    }
    
    if ([_tagList count] % 2 == 1) {
        
        NSUInteger randomIndex = arc4random_uniform(3) + 1;
        
        _tagList = [_tagList arrayByAddingObject: _tagList[randomIndex]];
        
#pragma conditions for [_taglist count] beeing an odd number
        /*
        if (_indexLabelTwo == [_tagList count] || _indexLabelTwo == [_tagList count]-1 || _indexLabelTwo == [_tagList count]-2) {
            _indexLabelTwo = -2;
            if ([_aslabelone.text isEqualToString:[NSString stringWithFormat:@"%@", [_tagList lastObject]]]) {
                _indexLabelOne = -2;
                _indexLabelTwo = -1;
            }
        }
        
        if (_indexLabelOne == [_tagList count]-2 || _indexLabelOne == [_tagList count]-1) {
            _indexLabelOne = -1;
            if ([_aslabeltwo.text isEqualToString:[NSString stringWithFormat:@"%@", [_tagList lastObject]]]) {
                _indexLabelTwo = -1;
                _indexLabelOne = -2;
            }
        }
         */
#pragma end of conditions
        
#pragma new conditions for _taglist provided with extra random picked number
        
        if (_indexLabelOne == [_tagList count] || _indexLabelOne == [_tagList count]-1 || _indexLabelOne == [_tagList count]-2) {
            _indexLabelOne = -2;
            if ([_aslabeltwo.text isEqualToString:[NSString stringWithFormat:@"%@", [_tagList lastObject]]]) {
                _indexLabelTwo = -1;
                _indexLabelOne = -2;
            }
        }
        
        if (_indexLabelTwo == [_tagList count]-2 || _indexLabelTwo == [_tagList count]-1) {
            _indexLabelTwo = -1;
            if ([_aslabelone.text isEqualToString:[NSString stringWithFormat:@"%@", [_tagList lastObject]]]) {
                _indexLabelOne = -1;
                _indexLabelTwo = -2;
            }
        }
    }
}

- (void)animateLabels {
    
    _aslabelone.text = _tagList[_indexLabelOne];
    _aslabeltwo.text = _tagList[_indexLabelTwo];

    //Set alpha of second label to 0
    _aslabeltwo.alpha = 0;

    if (_aslabelone.scrolling == YES) {
        [self performSelector:@selector(crossFade) withObject:nil afterDelay:_delay];
    }else {
        [self performSelector:@selector(crossFade) withObject:nil];
    }
}

- (void)crossFade {
    
    if (!_aslabelone.text.length && !_aslabeltwo.text.length)
        return;
    
    [self checkLabelIndexing];
    
    if (_aslabeltwo.scrolling == YES) {

        
        [UIView animateWithDuration:_duration animations:^{
            [_aslabelone setAlpha:0];
            [_aslabeltwo setAlpha:1];
            [UIView commitAnimations];
        } completion:^(BOOL finished) {
            
            _indexLabelOne += 2;
            _aslabelone.text = _tagList[_indexLabelOne];
            
            if (_aslabelone.scrolling == YES) {
                
                [UIView animateWithDuration:_duration delay:_delay options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut animations:^{
                    [_aslabelone setAlpha:1];
                    [_aslabeltwo setAlpha:0];
                    [UIView commitAnimations];
                } completion:^(BOOL finished) {
                    
                    _indexLabelTwo += 2;
                    _aslabeltwo.text = _tagList[_indexLabelTwo];
                    [self performSelector:@selector(crossFade) withObject:nil afterDelay:_delay];
                    
                }];
                
            }else {
                
                [UIView animateWithDuration:_duration animations:^{
                    [_aslabelone setAlpha:1];
                    [_aslabeltwo setAlpha:0];
                    [UIView commitAnimations];
                } completion:^(BOOL finished) {
                    
                    _indexLabelTwo += 2;
                    _aslabeltwo.text = _tagList[_indexLabelTwo];
                    [self performSelector:@selector(crossFade) withObject:nil];
                    
                }];
            }
        }];
        
    }else {
        
        [UIView animateWithDuration:_duration animations:^{
            [_aslabelone setAlpha:0];
            [_aslabeltwo setAlpha:1];
            [UIView commitAnimations];
        } completion:^(BOOL finished) {
        
            _indexLabelOne += 2;
            _aslabelone.text = _tagList[_indexLabelOne];
            
            if (_aslabelone.scrolling) {
                
                [UIView animateWithDuration:_duration animations:^{
                    [_aslabelone setAlpha:1];
                    [_aslabeltwo setAlpha:0];
                    [UIView commitAnimations];
                } completion:^(BOOL finished) {
                    
                    _indexLabelTwo += 2;
                    _aslabeltwo.text = _tagList[_indexLabelTwo];
                    [self performSelector:@selector(crossFade) withObject:nil afterDelay:_delay];
                    
                }];
            }else {
                
                [UIView animateWithDuration:_duration animations:^{
                    [_aslabelone setAlpha:1];
                    [_aslabeltwo setAlpha:0];
                    [UIView commitAnimations];
                } completion:^(BOOL finished) {
                    
                    _indexLabelTwo += 2;
                    _aslabeltwo.text = _tagList[_indexLabelTwo];
                    [self performSelector:@selector(crossFade) withObject:nil];
                    
                }];
            }
        }];
    }
}

- (void)updateText:(NSArray *)tagList {
    
    _tagList = tagList;
}

@end
