//
//  MHCoreDataContextForTests.m
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCoreDataContextForTests.h"

@interface MHCoreDataContextForTests ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinatorForTest;
@property (strong, nonatomic) NSPersistentStore *persistentStoreForTest;

@end

@implementation MHCoreDataContextForTests

+ (MHCoreDataContextForTests *)getInstance
{
	static MHCoreDataContextForTests *cdcInstance;

	@synchronized(self)
	{
		if (!cdcInstance)
		{
			cdcInstance = [[MHCoreDataContextForTests alloc] init];
		}
		return cdcInstance;
	}
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinatorForTest != nil)
        return _persistentStoreCoordinatorForTest;

    NSError *error = nil;
    _persistentStoreCoordinatorForTest = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    _persistentStoreForTest = [self.persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:options error:&error];
    if (!_persistentStoreForTest) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinatorForTest;
}

- (void)dropTestPersistentStore
{
    NSError *error = nil;
    [_persistentStoreCoordinatorForTest removePersistentStore:_persistentStoreForTest error:&error];
    if (error)
        NSLog(@"Failed to drop test persistent store, error:%@", error);

    _persistentStoreCoordinatorForTest = nil;
}

@end
