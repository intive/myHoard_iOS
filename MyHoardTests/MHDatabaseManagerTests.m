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


SPEC_BEGIN(MHDatabaseManagerTests)

describe(@"MHDatabaseManager Tests", ^{

    MHCoreDataContextForTests* cdcTest = [MHCoreDataContextForTests getInstance];

    beforeEach(^{
        [MHCoreDataContext stub:@selector(getInstance) andReturn:cdcTest];
    });

    afterEach(^{
        [cdcTest dropTestPersistentStore];
    });

    it(@"Add objects to DB test", ^{
        [MHDatabaseManager insertCollectionWithObjId:@"1" objName:@"name" objDescription:@"1" objTags:@[@"1", @"2"] objItemsNumber:nil objCreatedDate:[NSDate date] objModifiedDate:nil objOwner:nil];

        NSManagedObjectContext* context = [MHCoreDataContextForTests getInstance].managedObjectContext;
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
    
});

SPEC_END
