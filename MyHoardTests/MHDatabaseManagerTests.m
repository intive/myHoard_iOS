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
#import "MHAPI.h"
#import <OCMock.h>

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
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:nil objStatus:@"new" objType:nil];

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

        [[co.objName should] equal:@"name"];
        NSArray* tags = co.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[co.objTags should] equal:@[@"1", @"2"]];
        
    });
    

    it(@"Add items to DB test", ^{
        MHCollection* collection = [MHDatabaseManager insertCollectionWithObjName:@"name"
                                                                   objDescription:@"1"
                                                                          objTags:@[@"1", @"2"]
                                                                   objCreatedDate:[NSDate date]
                                                                  objModifiedDate:nil
                                                      objOwnerNilAddLogedUserCode:nil
                                                                        objStatus:@"new"
                                                                          objType:nil];

        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil collection:collection objStatus:@"new"];
        
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
        
        [[item.objName should] equal:@"name"];
        NSArray* tags = item.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];

    });
    
    it(@"Take item from DB test", ^{
        
        MHCollection* collection = [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:nil objStatus:@"new" objType:nil];
        
        NSDate *itemCreatedDate = [NSDate date];
        MHItem* item = [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:itemCreatedDate objModifiedDate:nil collection:collection objStatus:@"new"];
        
        [[item.objName should] equal:@"name"];
        NSArray* tags = item.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];
        [[item.objCreatedDate should ] equal:itemCreatedDate];
    });
    
    
    it(@"Get all collections", ^{
       
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:nil objStatus:@"new" objType:nil];
        [MHDatabaseManager insertCollectionWithObjName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:nil objStatus:@"new" objType:nil];
        
        NSArray *result = [MHDatabaseManager allCollections];
        
        [[result should]beNonNil];
        [[theValue(result.count)should]equal:theValue(2)];
        
    });
    
    it(@"Add media to DB test", ^{
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:@"key" item:nil objStatus:@"new"];
        
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
        
        [[me.objCreatedDate should] beKindOfClass:[NSDate class]];
        [[me.objKey should] equal:@"key"];
        
    });
    
    it(@"Id of media should be unique", ^{
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:@"key" item:nil objStatus:@"new"];
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:@"key" item:nil objStatus:@"new"];
        
        // the same as first one, should not be added to db
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:@"key" item:nil objStatus:@"new"];
        
        NSManagedObjectContext* context = cdcTest.managedObjectContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHMedia"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSError* error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count) should] equal:theValue(3)];
    });
    

    it(@"Add item to a specified collection", ^{
       
        MHCollection* collection = [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:nil objStatus:@"new" objType:nil];
        
        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil collection:collection objStatus:@"new"];
        [MHDatabaseManager insertItemWithObjName:@"name2" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil collection:collection objStatus:@"new"];
        [MHDatabaseManager insertItemWithObjName:@"Michael Jordan" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil  objCreatedDate:[NSDate date] objModifiedDate:nil collection:collection objStatus:@"new"];
        
        [MHDatabaseManager insertItemWithObjName:@"LeBron James" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil collection:collection objStatus:@"new"];
        
        [[theValue(collection.items.count)should]equal:theValue(4)];
        
        for(MHItem *item in collection.items){
            [[item.collection should] equal:collection];
            [[item.media should] beNonNil];
            [[theValue(item.media.count)should]equal:theValue(0)];
        }
        
    });
    
    it(@"ADD collection with simulated user id(owner)", ^{
        id Mock = [OCMockObject partialMockForObject:[MHAPI getInstance]];
        [[[Mock stub] andReturn:@"1"]userId];
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:nil objStatus:@"new" objType:nil];
        
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
        
        [[co.objName should] equal:@"name"];
        [[co.objOwner should] equal:@"1"];
    });

    it(@"ADD collections with same name for different owners", ^{
        
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"1" objStatus:@"new" objType:nil];
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"2" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"2" objStatus:@"new" objType:nil];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        [[error should] beNil];
        [[fetchedObjects should] beNonNil];
        [[theValue(fetchedObjects.count)should]equal:theValue(2)];
        
    });
    
    it(@"Get collection with name for a specyfied owner", ^{
        
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2", @"3"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"1" objStatus:@"new" objType:nil];
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"2" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"2" objStatus:@"new" objType:nil];
        
        id Mock = [OCMockObject partialMockForObject:[MHAPI getInstance]];
        [[[Mock stub] andReturn:@"1"]userId];
        MHCollection *col = [MHDatabaseManager collectionWithObjName:@"name"];
        [[col.objDescription should] equal:@"1"];
        [[theValue([col.objTags count]) should]equal:theValue(3)];
        
        id Mock2 = [OCMockObject partialMockForObject:[MHAPI getInstance]];
        [[[Mock2 stub] andReturn:@"6754"]userId];
        MHCollection *col1 = [MHDatabaseManager collectionWithObjName:@"name"];
        [[col1.objDescription should]beNil];
        [[theValue([col1.objTags count]) should]equal:theValue(0)];
        
        id Mock3 = [OCMockObject partialMockForObject:[MHAPI getInstance]];
        [[[Mock3 stub] andReturn:@"2"]userId];
        MHCollection *col2 = [MHDatabaseManager collectionWithObjName:@"name"];
        [[col2.objDescription should] equal:@"2"];
        [[theValue([col2.objTags count]) should]equal:theValue(2)];
    });
    
    it(@"Get collections for a specyfied owner", ^{

        MHCollection *col1=[MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2", @"3"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"1" objStatus:@"new" objType:nil];
        MHCollection *col2=[MHDatabaseManager insertCollectionWithObjName:@"name1" objDescription:@"2" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"1"objStatus:@"new" objType:nil];
        MHCollection *col3=[MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"2" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"2" objStatus:@"new" objType:nil];
        
        id Mock = [OCMockObject partialMockForObject:[MHAPI getInstance]];
        [[[Mock stub] andReturn:@"1"]userId];
        NSArray *colAll1 = [MHDatabaseManager allCollections];
        [[theValue([colAll1 count]) should]equal:theValue(2)];
        [[[colAll1 objectAtIndex:0]should]equal:col1];
        [[[colAll1 objectAtIndex:1]should]equal:col2];
        [[[colAll1 objectAtIndex:0]shouldNot]equal:col3];
        [[[colAll1 objectAtIndex:1]shouldNot]equal:col3];
        
        id Mock2 = [OCMockObject partialMockForObject:[MHAPI getInstance]];
        [[[Mock2 stub] andReturn:@"2"]userId];
        NSArray *colAll2 = [MHDatabaseManager allCollections];
        [[theValue([colAll2 count]) should]equal:theValue(1)];
        [[[colAll2 objectAtIndex:0]should]equal:col3];
        [[[colAll2 objectAtIndex:0]shouldNot]equal:col1];
        [[[colAll2 objectAtIndex:0]shouldNot]equal:col2];

        });
    
   /* it(@"Items with same name in collection, is it possible to get duplicates?", ^{
        
        MHCollection *col1=[MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2", @"3"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwnerNilAddLogedUserCode:@"1" objStatus:@"new" objType:nil];
        
        MHItem *item1=[MHDatabaseManager insertItemWithObjName:@"nazwa" objDescription:@"1I" objTags:nil objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil collection:col1 objStatus:nil];
        MHItem *item2=[MHDatabaseManager insertItemWithObjName:@"nazwa" objDescription:@"1I" objTags:nil objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil collection:col1 objStatus:nil];
        
        NSArray *items=[MHDatabaseManager allItemsWithObjName:@"nazwa" inCollection:col1];
        [[theValue([items count]) should]equal:theValue(2)];
        [[[items objectAtIndex:1]should]equal:item1];
        [[[items objectAtIndex:0]should]equal:item2];
    });
    */
});

SPEC_END

