//
//  MHItemDetailsViewControllerTest.m
//  MyHoard
//
//  Created by user on 2/21/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHItemDetailsViewController.h"

@interface MHItemDetailsViewControllerTest : XCTestCase

@end

@implementation MHItemDetailsViewControllerTest {
    
    UIStoryboard *storyboard;
    MHItemDetailsViewController *_vc;
}

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHItemDetailsViewController class])];
    [_vc view];
}

- (void)tearDown
{
    _vc = nil;
    storyboard = nil;
    [super tearDown];
}

- (void)testViewDidLoad {
    
    [_vc viewDidLoad];
    
    _vc.itemNameTextField.delegate = self;
    _vc.itemIdTextField.delegate = self;
    _vc.itemCollectionIdTextField.delegate = self;
    
    XCTAssertEqualObjects(_vc.itemNameTextField.delegate, self, @"");
    XCTAssertEqualObjects(_vc.itemIdTextField.delegate, self, @"");
    XCTAssertEqualObjects(_vc.itemCollectionIdTextField.delegate, self, @"");
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}


#pragma Outlets

- (void)testItemNameTextFieldShouldExist {
    
    XCTAssertNotNil(_vc.itemNameTextField, @"");
}

- (void)testItemObjIdTextFieldShouldExist {
    
    XCTAssertNotNil(_vc.itemIdTextField, @"");
}

- (void)testItemObjCollectionIdTextFieldShouldExist {
    
    XCTAssertNotNil(_vc.itemCollectionIdTextField, @"");
}

- (void)testDeleteItemByIdButtonExist {
    
    XCTAssertNotNil(_vc.deleteItemById, @"");
}

- (void)testDeleteItemByCollectionIdButtonExist {
    
    XCTAssertNotNil(_vc.deleteItemByCollectionId, @"");
}

- (void)testDoneBarButtonExist {
    
    XCTAssertNotNil(_vc.doneBarButton, @"");
}

- (void)testCancelBarButtonExist {
    
    XCTAssertNotNil(_vc.cancelBarButton, @"");
}

- (void)testSearchButtonExist {
    
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

- (void)testDeleteItemByIdButtonAction {
    
    NSString *action = [_vc.deleteItemById actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertEqualObjects(action, @"deleteItem:", @"Action should be deleteItem");
}

- (void)testDeleteItemByCollectionIdButtonAction {
    
    NSString *action = [_vc.deleteItemByCollectionId actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertEqualObjects(action, @"deleteItemCollection:", @"Action should be deleteItem");
}

- (void)testSearchButtonAction {
    
    NSString *action = [_vc.searchButton actionsForTarget:_vc forControlEvent:UIControlEventTouchUpInside][0];
    XCTAssertEqualObjects(action, @"search:", @"Action should be search");
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
