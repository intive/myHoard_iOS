//
//  MHCollectionDetailsViewControllerTest.m
//  MyHoard
//
//  Created by user on 2/22/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CollectionDetailsViewController.h"

@interface MHCollectionDetailsViewControllerTest : XCTestCase

@end

@implementation MHCollectionDetailsViewControllerTest {
    
    UIStoryboard *storyboard;
    CollectionDetailsViewController *_vc;
}

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([CollectionDetailsViewController class])];
    [_vc view];
}

- (void)tearDown
{
    storyboard = nil;
    _vc = nil;
    [super tearDown];
    
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}


#pragma Outlets

- (void)testCollectionNameTextFieldShouldExist {
    
    XCTAssertNotNil(_vc.collectionNameTextField, @"");
}

- (void)testCollectionIdTextFieldShouldExist {
    
    XCTAssertNotNil(_vc.collectionIdTextField, @"");
}

- (void)testDeleteCollectionByIdButtonShouldExist {
    
    XCTAssertNotNil(_vc.deleteCollectionByIdButton, @"");
}

- (void)testSearchButtonShouldExist {
    
    XCTAssertNotNil(_vc.searchButton, @"");
}

- (void)testThatNavigationItemTitleExist {
    
    XCTAssertNotNil(_vc.navigationItem.title, @"");
}

- (void)testThatDoneButtonExist {
    
    XCTAssertNotNil(_vc.navigationItem.rightBarButtonItem, @"");
}

- (void)testThatCancelButtonExist {
    
    XCTAssertNotNil(_vc.navigationItem.leftBarButtonItem, @"");
}


#pragma Actions

- (void)testDeleteCollectionByIdButtonAction {
    
    NSString *action = [_vc.deleteCollectionByIdButton actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertNotEqualObjects(action, @"deleteCollection", @"Action should be deleteCollection");
}

- (void)testSearchButtonAction {
    
    NSString *action = [_vc.searchButton actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertNotEqualObjects(action, @"search", @"Action should be search");
}

- (void)testCancelButtonAction {
    
    SEL selector = NSSelectorFromString(@"cancel:");
    XCTAssertTrue([_vc respondsToSelector:selector], @"_vc should respond to selector cancelPressed:");
}

- (void)testDoneButtonAction {
    
    SEL selector = NSSelectorFromString(@"done:");
    XCTAssertTrue([_vc respondsToSelector:selector], @"_vc should respond to selector donePressed:");
}

@end
