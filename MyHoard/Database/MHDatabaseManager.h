//
//  MHDatabaseManager.h
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHCollection, MHItem, MHMedia, CLLocation;

extern NSString* const collectionTypePrivate;
extern NSString* const collectionTypePublic;
extern NSString* const collectionTypeOffline;

extern NSString* const objectStatusDeleted;
extern NSString* const objectStatusOk;
extern NSString* const objectStatusModified;
extern NSString* const objectStatusNew;

@interface MHDatabaseManager : NSObject

#pragma mark - Collection
+ (MHCollection*)insertCollectionWithObjName:(NSString*)objName
                              objDescription:(NSString*)objDescription
                                     objTags:(NSArray*)objTags
                              objCreatedDate:(NSDate*)objCreatedDate
                             objModifiedDate:(NSDate*)objModifiedDate
                 objOwnerNilAddLogedUserCode:(NSString*)objOwner
                                   objStatus:(NSString*)objStatus
                                     objType:(NSString*)objType;

+ (NSArray*)allCollections;
+ (MHCollection*)collectionWithObjName:(NSString*)objName;

#pragma mark - Item
+ (MHItem*)insertItemWithObjName:(NSString*)objName
                  objDescription:(NSString*)objDescription
                         objTags:(NSArray*)objTags
                     objLocation:(CLLocation*)objLocation
                  objCreatedDate:(NSDate*)objCreatedDate
                 objModifiedDate:(NSDate*)objModifiedDate
                      collection:(MHCollection *)collection
                       objStatus:(NSString*)objStatus;

+ (MHItem*) itemWithObjName:(NSString*)objName inCollection:(MHCollection *)collection;
+ (NSArray*) allItemsWithObjName: (NSString*)objName inCollection:(MHCollection*)collection;
+ (void)removeItemWithObjName:(NSString*)objName inCollection:(MHCollection*)collection;

#pragma mark - Media
+ (MHMedia*)insertMediaWithCreatedDate:(NSDate*)objCreatedDate
                                objKey:(NSString*)objKey
                                  item:(MHItem *)item
                             objStatus:(NSString*)objStatus;

+ (NSArray*)allMediaInItem:(MHItem*)item;

+ (void)removeMediaInItem:(MHItem*)item;

@end
