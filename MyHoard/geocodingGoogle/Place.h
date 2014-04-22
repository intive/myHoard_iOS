//
//  Place.h
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 10/10/11.
//  Copyright (c) 2011 Mohammed Jisrawi. All rights reserved.
//

#import "Address.h"

@interface Place : Address {
    NSString *googleId;
    NSString *googleIconPath;
    NSString *googleRef;
    double rating;
    NSArray *types;
}

@property (nonatomic, strong) NSString *googleId;
@property (nonatomic, strong) NSString *googleIconPath;
@property (nonatomic, strong) NSString *googleRef;
@property (nonatomic, readwrite) double rating;
@property (nonatomic, strong) NSArray *types;

@end
