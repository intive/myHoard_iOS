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
        
        [fetchedObjects enumerateObjectsUsingBlock:^(MHItem *item, NSUInteger idx, BOOL *stop) {
            [[item.objCollectionId shouldNot] equal:@"carsCollection"];
            [[item.objCollectionId should] equal:@"otherCollection"];
        }];
        
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

    it(@"Take item from DB test", ^{
        NSDate *itemCreatedDate = [NSDate date];
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:itemCreatedDate objModifiedDate:nil objCollectionId:@"1" objOwner:nil];
        
        MHItem *item = [MHDatabaseManager itemWithObjId:@"1"];
        
        [[item.objId should] equal:@"1"];
        [[item.objName should] equal:@"name"];
        [[theValue(item.objTags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];
        [[item.objCreatedDate] should ] equal:itemCreatedDate];
    });

    it(@"Id of collecion should be unique", ^{
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        // the same as first one, should not be added to db
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
        [[theValue(fetchedObjects.count) should] equal:theValue(2)];
    });

    it(@"Id of item should be unique", ^{
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertItemWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];

        // the same as first one, should not be added to db
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];

        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];

        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(2)];
    });

    it(@"Remove collection with id from db", ^{
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        [MHDatabaseManager removeCollectionWithId:@"1"];

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

        [[co.objId should] equal:@"2"];
        [[co.objName should] equal:@"name2"];
        [[theValue(co.objTags.count) should] equal:theValue(2)];
        [[co.objTags should] equal:@[@"2", @"1"]];
    });
    it(@"Get collection by objId from DB test", ^{
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        MHCollection *co = [MHDatabaseManager getCollectionWithObjId:@"1"];
        
        [[co.objId should] equal:@"1"];
        [[co.objName should] equal:@"name"];
        [[theValue(co.objTags.count) should] equal:theValue(2)];
        [[co.objTags should] equal:@[@"1", @"2"]];
        
        MHCollection *co2 = [MHDatabaseManager getCollectionWithObjId:@"2"];
        
        [[co2.objId should] equal:@"2"];
        [[co2.objName should] equal:@"name2"];
        [[theValue(co2.objTags.count) should] equal:theValue(2)];
        [[co2.objTags should] equal:@[@"2", @"1"]];
        
        MHCollection *co3 = [MHDatabaseManager getCollectionWithObjId:@"1"];//checking if it is possible to get the same data more time then one
        
        [[co3.objId should] equal:@"1"];
        [[co3.objName should] equal:@"name"];
        [[theValue(co3.objTags.count) should] equal:theValue(2)];
        [[co3.objTags should] equal:@[@"1", @"2"]];
        
        MHCollection *co4 = [MHDatabaseManager getCollectionWithObjId:@"72"];//checking if it is not getting items witch is not matching an Id
        
        [[co4.objId should] beNil];
        [[co4.objName should] beNil];
        [[theValue(co4.objTags.count) should] equal:theValue(0)];
        [[co4.objTags should] beNil];
    });

});

SPEC_END

