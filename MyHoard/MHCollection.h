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
@property (nonatomic, retain) NSSet *collection;
@end

@interface MHCollection (CoreDataGeneratedAccessors)

- (void)addCollectionObject:(MHItem *)value;
- (void)removeCollectionObject:(MHItem *)value;
- (void)addCollection:(NSSet *)values;
- (void)removeCollection:(NSSet *)values;

@end
