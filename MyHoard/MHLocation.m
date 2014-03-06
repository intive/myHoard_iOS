//
//  MHLocation.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 01/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHLocation.h"

@implementation MHLocation

static MHLocation *sharedInstance;

+ (MHLocation *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance=[[MHLocation alloc] init];
    }
    return sharedInstance;
}

+(id)alloc {
    @synchronized(self) {
        NSAssert(sharedInstance == nil, @"Attempted to allocate a second instance of a singleton LocationController.");
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

-(id) init {
    if (self = [super init]) {
        _currentLocation = [[CLLocation alloc] init];
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
    return self;
}

- (void)startGettingLocation{
    [locationManager startUpdatingLocation];
}

- (void)stopGettingLocation{
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    _currentLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"error when getting location %@", [error description]);
}

- (void)geolocateWithCity:(NSString*) city
               withStreet:(NSString*) street
           withPostalCode:(NSString*) postal
          completionBlock:(MHLocationCompletionBlock)completionBlock{
    
    if (!city.length)
    {
        NSLog(@"One of mandatory fields is not set: city:%@", city);
        return;
    }
    NSMutableString *geostring=[[NSMutableString  alloc]init];
    [geostring appendFormat:@"%@",city];
    
    if (street.length)
    {
        [geostring appendFormat:@", %@",street];
    }
    if (postal.length)
    {
        [geostring appendFormat:@", %@",postal];
    }
    
    [self->geocoder geocodeAddressString:geostring
                       completionHandler:^(NSArray *coordinates, NSError
                                           *error) {
                           if (coordinates.count)
                           {
                               CLPlacemark *placemark = coordinates[0];
                               completionBlock(placemark.location);
                           }
                           else
                           {
                               //error
                               completionBlock(nil);
                           }
                       }];
    
}

@end
