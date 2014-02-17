//
//  MHDatabaseManager.m
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHDatabaseManager.h"

#import "MHCoreDataContext.h"
#import "MHCollection.h"
#import "MHItem.h"

@implementation MHDatabaseManager

#pragma mark - Collection
+ (void)insertCollectionWithObjId:(NSString*)objId
                          objName:(NSString*)objName
                   objDescription:(NSString*)objDescription
                          objTags:(NSArray*)objTags
                   objItemsNumber:(NSNumber*)objItemsNumber
                   objCreatedDate:(NSDate*)objCreatedDate
                  objModifiedDate:(NSDate*)objModifiedDate
                         objOwner:(NSString*)objOwner
{
    // mandatory fields
    if (!objId.length || !objName.length || !objCreatedDate)
    {
        NSLog(@"One of mandatory fields is not set: objId:%@, objName:%@, objCreatedDate:%@", objId, objName, objCreatedDate);
        return;
    }

#warning check if objId exist in DB

    MHCollection* collection = [NSEntityDescription insertNewObjectForEntityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];

    collection.objId = objId;
    collection.objName = objName;
    collection.objCreatedDate = objCreatedDate;

    if (objDescription.length)
        collection.objDescription = objDescription;

    if (objTags.count)
        collection.objTags = objTags;

    if (objItemsNumber)
        collection.objItemsNumber = objItemsNumber;

    if (objModifiedDate)
        collection.objModifiedDate = objModifiedDate;

    if (objOwner.length)
        collection.objOwner = objOwner;

    [[MHCoreDataContext getInstance] saveContext];
}

+ (MHCollection*)getCollectionWithObjId:(NSString*)objId
{
    return nil;
}

+ (NSArray*)getAllCollections
{
    return nil;
}

+ (void)removeCollectionWithId:(NSString*)objId
{

}


#pragma mark - Item
+ (void)insertItemWithObjId:(NSString*)objId
                    objName:(NSString*)objName
             objDescription:(NSString*)objDescription
                    objTags:(NSArray*)objTags
                objLocation:(NSDictionary*)objLocation
                objQuantity:(NSNumber*)objQuantity
                objMediaIds:(NSArray*)objMediaIds
             objCreatedDate:(NSDate*)objCreatedDate
            objModifiedDate:(NSDate*)objModifiedDate
            objCollectionId:(NSString*)objCollectionId
                   objOwner:(NSString*)objOwner
{
    
    //mandatory fields
    if (!objId.length || !objName || !objCreatedDate) {
        
        NSLog(@"One of mandatory fields is not set: objId:%@, objName:%@, objCreatedDate:%@", objId, objName, objCreatedDate);
        return;
    }
    
    MHItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    item.objId = objId;
    item.objName = objName;
    item.objCreatedDate = objCreatedDate;
    
    if (objDescription.length) {
        item.objDescription = objDescription;
    }
    
    if (objTags.count) {
        item.objTags = objTags;
    }
    
    if (objLocation.count) {
        item.objLoctaion = objLocation;
    }
    
    if (objQuantity) {
        item.objQuantity = objQuantity;
    }
    
    if (objMediaIds.count) {
        item.objMediaIds = objMediaIds;
    }
    
    if (objModifiedDate) {
        item.objModifiedDate = objModifiedDate;
    }
    
    if (objCollectionId.length) {
        item.objCollectionId = objCollectionId;
    }
    
    if (objOwner.length) {
        item.objOwner = objOwner;
    }
    
    [[MHCoreDataContext getInstance] saveContext];

}


+ (MHItem*)getItemWithObjId:(NSString*)objId
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objId = %@", objId]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    
    if([fetchedObjects count] == 1)
    {
        MHItem *item = [fetchedObjects objectAtIndex:0];
        return item;
    }
    else
        return nil;
  }

+ (NSArray*)getAllItemsForCollectionWithObjId:(NSString*)collectionObjId
{
    return nil;
}

+ (void)removeItemWithObjId:(NSString*)objId
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objId==%@", objId]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil) {
        for (NSManagedObject *object in fetchedObjects) {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:object];
        }
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
}

+ (void)removeAllItemForCollectionWithObjId:(NSString*)collectionObjId
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objCollectionId==%@", collectionObjId]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil) {
        for (NSManagedObject *object in fetchedObjects) {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:object];
        }
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
}

@end
