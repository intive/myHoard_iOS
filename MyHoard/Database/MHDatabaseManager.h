//
//  MHDatabaseManager.h
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHCollection, MHItem, MHMedia, CLLocation;

@interface MHDatabaseManager : NSObject

#pragma mark - Collection
+ (MHCollection*)insertCollectionWithObjName:(NSString*)objName
                              objDescription:(NSString*)objDescription
                                     objTags:(NSArray*)objTags
                              objCreatedDate:(NSDate*)objCreatedDate
                             objModifiedDate:(NSDate*)objModifiedDate
                 objOwnerNilAddLogedUserCode:(NSString*) objOwner;

+ (NSArray*)allCollections;
+ (MHCollection*)collectionWithObjName:(NSString*)objName;

#pragma mark - Item
+ (MHItem*)insertItemWithObjName:(NSString*)objName
                  objDescription:(NSString*)objDescription
                         objTags:(NSArray*)objTags
                     objLocation:(CLLocation*)objLocation
                  objCreatedDate:(NSDate*)objCreatedDate
                 objModifiedDate:(NSDate*)objModifiedDate
                      collection:(MHCollection *)collection;

+ (MHItem*) itemWithObjName:(NSString*)objName inCollection:(MHCollection *)collection;
+ (NSArray*) allItemsWithObjName: (NSString*)objName inCollection:(MHCollection*)collection;

#pragma mark - Media
+ (MHMedia*)insertMediaWithCreatedDate:(NSDate*)objCreatedDate
                          objLocalPath:(NSString*)objLocalPath
                                  item:(MHItem *)item;

@end
