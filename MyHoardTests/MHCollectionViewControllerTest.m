//
//  MHCollectionViewControllerTest.m
//  MyHoard
//
//  Created by user on 2/24/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CollectionViewController.h"
#import "MHCollection.h"

@interface MHCollectionViewControllerTest : XCTestCase

@end

@implementation MHCollectionViewControllerTest{
    
    UIStoryboard *storyboard;
    CollectionViewController *_vc;
    UITableViewCell *cell;
}

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([CollectionViewController class])];
    [_vc view];
    cell = [_vc.tableView dequeueReusableCellWithIdentifier:@"CollectionsCell"];
}

- (void)tearDown
{
    cell = nil;
    _vc = nil;
    storyboard = nil;
    [super tearDown];
}

- (void)testViewDidLoad {
    
    [_vc viewDidLoad];
    
    XCTAssertNotNil(_vc.fetchedResultsController, @"");
    
    MHCollection *fetchedCollection = [_vc.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    XCTAssertNotNil(fetchedCollection, @"");
    XCTAssertEqualObjects(fetchedCollection.objId, @"somecollection", @"");
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
