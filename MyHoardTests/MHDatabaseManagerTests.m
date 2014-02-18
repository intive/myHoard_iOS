//
//  MHDatabaseManagerTests.m
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "Kiwi.h"
#import "MHCoreDataContextForTests.h"

#import "MHCoreDataContext.h"
#import "MHDatabaseManager.h"
#import "MHCollection.h"
#import "MHItem.h"


SPEC_BEGIN(MHDatabaseManagerTests)

describe(@"MHDatabaseManager Tests", ^{

    __block MHCoreDataContextForTests* cdcTest = nil;

    beforeEach(^{
        cdcTest = [MHCoreDataContextForTests new];
        [MHCoreDataContext stub:@selector(getInstance) andReturn:cdcTest];
    });

    afterEach(^{
        [cdcTest dropTestPersistentStore];
        cdcTest = nil;
    });
    
    it(@"Add collections to DB test", ^{
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(1)];

        MHCollection* co = [fetchedObjects objectAtIndex:0];

        [[co.objId should] equal:@"1"];
        [[co.objName should] equal:@"name"];
        [[theValue(co.objTags.count) should] equal:theValue(2)];
        [[co.objTags should] equal:@[@"1", @"2"]];
    });
    

    it(@"Add items to DB test", ^{
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"1" objOwner:nil];
        
        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(1)];
        
        MHItem* item = [fetchedObjects objectAtIndex:0];
        
        [[item.objId should] equal:@"1"];
        [[item.objName should] equal:@"name"];
        [[theValue(item.objTags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];

    });
    
    it(@"Remove items by objCollectionId form DB test", ^{
       
       [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"carsCollection" objOwner:nil];
        
       [MHDatabaseManager insertItemWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"3", @"4"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"otherCollection" objOwner:nil];
        
        [MHDatabaseManager removeAllItemForCollectionWithObjId:@"carsCollection"];
        
        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(1)];
        
        MHItem* item = [fetchedObjects objectAtIndex:0];
        
        [[item.objId should] equal:@"2"];
        [[item.objName should] equal:@"name2"];
        [[theValue(item.objTags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"3", @"4"]];
        [[item.objCollectionId should] equal:@"otherCollection"];

        [[fetchedObjects shouldNot]contain:@"carsCollection"];
        
    });
    
    it(@"Get all items by objCollectionId from DB test", ^{
        
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        
        NSArray *fetchedObjects = [MHDatabaseManager getAllItemsForCollectionWithObjId:@"testId"];
        
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(1)];
        
        MHItem *item = [fetchedObjects objectAtIndex:0];
        
        [[item.objCollectionId should] equal:@"testId"];
        [[item.objCollectionId shouldNot] equal:@"test2"];
        [[item.objCollectionId shouldNot] equal:@"2test"];
        [[item.objCollectionId should] startWithString:@"test"];
        
    });

    it(@"Get item by objId from DB test", ^{
        
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"test" objOwner:nil];
        
        MHItem *item = [MHDatabaseManager getItemWithObjId:@"1"];
        
        [[item should] beNonNil];
        [[item.objId should] equal:@"1"];
        [[item.objCollectionId should] equal:@"test"];
        
    });
    
});

SPEC_END

