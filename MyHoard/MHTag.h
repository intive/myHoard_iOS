//
//  MHTag.h
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 20/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHCollection, MHItem;

@interface MHTag : NSManagedObject

@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) MHCollection *collection;
@property (nonatomic, retain) MHItem *item;

@end
