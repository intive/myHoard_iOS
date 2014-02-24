//
//  MHItemViewControllerTest.m
//  MyHoard
//
//  Created by user on 2/24/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHItemViewController.h"

@interface MHItemViewControllerTest : XCTestCase

@end

@implementation MHItemViewControllerTest {
    
    UIStoryboard *storyboard;
    MHItemViewController *_vc;
    UITableViewCell *cell;
}

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHItemViewController class])];
    [_vc view];
    cell = [_vc.tableView dequeueReusableCellWithIdentifier:@"ItemCell"];
}

- (void)tearDown
{
    cell = nil;
    _vc = nil;
    storyboard = nil;
    [super tearDown];
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}


#pragma Outlets

- (void)testThatCellExist {
    
    XCTAssertNotNil(cell, @"");
}

- (void)testThatTitleLabelExist {
    
    XCTAssertNotNil(cell.textLabel, @"");
}

- (void)testThatSubtitleLableExist {
    
    XCTAssertNotNil(cell.detailTextLabel, @"");
}

- (void)testThatNavigationItemTitleExist {
    
    XCTAssertNotNil(_vc.navigationItem.title, @"");
}

- (void)testThatAddButtonExist {
    
    XCTAssertNotNil(_vc.navigationItem.rightBarButtonItem, @"");
}

@end
