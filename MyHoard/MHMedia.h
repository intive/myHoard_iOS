//
//  MHMedia.h
//  MyHoard
//
//  Created by user on 2/23/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHItem;

@interface MHMedia : NSManagedObject

@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSString * objItem;
@property (nonatomic, retain) NSString * objLocalPath;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) MHItem *media;

@end
