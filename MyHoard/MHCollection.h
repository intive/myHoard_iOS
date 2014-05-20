//
//  MHCollection.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 20/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHItem, MHTag;

@interface MHCollection : NSManagedObject

@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objDescription;
@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSDate * objModifiedDate;
@property (nonatomic, retain) NSString * objName;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSString * objStatus;
@property (nonatomic, retain) NSString * objType;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *tags;
@end

@interface MHCollection (CoreDataGeneratedAccessors)

- (void)addItemsObject:(MHItem *)value;
- (void)removeItemsObject:(MHItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addTagsObject:(MHTag *)value;
- (void)removeTagsObject:(MHTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
