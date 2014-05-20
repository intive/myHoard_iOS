//
//  MHItem.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 20/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHCollection, MHMedia, MHTag;

@interface MHItem : NSManagedObject

@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objDescription;
@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) id objLocation;
@property (nonatomic, retain) NSDate * objModifiedDate;
@property (nonatomic, retain) NSString * objName;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSString * objStatus;
@property (nonatomic, retain) MHCollection *collection;
@property (nonatomic, retain) NSSet *media;
@property (nonatomic, retain) NSSet *tags;
@end

@interface MHItem (CoreDataGeneratedAccessors)

- (void)addMediaObject:(MHMedia *)value;
- (void)removeMediaObject:(MHMedia *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

- (void)addTagsObject:(MHTag *)value;
- (void)removeTagsObject:(MHTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
