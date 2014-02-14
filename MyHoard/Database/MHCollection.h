//
//  MHCollection.h
//  MyHoard
//
//  Created by Karol Kogut on 13.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MHCollection : NSManagedObject

@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSString * objName;
@property (nonatomic, retain) NSString * objDescription;
@property (nonatomic, retain) NSArray * objTags;
@property (nonatomic, retain) NSNumber * objItemsNumber;
@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSDate * objModifiedDate;
@property (nonatomic, retain) NSString * objOwner;

@end
