//
//  MHItem.h
//  MyHoard
//
//  Created by user on 2/23/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHCollection, MHMedia;

@interface MHItem : NSManagedObject

@property (nonatomic, retain) NSString * objCollectionId;
@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objDescription;
@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSDictionary * objLocation;
@property (nonatomic, retain) NSArray * objMediaIds;
@property (nonatomic, retain) NSDate * objModifiedDate;
@property (nonatomic, retain) NSString * objName;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSNumber * objQuantity;
@property (nonatomic, retain) NSArray * objTags;
@property (nonatomic, retain) MHCollection *item;
@property (nonatomic, retain) MHMedia *itemMedia;

@end
