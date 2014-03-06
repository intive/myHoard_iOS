//
//  MHLocationTests.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 05/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
/*
#import "MHLocation.h"
#import "Kiwi.h"
#import <OCMock/OCMock.h>

SPEC_BEGIN(locationTest)

describe(@"MHLocationTests", ^{
    
    context(@"Test geolocation", ^{
        
        it(@"Chcek if method returning valid location for city", ^{
            
            [[MHLocation sharedInstance]geolocateWithCity:@"New York" withStreet:nil withPostalCode:nil];
            CLLocation *geo=[[MHLocation sharedInstance]geolocation];
            NSString *geoString = [NSString stringWithFormat:@"%f%f",geo.coordinate.latitude,geo.coordinate.longitude];
            
            NSString *validGeo = @"40.723779-73.991289";
            [[geoString should]equal: validGeo];
            
        });
        
        
        it(@"Chcek if method returning valid location for city with postal code", ^{
            
            [[MHLocation sharedInstance]geolocateWithCity:@"Szczecin" withStreet:nil withPostalCode:@"71-252"];
            CLLocation *geo=[[MHLocation sharedInstance]geolocation];
            NSString *geoString = [NSString stringWithFormat:@"%f%f",geo.coordinate.latitude,geo.coordinate.longitude];
            
            NSString *validGeo = @"53.44996514.505255";
            [[geoString should]equal: validGeo];

        });
        
        it(@"Chcek if method returning valid location for street with city", ^{
            
            [[MHLocation sharedInstance]geolocateWithCity:@"Warszawa" withStreet:@"Hodowlana" withPostalCode:nil];
            CLLocation *geo=[[MHLocation sharedInstance]geolocation];
            NSString *geoString = [NSString stringWithFormat:@"%f%f",geo.coordinate.latitude,geo.coordinate.longitude];
            
            NSString *validGeo = @"52.26955921.056340";
            [[geoString should]equal: validGeo];
            
        });
        
    });
 
    context(@"Test gps location", ^{
        
        beforeAll(^{
            [[MHLocation sharedInstance]startGettingLocation];
        });
        
        it(@"Chcek if method returning valid gps coordinates", ^{
            
            CLLocation *geo=[[MHLocation sharedInstance]currentLocation];
            NSString *geoString = [NSString stringWithFormat:@"%f%f",geo.coordinate.latitude,geo.coordinate.longitude];
            
            });
    
    });

});

SPEC_END
*/