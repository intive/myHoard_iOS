//
//  MHCollectionItem.h
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MHItem : NSManagedObject

@property (nonatomic, retain) NSString *objId;
@property (nonatomic, retain) NSString *objName;
@property (nonatomic, retain) NSString *objDescription;
@property (nonatomic, retain) NSArray *objTags;
@property (nonatomic, retain) NSDictionary *objLoctaion;
@property (nonatomic, retain) NSNumber *objQuantity;
@property (nonatomic, retain) NSArray *objMediaIds;
@property (nonatomic, retain) NSDate *objCreatedDate;
@property (nonatomic, retain) NSDate *objModifiedDate;
@property (nonatomic, retain) NSString *objCollectionId;
@property (nonatomic, retain) NSString *objOwner;

@end
