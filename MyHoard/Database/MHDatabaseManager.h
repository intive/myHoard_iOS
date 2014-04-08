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
+ (void)insertCollectionWithObjName:(NSString*)objName
                     objDescription:(NSString*)objDescription
                            objTags:(NSArray*)objTags
                     objItemsNumber:(NSNumber*)objItemsNumber
                     objCreatedDate:(NSDate*)objCreatedDate
                    objModifiedDate:(NSDate*)objModifiedDate
                           objOwner:(NSString*)objOwner;

+ (MHCollection*)getCollectionWithObjId:(NSString*)objId;

+ (MHCollection*)getCollectionWithObjName:(NSString*)objName;

+ (NSArray*)getAllCollections;

+ (void)removeCollectionWithId:(NSString*)objId;


#pragma mark - Item
+ (MHItem*)insertItemWithObjName:(NSString*)objName
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

+ (MHItem*)itemWithObjName:(NSString*)objName;

+ (NSArray*)getAllItemsForCollectionWithObjId:(NSString*)collectionObjId;

+ (void)removeItemWithObjId:(NSString*)objId;

+ (void)removeAllItemForCollectionWithObjId:(NSString*)collectionObjId;

#pragma mark - Media
+ (void)insertMediaWithObjItem:(NSString*)objItem
                objCreatedDate:(NSDate*)objCreatedDate
                      objOwner:(NSString*)objOwner
                  objLocalPath:(NSString*)objLocalPath
                          item:(MHItem *)item;

+ (MHMedia*)mediaWithObjId:(NSString*)objId;

+ (void)removeMediaWithObjId:(NSString*)objId;

@end
