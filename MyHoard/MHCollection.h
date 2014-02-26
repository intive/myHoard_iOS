//
//  MHCollection.h
//  MyHoard
//
//  Created by user on 2/26/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHItem;

@interface MHCollection : NSManagedObject

@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objDescription;
@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSNumber * objItemsNumber;
@property (nonatomic, retain) NSDate * objModifiedDate;
@property (nonatomic, retain) NSString * objName;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSArray * objTags;
@property (nonatomic, retain) NSSet *items;
@end

@interface MHCollection (CoreDataGeneratedAccessors)

- (void)addItemsObject:(MHItem *)value;
- (void)removeItemsObject:(MHItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
