//
//  MHMediaHelperTests.m
//  MyHoard
//
//  Created by Milena Gnoińska on 26.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MHMediaHelper.h"

@interface MHMediaHelperTests : XCTestCase

@end

@implementation MHMediaHelperTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testThumbnail
{
    id mock = [OCMockObject mockForClass:[ALAssetsLibrary class]];
    ALAsset *asset = [[ALAsset alloc]init];
    [[mock stub] andReturn:asset];
    UIImage *thumbnail = nil;
    thumbnail = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    [mock verify];
}

- (void)testImage
{
    id mock = [OCMockObject mockForClass:[ALAssetsLibrary class]];
    ALAsset *asset = [[ALAsset alloc]init];
    [[mock stub] andReturn:asset];
    UIImage *image = nil;
    image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
    [mock verify];
}

@end
