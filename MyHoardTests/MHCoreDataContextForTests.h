//
//  MHCoreDataContextForTests.h
//  MyHoard
//
//  Created by Karol Kogut on 14.02.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCoreDataContext.h"

@interface MHCoreDataContextForTests : MHCoreDataContext

+ (MHCoreDataContextForTests *)getInstance;

- (void)dropTestPersistentStore;

@end
