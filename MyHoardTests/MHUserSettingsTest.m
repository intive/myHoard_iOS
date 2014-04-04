//
//  MHUserSettingsTest.m
//  MyHoard
//
//  Created by user on 14/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock.h>
#import "Kiwi.h"
#import "MHUserSettings.h"

@interface MHUserSettingsTest : XCTestCase

@end

@implementation MHUserSettingsTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNSUserDefaults {
    
    id mockUserDefaults = [OCMockObject mockForClass:[NSUserDefaults class]];
    
    [[[mockUserDefaults expect]andReturn:@"Java_one"]objectForKey:@"server_preference"];
    XCTAssertNotEqual([mockUserDefaults objectForKey:@"server_preference"], @"Python", @"");
    [mockUserDefaults verify];
    
    [[[mockUserDefaults expect]andReturn:@"Python"]objectForKey:@"server_preference"];
    XCTAssertEqualObjects([mockUserDefaults objectForKey:@"server_preference"], @"Python", @"");
    
    MHUserSettings *settings = [[MHUserSettings alloc]initWithUserDefaults:mockUserDefaults];
    id mockedSettings = [OCMockObject partialMockForObject:settings];
    
    [[[mockedSettings expect]andReturnValue:OCMOCK_VALUE(MHServerTypePython)]wrappigMethod];
    
    XCTAssertEqual([mockedSettings wrappigMethod], MHServerTypePython, @"");
    
    [mockedSettings wrappigMethod];
    [mockedSettings verify];
    [mockUserDefaults verify];

}

@end