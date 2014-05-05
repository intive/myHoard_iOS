//
//  MHLocationTests.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 05/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHLocation.h"
#import "Kiwi.h"
#import <OCMock/OCMock.h>
#import <CoreLocation/CoreLocation.h>

SPEC_BEGIN(locationTest)

describe(@"MHLocationTests", ^{
    
    context(@"Test geolocation", ^{
        
        it(@"Is returnig value correctly?", ^{
            id Mock = [OCMockObject mockForClass:[CLLocationManager class]];
            //cllocationManager.h ma property :"
            /*
             *  location
             *
             *  Discussion:
             *      The last location received. Will be nil until a location has been received.
             *
            @property(readonly, nonatomic) CLLocation *location;"*/
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];
            [[[Mock stub] andReturn:loc]location];//Jak zrobic aby wiedzial o jakie location mi chodzi?
            
        });
        
        it(@"Czy ten test ma jakis sens2?", ^{
            id Mock = [OCMockObject mockForClass:[CLLocationManager nullMock]];
            //CLLocation *loc = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];
            [Mock stub];
            [[[[MHLocation sharedInstance]currentLocation] should]beNil];
        });
        
        it(@"Czy ten test ma jakis sens?", ^{
        id Mock = [OCMockObject partialMockForObject:[MHLocation sharedInstance]];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];
        [[[Mock stub] andReturn:loc]currentLocation];
        [[[[MHLocation sharedInstance]currentLocation] should]equal:loc];

        });
        
    });

});

SPEC_END
