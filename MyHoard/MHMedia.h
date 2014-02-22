//
//  MHMedia.h
//  MyHoard
//
//  Created by Konrad Gnoinski on 22/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MHMedia : NSManagedObject

@property (nonatomic, retain) NSString * objId;
@property (nonatomic, retain) NSString * objItem;
@property (nonatomic, retain) NSDate * objCreatedDate;
@property (nonatomic, retain) NSString * objOwner;
@property (nonatomic, retain) NSString * objLocalPath;

@end
