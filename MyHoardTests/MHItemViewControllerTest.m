//
//  MHItemViewControllerTest.m
//  MyHoard
//
//  Created by user on 2/24/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHItemViewController.h"
#import "MHItem.h"
#import "MHCoreDataContextForTests.h"
#import "MHDatabaseManager.h"
#import "Kiwi.h"

@interface MHItemViewControllerTest : XCTestCase

@end

@implementation MHItemViewControllerTest {
    
    UIStoryboard *storyboard;
    MHItemViewController *_vc;
    UITableViewCell *cell;
}

static id partialMockForView() {
    
    MHItemViewController *viewController = [[MHItemViewController alloc]init];
    id mockViewController = [KWMock partialMockForObject:viewController];
    return mockViewController;
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

- (void)testViewDidLoad {
    
    [_vc viewDidLoad];

    XCTAssertNotNil(_vc.fetchedResultsController, @"");
    
    [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
    
    [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
    
    [MHDatabaseManager insertItemWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"3", @"4"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
    
    MHItem *fetchedItem2 = [_vc.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    MHItem *fetchedItem1 = [_vc.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    XCTAssertNotNil(fetchedItem1, @"");
    XCTAssertEqualObjects(fetchedItem1.objName, @"name", @"");
    XCTAssertNotNil(fetchedItem2, @"");
    XCTAssertEqualObjects(fetchedItem2.objName, @"name2", @"");
    
    [MHDatabaseManager removeAllItemForCollectionWithObjId:@"testId"];
    [MHDatabaseManager removeCollectionWithId:@"testId"];
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

SPEC_BEGIN(test)

    describe(@"MHItemViewController", ^{
        
        __block MHCoreDataContextForTests* mhi = nil;
        
        beforeEach(^{
            mhi = [MHCoreDataContextForTests new];
            [MHCoreDataContext stub:@selector(getInstance) andReturn:mhi];
        });
        
        afterEach(^{
            [mhi dropTestPersistentStore];
            mhi = nil;
        });
       
        it(@"Should return number of sections", ^{
           
            id mockFetchedResultsController = [KWMock mockForClass:[NSFetchedResultsController class]];
            [[mockFetchedResultsController stubAndReturn:[NSObject new]]section];
            
            id mockViewController = partialMockForView();
            [[mockViewController stubAndReturn:mockFetchedResultsController]fetchedResultsController];
            
            UITableView *tableView = [[UITableView alloc]init];
            id mockTableView = [KWMock partialMockForObject:tableView];
            [[mockTableView stubAndReturn:[KWValue valueWithInteger:1]]numberOfSectionsInTableView:mockTableView];
            
            NSInteger numberOfSections = [mockViewController numberOfSectionsInTableView:mockTableView];
            
            [[theValue(numberOfSections) should]equal:theValue(1)];
            
        });
        
        it(@"Should return number of rows in section", ^{
            
            NSInteger numberOfRows = 23;
            
            id mockSectionInfo = [KWMock mockForProtocol:@protocol(NSFetchedResultsSectionInfo)];
            [[mockSectionInfo stubAndReturn:[KWValue valueWithInteger:numberOfRows]]numberOfObjects];
            
            id mockFetchedResultsController = [KWMock mockForClass:[NSFetchedResultsController class]];
            [[mockFetchedResultsController stubAndReturn:@[mockSectionInfo]]sections];
            
            UITableView *tableView = [[UITableView alloc]init];
            id mockTableView = [KWMock partialMockForObject:tableView];
            [[mockTableView stubAndReturn:[KWValue valueWithInteger:numberOfRows]]numberOfRowsInSection:0];
            
            id mockViewController = partialMockForView();
            
            [[mockViewController stubAndReturn:mockFetchedResultsController] fetchedResultsController];
            
            NSInteger numberOfRowsInSection = [mockTableView numberOfRowsInSection:0];
            NSInteger numberORISFromMSI = [mockSectionInfo numberOfObjects];
            NSInteger numberOSIMFRC = [[mockFetchedResultsController sections] count];
            NSInteger numberOSFromMVC = [mockViewController numberOfSectionsInTableView:mockTableView];
            
            
            [[theValue(numberOfRowsInSection)should]equal:theValue(numberOfRows)];
            [[theValue(numberOfRows)should]equal:theValue(numberORISFromMSI)];
            [[theValue(numberOSIMFRC)should]equal:theValue(1)];
            [[theValue(numberOSFromMVC)should]equal:theValue(1)];
            
        });
        
        it(@"NSFetchResultsController should return object at index path", ^{
            
            [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
            
            [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
            [fetchRequest setEntity:entity];

            NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:NO];
            
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            
            [fetchRequest setFetchBatchSize:20];
            
            NSFetchedResultsController *rc = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:mhi.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
            
            NSError *error = nil;
            
            [rc performFetch:&error];
            
            MHItem *item = [rc objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            [[error should]beNil];
            [[item should]beNonNil];
            [[item.objName should]equal:@"name"];
            
            [MHDatabaseManager removeCollectionWithId:@"testId"];
            [MHDatabaseManager removeAllItemForCollectionWithObjId:@"testId"];
            
        });
    });

SPEC_END