//
//  MHItem.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 08/04/14.
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
@property (nonatomic, retain) id objLocation;
@property (nonatomic, retain) id objMediaIds;
@property (nonatomic, retain) NSDate * objModifiedDate;
@property (nonatomic, retain) NSString * objName;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSNumber * objQuantity;
@property (nonatomic, retain) id objTags;
@property (nonatomic, retain) MHCollection *collection;
@property (nonatomic, retain) NSSet *media;
@end

@interface MHItem (CoreDataGeneratedAccessors)

- (void)addMediaObject:(MHMedia *)value;
- (void)removeMediaObject:(MHMedia *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

@end
