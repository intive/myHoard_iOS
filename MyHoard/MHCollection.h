//
//  MHCollection.h
//  MyHoard
//
//  Created by user on 2/23/14.
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
@property (nonatomic, retain) NSSet *item;
@end

@interface MHCollection (CoreDataGeneratedAccessors)

- (void)addItemObject:(MHItem *)value;
- (void)removeItemObject:(MHItem *)value;
- (void)addItem:(NSSet *)values;
- (void)removeItem:(NSSet *)values;

@end
