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
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

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
                                                                         objOwner:nil];

        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil  objOwner:nil collection:collection];
        
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
        
        MHCollection* collection = [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSDate *itemCreatedDate = [NSDate date];
        MHItem* item = [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:itemCreatedDate objModifiedDate:nil objOwner:nil collection:collection];
        
        [[item.objName should] equal:@"name"];
        NSArray* tags = item.objTags;
        [[theValue(tags.count) should] equal:theValue(2)];
        [[item.objTags should] equal:@[@"1", @"2"]];
        [[item.objCreatedDate should ] equal:itemCreatedDate];
    });
    
    
    it(@"Get all collections", ^{
       
        [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        [MHDatabaseManager insertCollectionWithObjName:@"name2" objDescription:@"2" objTags:@[@"2", @"1"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        NSArray *result = [MHDatabaseManager allCollections];
        
        [[result should]beNonNil];
        [[theValue(result.count)should]equal:theValue(2)];
        
    });
    
    it(@"Add media to DB test", ^{
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka" item:nil];
        
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
        [[me.objOwner should] equal:@"ja"];
        [[me.objLocalPath should] equal:@"sciezka"];
        
    });
    
    it(@"Id of media should be unique", ^{
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka" item:nil];
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka2" item:nil];
        
        // the same as first one, should not be added to db
        [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objOwner:@"ja" objLocalPath:@"sciezka" item:nil];
        
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
       
        MHCollection* collection = [MHDatabaseManager insertCollectionWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];
        
        [MHDatabaseManager insertItemWithObjName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil collection:collection];
        [MHDatabaseManager insertItemWithObjName:@"name2" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil collection:collection];
        [MHDatabaseManager insertItemWithObjName:@"Michael Jordan" objDescription:@"1" objTags:@[@"1", @"2"] objLocation:nil  objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil collection:collection];
        
        [MHDatabaseManager insertItemWithObjName:@"LeBron James" objDescription:@"2" objTags:@[@"1", @"2"] objLocation:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil collection:collection];
        
        [[theValue(collection.items.count)should]equal:theValue(4)];
        
        for(MHItem *item in collection.items){
            [[item.collection should] equal:collection];
            [[item.media should] beNonNil];
            [[theValue(item.media.count)should]equal:theValue(0)];
        }
        
    });

});

SPEC_END

