//
//  MHDatabaseManager.h
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHCollection, MHItem, MHMedia;

@interface MHDatabaseManager : NSObject

#pragma mark - Collection
+ (void)insertCollectionWithObjId:(NSString*)objId
                          objName:(NSString*)objName
                   objDescription:(NSString*)objDescription
                          objTags:(NSArray*)objTags
                   objItemsNumber:(NSNumber*)objItemsNumber
                   objCreatedDate:(NSDate*)objCreatedDate
                  objModifiedDate:(NSDate*)objModifiedDate
                         objOwner:(NSString*)objOwner;

+ (MHCollection*)getCollectionWithObjId:(NSString*)objId;

+ (NSArray*)getAllCollections;

+ (void)removeCollectionWithId:(NSString*)objId;


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
                   objOwner:(NSString*)objOwner;


+ (MHItem*)itemWithObjId:(NSString*)objId;

+ (NSArray*)getAllItemsForCollectionWithObjId:(NSString*)collectionObjId;

+ (void)removeItemWithObjId:(NSString*)objId;

+ (void)removeAllItemForCollectionWithObjId:(NSString*)collectionObjId;

#pragma mark - Media
+ (void)insertMediaWithObjId:(NSString*)objId
                          objItem:(NSString*)objItem
                   objCreatedDate:(NSDate*)objCreatedDate
                         objOwner:(NSString*)objOwner
                     objLocalPath:(NSString*)objLocalPath;

+ (MHMedia*)mediaWithObjId:(NSString*)objId;

+ (void)removeMediaWithObjId:(NSString*)objId;

@end
