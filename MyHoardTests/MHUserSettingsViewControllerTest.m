//
//  MHUserSettingsViewControllerTest.m
//  MyHoard
//
//  Created by user on 3/6/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHUserSettingsViewController.h"

@interface MHUserSettingsViewControllerTest : XCTestCase {
    
    MHUserSettingsViewController *_vc;
    UIStoryboard *storyboard;
    NSUserDefaults *defaults;
}

@end

@implementation MHUserSettingsViewControllerTest

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHUserSettingsViewController class])];
    [_vc view];
    _vc.defaults = [NSUserDefaults standardUserDefaults];
}

- (void)tearDown
{
    _vc = nil;
    storyboard = nil;
    defaults = nil;
    [super tearDown];
}

- (void)testViewDidLoad {
    
    [_vc viewDidLoad];
    
    XCTAssertNotNil(_vc.serverChoice, @"");
    XCTAssertEqualObjects([_vc.serverChoice objectAtIndex:0], @"Java_one", @"");
    XCTAssertEqualObjects([_vc.serverChoice objectAtIndex:1], @"Java_two", @"");
    XCTAssertEqualObjects([_vc.serverChoice objectAtIndex:2], @"Python", @"");
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}


#pragma Outlets

- (void)testThatDefaultServerButtonExist {
    
    XCTAssertNotNil(_vc.defaultServerButton, @"");
}

- (void)testThatSetDefaultServerButtonExist {
    
    XCTAssertNotNil(_vc.setDefaultServerButton, @"");
}

- (void)testThatPickerViewExist {
    
    XCTAssertNotNil(_vc.defaultServerPicker, @"");
}


#pragma Actions

- (void)testDefaultServerPreference {
    
//    XCTAssertNotNil(_vc.defaults, @"");
//    XCTAssertNotNil([_vc.defaults objectForKey:@"server_preference"], @"");
}

- (void)testDefaultServerButton {
    
    NSString *action = [_vc.defaultServerButton actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertNotEqualObjects(action, @"serverPreference", @"Action should be serverPreference");
}

- (void)testSetDefaultServerButton {
    
    NSString *action = [_vc.setDefaultServerButton actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertNotEqualObjects(action, @"setServerPreference", @"Action should be setServerPreference");
}

- (void)testSetServerPreference {
    
    XCTAssertNotNil(_vc.defaults, @"");
}



@end

