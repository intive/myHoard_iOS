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
+ (MHCollection*)insertCollectionWithObjName:(NSString*)objName
                              objDescription:(NSString*)objDescription
                                     objTags:(NSArray*)objTags
                              objItemsNumber:(NSNumber*)objItemsNumber
                              objCreatedDate:(NSDate*)objCreatedDate
                             objModifiedDate:(NSDate*)objModifiedDate
                                    objOwner:(NSString*)objOwner;

+ (MHCollection*)collectionWithObjName:(NSString*)objName;
+ (NSArray*)allCollections;

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
                        objOwner:(NSString*)objOwner
                      collection:(MHCollection *)collection;

+ (MHItem*)itemWithObjName:(NSString*)objName;

#pragma mark - Media
+ (MHMedia*)insertMediaWithObjItem:(NSString*)objItem
                    objCreatedDate:(NSDate*)objCreatedDate
                          objOwner:(NSString*)objOwner
                      objLocalPath:(NSString*)objLocalPath
                              item:(MHItem *)item;

@end
