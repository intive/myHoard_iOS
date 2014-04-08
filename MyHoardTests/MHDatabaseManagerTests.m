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
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

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
        NSArray* tags = co.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[co.objTags should] equal:@[@"1", @"2"]];
        
    });
    

    it(@"Add items to DB test", ^{
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"1" objOwner:nil];
        
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
        NSArray* tags = item.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];

    });
    
    it(@"Get all items by objCollectionId from DB test", ^{
        
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        
        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        
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
        
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSDate *itemCreatedDate = [NSDate date];
        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:itemCreatedDate objModifiedDate:nil objCollectionId:@"1" objOwner:nil];
        
        MHItem *item = [MHDatabaseManager itemWithObjId:@"1"];
        
        [[item.objId should] equal:@"1"];
        [[item.objName should] equal:@"name"];
        NSArray* tags = item.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];
        [[item.objCreatedDate should ] equal:itemCreatedDate];
    });
    
    
    it(@"Get all collections", ^{
       
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSArray *result = [MHDatabaseManager getAllCollections];
        
        [[result should]beNonNil];
        [[theValue(result.count)should]equal:theValue(2)];
        
    });
    
    it(@"Add media to DB test", ^{
        [MHDatabaseManager insertMediaWithObjItem:@"ciekaweCoTUSieBedzieWpisywac" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka" item:nil];
        
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
        [MHDatabaseManager insertMediaWithObjItem:@"ciekaweCoTUSieBedzieWpisywac" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka" item:nil];
        [MHDatabaseManager insertMediaWithObjItem:@"ciekawe" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka2" item:nil];
        
        // the same as first one, should not be added to db
        [MHDatabaseManager insertMediaWithObjItem:@"tuZmienie" objCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka" item:nil];
        
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
    

    it(@"Add item to a specified collection", ^{
       
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertItemWithObjName:@"name2" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertItemWithObjName:@"Michael Jordan" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjName:@"LeBron James" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"" objOwner:nil];
        
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
            [[item.media should]beNonNil];
            [[theValue(item.media.count)should]equal:theValue(0)];
        }
        
    });
    it(@"Remove media with objId", ^{
        
        NSDate *testDate = [NSDate date];
        
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objQuantity:nil objMediaIds:nil objCreatedDate:[NSDate date] objModifiedDate:nil objCollectionId:@"testId" objOwner:nil];
        [MHDatabaseManager insertMediaWithObjItem:@"1" objCreatedDate:[NSDate date] objOwner:nil objLocalPath:nil item:nil];
        [MHDatabaseManager insertMediaWithObjItem:@"2" objCreatedDate:testDate objOwner:nil objLocalPath:nil item:nil];
        
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

