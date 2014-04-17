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
                                    objOwner:(NSString*)objOwner;

+ (MHCollection*)collectionWithObjName:(NSString*)objName;
+ (NSArray*)allCollections;

#pragma mark - Item
+ (MHItem*)insertItemWithObjName:(NSString*)objName
                  objDescription:(NSString*)objDescription
                         objTags:(NSArray*)objTags
                     objLocation:(CLLocation*)objLocation
                  objCreatedDate:(NSDate*)objCreatedDate
                 objModifiedDate:(NSDate*)objModifiedDate
                        objOwner:(NSString*)objOwner
                      collection:(MHCollection *)collection;

+ (MHItem*)itemWithObjName:(NSString*)objName;
+ (NSArray*) allItemsWithObjName: (NSString*)objName inCollection:(MHCollection*)collection;

#pragma mark - Media
+ (MHMedia*)insertMediaWithCreatedDate:(NSDate*)objCreatedDate
                              objOwner:(NSString*)objOwner
                          objLocalPath:(NSString*)objLocalPath
                                  item:(MHItem *)item;

@end
