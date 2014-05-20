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
#import "MHMedia.h"
#import "MHApi.h"

#pragma mark - constants for collection type and object status

NSString* const collectionTypePrivate = @"private";
NSString* const collectionTypePublic = @"public";
NSString* const collectionTypeOffline = @"offline";

NSString* const objectStatusDeleted = @"deleted";
NSString* const objectStatusOk = @"ok";
NSString* const objectStatusModified = @"modified";
NSString* const objectStatusNew = @"new";

@implementation MHDatabaseManager

#pragma mark - Collection
+ (MHCollection*)insertCollectionWithObjName:(NSString*)objName
                              objDescription:(NSString*)objDescription
                                     objTags:(NSArray*)objTags
                              objCreatedDate:(NSDate*)objCreatedDate
                             objModifiedDate:(NSDate*)objModifiedDate
                 objOwnerNilAddLogedUserCode:(NSString*)objOwner
                                   objStatus:(NSString*)objStatus
                                     objType:(NSString*)objType
{
    // mandatory fields
    if (!objName.length || !objCreatedDate)
    {
        NSLog(@"One of mandatory fields is not set: objName:%@, objCreatedDate:%@", objName, objCreatedDate);
        return nil;
    }

    MHCollection* collection = [NSEntityDescription insertNewObjectForEntityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    
    collection.objName = objName;
    collection.objCreatedDate = objCreatedDate;

    if (objDescription.length) {
        collection.objDescription = objDescription;
    }

    if (objTags.count) {
        for (NSString *tag in objTags) {
            [MHDatabaseManager insertTag:tag forObject:collection];
        }
    }
    
    if (objModifiedDate) {
        collection.objModifiedDate = objModifiedDate;
    }
    
    if (objOwner.length) {
        collection.objOwner=objOwner;
    } else {
        collection.objOwner = [[MHAPI getInstance]userId];
    }
    
    if (objStatus.length){
        if ([objStatus isEqualToString:objectStatusOk] || [objStatus isEqualToString:objectStatusDeleted] || [objStatus isEqualToString:objectStatusModified] || [objStatus isEqualToString:objectStatusNew]) {
            collection.objStatus = objStatus;
        }else{
            NSLog(@"Collection status in not seted properly, options are: ok deleted modified new");
        }
    }
    
    if (objType.length){
        if ([objType isEqualToString:collectionTypeOffline] || [objType isEqualToString:collectionTypePublic] || [objType isEqualToString:collectionTypePrivate]) {
            collection.objType = objType;
        }else{
            NSLog(@"Collection type in not seted properly, options are: offline public private");
        }
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    return collection;
}

+ (NSArray*)allCollections{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objOwner = %@", [[MHAPI getInstance]userId]]];

    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
    
    [fetchRequest setSortDescriptors:@[ sd ]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error != nil)
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    
    
    return fetchedObjects;
}

+ (MHCollection*)collectionWithObjName:(NSString*)objName {
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"(objName = %@) AND (objOwner = %@)", objName,[[MHAPI getInstance]userId]]];
    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    if(error==nil){
        if([fetchedObjects count] == 1)
        {
            return [fetchedObjects objectAtIndex:0];
        }
    }
    NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    return nil;
}


#pragma mark - Item
+ (MHItem*)insertItemWithObjName:(NSString*)objName
                  objDescription:(NSString*)objDescription
                         objTags:(NSArray*)objTags
                     objLocation:(CLLocation*)objLocation
                  objCreatedDate:(NSDate*)objCreatedDate
                 objModifiedDate:(NSDate*)objModifiedDate
                      collection:(MHCollection *)collection
                       objStatus:(NSString*)objStatus
{
    
    //mandatory fields
    if (!objName || !objCreatedDate) {
        
        NSLog(@"One of mandatory fields is not set: objName:%@, objCreatedDate:%@", objName, objCreatedDate);
        return nil;
    }
    
    MHItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    item.collection = collection;
    item.objName = objName;
    item.objCreatedDate = objCreatedDate;
    
    if (objDescription.length) {
        item.objDescription = objDescription;
    }
    
    if (objTags.count) {
        for (NSString *tag in objTags) {
            [MHDatabaseManager insertTag:tag forObject:item];
        }
    }
    
    if (objModifiedDate) {
        item.objModifiedDate = objModifiedDate;
    }
    
    if (objLocation){
        item.objLocation=objLocation;
    }
    //objOwner don't need to be set becouse we are getting items only for collection, so situation where we take items from different owner then owner of a collection couldn't happen.
    
    if (objStatus.length){
        if ([objStatus isEqualToString:objectStatusOk] || [objStatus isEqualToString:objectStatusDeleted] || [objStatus isEqualToString:objectStatusModified] || [objStatus isEqualToString:objectStatusNew]) {
            item.objStatus = objStatus;
        }else{
            NSLog(@"Item status in not seted properly, options are: ok deleted modified new");
        }
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
    return item;
}

+ (NSArray*) allItemsWithObjName: (NSString*)objName inCollection:(MHCollection *)collection{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objName = %@ AND collection = %@", objName, collection]];

    NSError *error = nil;
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetch error:&error];
    return fetchedObjects;
}

+ (void)removeItemWithObjName:(NSString *)objName inCollection:(MHCollection *)collection
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objName==%@ AND collection = %@", objName, collection]];
    
    NSError *error = nil;
    
    NSArray *fetchedObjects = [[MHCoreDataContext getInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedObjects != nil && error == nil) {
        for (NSManagedObject *object in fetchedObjects) {
            [[MHCoreDataContext getInstance].managedObjectContext deleteObject:object];
        }
    }else {
        NSLog(@"Unresolved error: %@, %@", error, [error userInfo]);
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
}

#pragma mark - Media
+ (MHMedia*)insertMediaWithCreatedDate:(NSDate*)objCreatedDate
                                objKey:(NSString*)objKey
                                  item:(MHItem *)item
                             objStatus:(NSString*)objStatus
{
    // mandatory fields
    if (!objCreatedDate)
    {
        NSLog(@"One of mandatory fields is not set: objCreatedDate:%@", objCreatedDate);
        return nil;
    }
    
    MHMedia* media = [NSEntityDescription insertNewObjectForEntityForName:@"MHMedia" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
        
    media.objCreatedDate = objCreatedDate;

    media.item = item;

    media.objKey = objKey;
    
    //objOwner don't need to be set becouse we are getting media only for items, so situation where we take items from different owner then owner of a item couldn't happen.
    
    if (objStatus.length){
        if ([objStatus isEqualToString:objectStatusOk] || [objStatus isEqualToString:objectStatusDeleted] || [objStatus isEqualToString:objectStatusModified] || [objStatus isEqualToString:objectStatusNew]) {
            media.objStatus = objStatus;
        }else{
            NSLog(@"Media status in not seted properly, options are: ok deleted modified new");
        }
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    return media;
}

#pragma mark - Tag
+ (MHTag*)insertTag:(NSString *)tag
          forObject:(NSManagedObject*)object {

    MHTag* tagObject = [NSEntityDescription insertNewObjectForEntityForName:@"MHTag"
                                                     inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    tagObject.tag = tag;
    if ([object isKindOfClass:[MHCollection class]]) {
        tagObject.collection = (MHCollection *)object;
    } else if ([object isKindOfClass:[MHItem class]]){
        tagObject.item = (MHItem *)object;
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    return tagObject;
}

@end

