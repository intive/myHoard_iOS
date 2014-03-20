//
//  MHCollectionViewControllerTest.m
//  MyHoard
//
//  Created by Kacper Tłusty on 15.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MHCollectionViewController.h"
#import "Kiwi.h"
#import "MHDatabaseManager.h"
#import "MHCoreDataContextForTests.h"
#import "MHCollection.h"

@interface MHCollectionViewControllerTest : XCTestCase

@end

@implementation MHCollectionViewControllerTest {
    
    UIStoryboard *storyboard;
    MHCollectionViewController *_vc;
    MHCollectionCell *cell;
    
}


static id partialMockForView()
{
    
    MHCollectionViewController *viewController = [[MHCollectionViewController alloc]init];
    id mockViewController = [KWMock partialMockForObject:viewController];
    return mockViewController;
    
}

- (void)setUp
{
    [super setUp];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHCollectionViewController class])];
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
    
    XCTAssertNotNil(_vc.fetchedResultsController, @"");
    
    [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"test" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
    
    
    MHCollection *fetchedItem1 = [_vc.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    
    XCTAssertNotNil(fetchedItem1, @"");
    XCTAssertEqualObjects(fetchedItem1.objName, @"name2", @"");
    
    
    [MHDatabaseManager removeCollectionWithId:@"testId"];
}

- (void)testStoryboardShouldExist {
    
    XCTAssertNotNil(storyboard, @"");
}

- (void)testViewControllerShouldExist {
    
    XCTAssertNotNil(_vc, @"");
}

#pragma Outlets

- (void)testThatCollectionViewExist {
    XCTAssertNotNil(_vc.collectionView, @"");
}

@end

SPEC_BEGIN(collectionViewControllerTest)

describe(@"MHCollectionViewController", ^{
    
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
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MHCollectionViewController *_vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHCollectionViewController class])];
        id mockCollectionViewController = [KWMock partialMockForObject:_vc.collectionView];
        [[mockCollectionViewController stubAndReturn:[KWValue valueWithInteger:1]]numberOfSectionsInCollectionView:mockCollectionViewController];
        
        NSInteger numberOfSections = [mockViewController numberOfSectionsInCollectionView:mockCollectionViewController];
        
        [[theValue(numberOfSections) should]equal:theValue(0)];
    });
    it(@"Should return number of cells in section", ^{
        
        NSInteger numberOfRows = 10;
        
        id mockSectionInfo = [KWMock mockForProtocol:@protocol(NSFetchedResultsSectionInfo)];
        [[mockSectionInfo stubAndReturn:[KWValue valueWithInteger:numberOfRows]]numberOfObjects];
        
        id mockFetchedResultsController = [KWMock mockForClass:[NSFetchedResultsController class]];
        [[mockFetchedResultsController stubAndReturn:@[mockSectionInfo]]sections];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MHCollectionViewController *_vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MHCollectionViewController class])];
        id mockCollectionViewController = [KWMock partialMockForObject:_vc.collectionView];
        [[mockCollectionViewController stubAndReturn:[KWValue valueWithInteger:numberOfRows]] numberOfRowsInSection:0];
        
        
        id mockViewController = partialMockForView();
        
        [[mockViewController stubAndReturn:mockFetchedResultsController] fetchedResultsController];
        
        NSInteger numberORISFromMSI = [mockSectionInfo numberOfObjects];
        NSInteger numberOSIMFRC = [[mockCollectionViewController sections] count];
        NSInteger numberOSFromMVC = [mockViewController numberOfSectionsInCollectionView:mockCollectionViewController];
        
        
        
        [[theValue(numberOfRows)should]equal:theValue(numberORISFromMSI)];
        [[theValue(numberOSIMFRC)should]equal:theValue(0)];
        [[theValue(numberOSFromMVC)should]equal:theValue(0)];
        
    });
    it(@"NSFetchResultsController should return object at index path", ^{
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId2" objName:@"name2" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        [fetchRequest setFetchBatchSize:20];
        
        NSFetchedResultsController *rc = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:mhi.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        
        NSError *error = nil;
        
        [rc performFetch:&error];
        
        MHCollection *collectionOne = [rc objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        MHCollection *collectionTwo = [rc objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [[error should]beNil];
        [[collectionOne should]beNonNil];
        [[collectionOne.objName should]equal:@"name"];
        [[collectionTwo should]beNonNil];
        [[collectionTwo.objName should]equal:@"name2"];
        
        [MHDatabaseManager removeCollectionWithId:@"testId"];
        [MHDatabaseManager removeCollectionWithId:@"testId2"];
        
    });
    
});

SPEC_END
