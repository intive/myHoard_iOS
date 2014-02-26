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
#import "MHMedia.h"


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
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

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
        
        [MHDatabaseManager insertCollectionWithObjId:@"carsCollection" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjId:@"otherCollection" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

       
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
        
        for(MHItem *item in fetchedObjects){
            [[item.objCollectionId shouldNot] equal:@"carsCollection"];
        }
        
    });
    
    it(@"Get all items by objCollectionId from DB test", ^{
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        
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
        
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSDate *itemCreatedDate = [NSDate date];
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:itemCreatedDate objModifiedDate:nil objCollectionId:@"1" objOwner:nil];
        
        MHItem *item = [MHDatabaseManager itemWithObjId:@"1"];
        
        [[item.objId should] equal:@"1"];
        [[item.objName should] equal:@"name"];
        [[theValue(item.objTags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];
        [[item.objCreatedDate should ] equal:itemCreatedDate];
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
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
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
        [[[error userInfo]should]beNil];
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
        
        MHCollection *co3 = [MHDatabaseManager getCollectionWithObjId:@"1"];//checking if it is possible to get the same data more time than one
        
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
    
    it(@"Remove item with objId", ^{
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
       
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertItemWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        
        [MHDatabaseManager removeItemWithObjId:@"1"];
        
        NSManagedObjectContext *context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:context];
        
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[[error userInfo]should]beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count)should]equal:theValue(1)];
        
        MHItem *item = [fetchedObjects objectAtIndex:0];
        
        [[item.objId should]equal:@"2"];
        [[item.objName should] equal:@"name2"];
        [[theValue(item.objTags.count)should]equal:theValue(2)];
        
    });
    
    it(@"Get all collections", ^{
       
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSArray *result = [MHDatabaseManager getAllCollections];
        
        [[result should]beNonNil];
        [[theValue(result.count)should]equal:theValue(2)];
        
    });
    
    it(@"Add media to DB test", ^{
        [MHDatabaseManager insertMediaWithObjId:@"1" objItem:@"ciekaweCoTUSieBedzieWpisywac" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka"];
        
        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHMedia"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(1)];
        
        MHMedia* me = [fetchedObjects objectAtIndex:0];
        
        [[me.objId should] equal:@"1"];
        [[me.objItem should] equal:@"ciekaweCoTUSieBedzieWpisywac"];
        [[me.objCreatedDate should] beKindOfClass:[NSDate class]];
        [[me.objOwner should] equal:@"ja"];
        [[me.objLocalPath should] equal:@"sciezka"];
        
    });
    
    it(@"Id of media should be unique", ^{
        [MHDatabaseManager insertMediaWithObjId:@"1" objItem:@"ciekaweCoTUSieBedzieWpisywac" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka"];
        [MHDatabaseManager insertMediaWithObjId:@"2" objItem:@"ciekawe" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka2"];
        
        // the same as first one, should not be added to db
        [MHDatabaseManager insertMediaWithObjId:@"1" objItem:@"tuZmienie" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka"];
        
        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHMedia"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(2)];
    });
    
    it(@"Get collection by objId from DB test", ^{
        [MHDatabaseManager insertMediaWithObjId:@"1" objItem:@"ciekawe" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka"];
        
        [MHDatabaseManager insertMediaWithObjId:@"2" objItem:@"ciekawe2" objCreatedDate:[NSDate date] objOwner:@"ja2" objLocalPath:@"sciezka2"];
        
        MHMedia *me = [MHDatabaseManager mediaWithObjId:@"1"];
        
        [[me.objId should] equal:@"1"];
        [[me.objLocalPath should] equal:@"sciezka"];
        
        MHMedia *me2 = [MHDatabaseManager mediaWithObjId:@"2"];
        
        [[me2.objId should] equal:@"2"];
        [[me2.objLocalPath should] equal:@"sciezka2"];
        
        MHMedia *me3 = [MHDatabaseManager mediaWithObjId:@"1"];//checking if it is possible to get the same data more time than one
        [[me3.objId should] equal:@"1"];
        [[me3.objLocalPath should] equal:@"sciezka"];
        [[me should] equal:me3];//with the same result
        
        MHMedia *me4 = [MHDatabaseManager mediaWithObjId:@"72"];//checking if it is not getting items witch is not matching an Id
        
        [[me4.objId should] beNil];
        });

    it(@"Add item to a specified collection", ^{
       
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertItemWithObjId:@"2" objName:@"name2" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertItemWithObjId:@"3" objName:@"Michael Jordan" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjId:@"4" objName:@"LeBron James" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"" objOwner:nil];
        
        NSManagedObjectContext *context = cdcTest.managedObjectContext;
        NSFetchRequest * fetchRequest = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:context];
        
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objId==%@", @"4"]];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should]beNil];
        [[fetchedObjects should]beNonNil];
        [[theValue(fetchedObjects.count)should]equal:theValue(0)];
        
        MHCollection *collection = [MHDatabaseManager getCollectionWithObjId:@"testId"];
        [[theValue(collection.items.count)should]equal:theValue(3)];
        [[collection.objItemsNumber should]equal:theValue(3)];
        
        for(MHItem *item in collection.items){
            [[item.objCollectionId should]equal:@"testId"];
            [[item.itemMedia should]beNonNil];
            [[theValue(item.itemMedia.count)should]equal:theValue(0)];
        }
        
    });
    it(@"Remove media with objId", ^{
        
        NSDate *testDate = [NSDate date];
        
        [MHDatabaseManager insertCollectionWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjId:@"testId" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertMediaWithObjId:@"1" objItem:@"1" objCreatedDate:[NSDate date] objOwner:nil objLocalPath:nil];
        [MHDatabaseManager insertMediaWithObjId:@"2" objItem:@"2" objCreatedDate:testDate objOwner:nil objLocalPath:nil];
        
        [MHDatabaseManager removeMediaWithObjId:@"1"];
        
        NSManagedObjectContext *context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHMedia" inManagedObjectContext:context];
        
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[[error userInfo]should]beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count)should]equal:theValue(1)];
        
        MHMedia *media = [fetchedObjects objectAtIndex:0];
        
        [[media.objId should] equal:@"2"];
        [[media.objItem should] equal:@"2"];
        [[media.objCreatedDate should] equal:testDate];

        
    });


});

SPEC_END

