//
//  NSString+TagsTest.m
//  MyHoard
//
//  Created by Karol Kogut on 08.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "Kiwi.h"
#import "NSString+Tags.h"

SPEC_BEGIN(NSString_Tags)

describe(@"NSString+Tags category tests", ^{

    it(@"Tests_1", ^{
        NSString *testStr = @"###";

        NSArray *tags = [testStr tags];

        [[tags should] beNil];
    });

    it(@"Tests_2", ^{
        NSString *testStr = @"# ##   ##";

        NSArray *tags = [testStr tags];

        [[tags should] beNil];
    });

    it(@"Tests_3", ^{
        NSString *testStr = @" ";

        NSArray *tags = [testStr tags];

        [[tags should] beNil];
    });

    it(@"Tests_4", ^{
        NSString *testStr = @"     ";

        NSArray *tags = [testStr tags];

        [[tags should] beNil];
    });

    it(@"Tests_5", ^{
        NSString *testStr = @"test";

        NSArray *tags = [testStr tags];

        [[tags should] beNonNil];
        [[theValue(tags.count) should] equal:theValue(1)];
        [[(NSString*)[tags objectAtIndex:0] should] equal:testStr];
    });

    it(@"Tests_6", ^{
        NSString *testStr = @"test test2";

        NSArray *tags = [testStr tags];

        [[tags should] beNonNil];
        [[theValue(tags.count) should] equal:theValue(2)];
        [[(NSString*)[tags objectAtIndex:0] should] equal:@"test"];
        [[(NSString*)[tags objectAtIndex:1] should] equal:@"test2"];
    });

    it(@"Tests_7", ^{
        NSString *testStr = @"test        test2 #   ###";

        NSArray *tags = [testStr tags];

        [[tags should] beNonNil];
        [[theValue(tags.count) should] equal:theValue(2)];
        [[(NSString*)[tags objectAtIndex:0] should] equal:@"test"];
        [[(NSString*)[tags objectAtIndex:1] should] equal:@"test2"];
    });

    it(@"Tests_8", ^{
        NSString *testStr = @"test   # #     test2";

        NSArray *tags = [testStr tags];

        [[tags should] beNonNil];
        [[theValue(tags.count) should] equal:theValue(2)];
        [[(NSString*)[tags objectAtIndex:0] should] equal:@"test"];
        [[(NSString*)[tags objectAtIndex:1] should] equal:@"test2"];
    });

    it(@"Tests_8", ^{
        NSString *testStr = @"       test   # #  test2    ";

        NSArray *tags = [testStr tags];

        [[tags should] beNonNil];
        [[theValue(tags.count) should] equal:theValue(2)];
        [[(NSString*)[tags objectAtIndex:0] should] equal:@"test"];
        [[(NSString*)[tags objectAtIndex:1] should] equal:@"test2"];
    });

    it(@"Tests_8", ^{
        NSString *testStr = @"test test2 test";

        NSArray *tags = [testStr tags];

        [[tags should] beNonNil];
        [[theValue(tags.count) should] equal:theValue(2)];
        [[(NSString*)[tags objectAtIndex:0] should] equal:@"test"];
        [[(NSString*)[tags objectAtIndex:1] should] equal:@"test2"];
    });
});

SPEC_END

