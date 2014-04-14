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


@implementation MHDatabaseManager

#pragma mark - Collection
+ (MHCollection*)insertCollectionWithObjName:(NSString*)objName
                              objDescription:(NSString*)objDescription
                                     objTags:(NSArray*)objTags
                              objCreatedDate:(NSDate*)objCreatedDate
                             objModifiedDate:(NSDate*)objModifiedDate
                                    objOwner:(NSString*)objOwner
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

    if (objDescription.length)
        collection.objDescription = objDescription;

    if (objTags.count)
        collection.objTags = objTags;

    if (objModifiedDate)
        collection.objModifiedDate = objModifiedDate;

    if (objOwner.length)
        collection.objOwner = objOwner;

    [[MHCoreDataContext getInstance] saveContext];
    return collection;
}

+ (NSArray*)allCollections
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    [fetchRequest setSortDescriptors:@[ [[NSSortDescriptor alloc] initWithKey: @"objName" ascending:YES] ]];
    
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
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objName = %@", objName]];
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
                        objOwner:(NSString*)objOwner
                      collection:(MHCollection *)collection
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
        item.objTags = objTags;
    }
    
    if (objModifiedDate) {
        item.objModifiedDate = objModifiedDate;
    }
    
    if (objOwner.length) {
        item.objOwner = objOwner;
    }
    
    [[MHCoreDataContext getInstance] saveContext];
    
    return item;
}

+ (MHItem*)itemWithObjName:(NSString*)objName{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext: [MHCoreDataContext getInstance].managedObjectContext];
    [fetch setEntity:entityDescription];
    [fetch setPredicate:[NSPredicate predicateWithFormat:@"objName = %@", objName]];
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

#pragma mark - Media
+ (MHMedia*)insertMediaWithCreatedDate:(NSDate*)objCreatedDate
                              objOwner:(NSString*)objOwner
                          objLocalPath:(NSString*)objLocalPath
                                  item:(MHItem *)item
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
    
    if (objLocalPath.length)
        media.objLocalPath = objLocalPath;
    
    if (objOwner.length)
        media.objOwner = objOwner;
    
    [[MHCoreDataContext getInstance] saveContext];
    return media;
}

@end

