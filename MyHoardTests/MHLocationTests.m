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

            // zmienne z małej litery i podajemy typ jeśli go znamy
            //id Mock = [OCMockObject mockForClass:[CLLocationManager class]]; kiwi ma swojego moca i można krócej:
            CLLocationManager* mock = [CLLocationManager nullMock];
            //cllocationManager.h ma property :"
            /*
             *  location
             *
             *  Discussion:
             *      The last location received. Will be nil until a location has been received.
             *
            @property(readonly, nonatomic) CLLocation *location;"*/
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];

            //[[[mock stub] andReturn:loc]location];//Jak zrobic aby wiedzial o jakie location mi chodzi?
            // stub jest deprecated, powinieneś użyć:
            [mock stub:@selector(location) andReturn:loc];

            [[[mock location] should] equal:loc];
            
        });
        
        it(@"Czy ten test ma jakis sens2?", ^{
            id Mock = [OCMockObject mockForClass:[CLLocationManager nullMock]];
            //CLLocation *loc = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];
            [Mock stub]; // sam stub to zamało, musisz dodać jaką metodę chcesz podmienić i co ma zwrócić (patrz powyżej)
            [[[[MHLocation sharedInstance]currentLocation] should]beNil];


            /*
             * Ten test ma mało sensu, generalnie nie podajesz czego stuba chcesz zrobić oraz czego od niego oczekujesz
             * dodatkowo sprawdzasz w zasadzie tylko to czy OCMockObj stowrzy Ci nullMocka i wszystkie zwracane metody będą nilami
             * napewno wystarczy sam KWMock jak w pierwszym teście i nullMock i mamy zagwarantowane, że wszystkie metody będą nilem,
             * no chyba, że dodamy stub i powiemy że ma być inaczej
             */
        });
        
        it(@"Czy ten test ma jakis sens?", ^{

        /*
         * Ten test nie robi tego co pewnie chciałeś osiągnąć. MHLocation jest singletonem i jego chcielibyśmy w sumie testować.
         * W twoim wypadku stworzysz mock, zrobisz mu stub na metodę i jak w teście powyżej sprawdzisz czy stub zadział tak jak chciałeś.
         * Więcej sensu by to miało jakbyś zrobił mocki CLLocationManager i CLGeocoder podmienił te których używa MHLocation i sprawdził
         * czy wszystkie twoje metody działają jak oczekujesz, ale to jest już nieco bardziej skomplikowane i mogą się pojawić jakieś problemy
         * np przy blockach ;)
         */
        id Mock = [OCMockObject partialMockForObject:[MHLocation sharedInstance]];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:-56.6462520 longitude:-36.6462520];
        [[[Mock stub] andReturn:loc]currentLocation];
        [[[[MHLocation sharedInstance]currentLocation] should]equal:loc];

        });
        
    });

});

SPEC_END
