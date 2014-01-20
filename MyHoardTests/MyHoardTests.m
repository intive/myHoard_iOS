//
//  MyHoardTests.m
//  MyHoardTests
//
//  Created by Sebastian Jędruszkiewicz on 01/12/13.
//  Copyright (c) 2013 BLStream. All rights reserved.
//

/*
 * More about Kiwi syntax:
 * https://github.com/allending/Kiwi/wiki/Specs
 * https://github.com/allending/Kiwi/wiki/Expectations
 * https://github.com/allending/Kiwi/wiki/Mocks-and-Stubs
 */

#import "Kiwi.h"

SPEC_BEGIN(MathSpec)

describe(@"Sample tests", ^{

    context(@"Test if numbers are equal", ^{

        it(@"Numbers should be equal", ^{

            NSUInteger a = 16;
            NSUInteger b = 26;
            [[theValue(a + b) should] equal:theValue(42)];
        });

        it(@"Numbers should not be equal", ^{

            NSUInteger a = 10;
            NSUInteger b = 5;
            [[theValue(a - b) shouldNot] equal:theValue(15)];
        });
    });

    context(@"Test strings", ^{

        it(@"Chcek if strings are equal", ^{

            NSString* s1 = @"test";
            NSString* s2 = @"test";
            NSString* s3 = @"test_2";

            [[s1 should] equal:s2];
            [[s2 shouldNot] equal:s3];
            [[s3 should] startWithString:s1];
        });

        it(@"Test stub", ^{

            NSString* s1 = @"123";
            [[theValue(s1.length) should] equal:theValue(3)];

            // Since now length will be equal 5;
            [s1 stub:@selector(length) andReturn:theValue(5)];

            [[theValue(s1.length) shouldNot] equal:theValue(3)];
            [[theValue(s1.length) should] equal:theValue(5)];
        });

        it(@"Test mock", ^{

            NSString* s1 = [NSString nullMock];

            [[theValue(s1.length) should] equal:theValue(0)];
            [[s1 substringFromIndex:0] shouldBeNil];

            [s1 stub:@selector(substringFromIndex:) andReturn:@"substring"];

            [[s1 substringFromIndex:0] shouldNotBeNil];
            [[[s1 substringFromIndex:0] should] equal:@"substring"];
        });

    });

});

SPEC_END

