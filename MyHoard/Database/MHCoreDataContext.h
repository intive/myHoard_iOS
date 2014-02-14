//
//  MHCoreDataContext.h
//  MyHoard
//
//  Created by Karol Kogut on 13.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MHCollection;

@interface MHCoreDataContext : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


+ (MHCoreDataContext *)getInstance;
- (void)saveContext;

@end
