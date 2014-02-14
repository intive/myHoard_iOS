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

}


+ (MHItem*)getItemWithObjId:(NSString*)objId
{
    return nil;
}

+ (NSArray*)getAllItemsForCollectionWithObjId:(NSString*)collectionObjId
{
    return nil;
}

+ (void)removeItemWithObjId:(NSString*)objId
{

}

+ (void)removeAllItemForCollectionWithObjId:(NSString*)collectionObjId
{

}

@end
