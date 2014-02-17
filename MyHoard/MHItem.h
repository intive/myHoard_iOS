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

@property (nonatomic, strong) NSString *objId;
@property (nonatomic, strong) NSString *objName;
@property (nonatomic, strong) NSString *objDescription;
@property (nonatomic, strong) NSArray *objTags;
@property (nonatomic, strong) NSDictionary *objLoctaion;
@property (nonatomic, strong) NSNumber *objQuantity;
@property (nonatomic, strong) NSArray *objMediaIds;
@property (nonatomic, strong) NSDate *objCreatedDate;
@property (nonatomic, strong) NSDate *objModifiedDate;
@property (nonatomic, strong) NSString *objCollectionId;
@property (nonatomic, strong) NSString *objOwner;

@end
