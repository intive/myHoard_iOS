//
//  MHSynchronizer.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 25/04/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSynchronizer.h"
#import "MHDatabaseManager.h"
#import "MHCoreDataContext.h"
#import "MHItem+UtilityMethods.h"
#import "MHCollection+MHAPIUtilities.h"

@interface MHSynchronizer()
{
    MHAPI* _api;
    NSInteger _oldMaxConcurrentOperationCount;
}

@property (nonatomic, copy) MHSynchronizeCompletionBlock completionBlock;

@end

@implementation MHSynchronizer

- (id)initWithAPI:(MHAPI *)api {
    self = [super init];
    if (self) {
        _api = api;
    }
    return self;
}

- (void)finish:(NSError *)error {
    if (_completionBlock) {
        _completionBlock(error);
    }
    self.completionBlock = nil;
    _api.operationQueue.maxConcurrentOperationCount = _oldMaxConcurrentOperationCount;
}

- (void)synchronize:(MHSynchronizeCompletionBlock)completionBlock {
    self.completionBlock = completionBlock;
    
    _oldMaxConcurrentOperationCount = _api.operationQueue.maxConcurrentOperationCount;
    _api.operationQueue.maxConcurrentOperationCount = 1;
    
    [_api readUserCollectionsWithCompletionBlock:^(id object, NSError *error) {
        if (error) {
            [self finish:error];
        }else {
            [self parseSynchronizationCollectionData:object withCompletionBlock:^(BOOL didFinishSync, NSError *error) {
                if (!didFinishSync) {
                    [self finish:error];
                }else {
                    NSArray *coreDataCollections = [MHDatabaseManager allCollections];
                    if (coreDataCollections.count) {
                        for (NSInteger i = 0; i < coreDataCollections.count; i++) {
                            __block MHCollection* c = coreDataCollections[i];
                            [_api readAllItemsOfCollection:c completionBlock:^(id object, NSError *error) {
                                if (error) {
                                    [self finish:error];
                                }else {
                                    [self parseSynchronizationItemsAndMediaData:object fromCollection:c withCompletionBlock:^(BOOL didFinishSync, NSError *error) {
                                        if (!didFinishSync) {
                                            [self finish:error];
                                        }else {
                                            if (i == (coreDataCollections.count - 1)) {
                                                [self finish:nil];
                                            }
                                        }
                                    }];
                                }
                            }];
                        }
                    } else {
                        [self finish:nil];
                    }
                }
            }];
        }
    }];
}

- (void)parseSynchronizationCollectionData:(id)responseObject withCompletionBlock:(MHCoreDataSyncCompletionBlock)completionBlock {
    
    NSArray *coreDataCollections = [MHDatabaseManager allCollections];
    NSPredicate *predicate;
    NSArray *predicationResult;
    
    if ([coreDataCollections count] == 0 && [responseObject count] > 0) {
        for (NSDictionary *responseDictionary in responseObject) {
            
            MHCollection *createdCollection = [MHDatabaseManager insertCollectionWithObjName:responseDictionary[@"name"]
                                                                              objDescription:responseDictionary[@"description"]
                                                                                     objTags:responseDictionary[@"tags"]
                                                                              objCreatedDate:[MHCollection createdDateFromString:responseDictionary[@"created_date"]]
                                               
                                                                             objModifiedDate:nil
                                                                 objOwnerNilAddLogedUserCode:responseDictionary[@"owner"]
                                                                                   objStatus:objectStatusOk
                                                                                     objType:nil];
            
            createdCollection.objId = responseDictionary[@"id"];
            [createdCollection typeFromBoolValue:responseDictionary[@"public"]];
            [createdCollection modifiedDateFromString:responseDictionary[@"modified_date"]];
            
            [[MHCoreDataContext getInstance] saveContext];
        }
    }else if ([coreDataCollections count] > 0 && [responseObject count] > 0){
        
        predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusNew];
        NSArray *objStatusNew = [coreDataCollections filteredArrayUsingPredicate:predicate];
        
        for (MHCollection *collectionWithNewStatus in objStatusNew) {
            predicate = [NSPredicate predicateWithFormat:@"objType == %@", collectionTypeOffline];
            NSArray *collectionsByType = [objStatusNew filteredArrayUsingPredicate:predicate];
            
            if (!collectionsByType.count) {
                [[MHAPI getInstance] createCollection:collectionWithNewStatus completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }
        }
        
        predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusModified];
        NSArray *objStatusModified = [coreDataCollections filteredArrayUsingPredicate:predicate];
        
        for (MHCollection *collectionWithModifiedStatus in objStatusModified) {
            predicate = [NSPredicate predicateWithFormat:@"id == %@", collectionWithModifiedStatus.objId];
            NSArray *collectionsById = [responseObject filteredArrayUsingPredicate:predicate];
            
            if (!collectionsById.count) {
                collectionWithModifiedStatus.objStatus = objectStatusNew;
                [[MHAPI getInstance] createCollection:collectionWithModifiedStatus completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }
        }
        
        predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusOk];
        NSArray *objStatusOk = [coreDataCollections filteredArrayUsingPredicate:predicate];
        
        for (MHCollection *collectionWithOkStatus in objStatusOk) {
            predicate = [NSPredicate predicateWithFormat:@"id == %@", collectionWithOkStatus.objId];
            NSArray *collectionsById = [responseObject filteredArrayUsingPredicate:predicate];
            
            if (!collectionsById.count) {
                [[MHCoreDataContext getInstance].managedObjectContext deleteObject:collectionWithOkStatus];
                [[MHCoreDataContext getInstance]saveContext];
            }
        }
        
        for (NSDictionary *responseDictionary in responseObject) {
            predicate = [NSPredicate predicateWithFormat:@"objId == %@", responseDictionary[@"id"]];
            predicationResult = [coreDataCollections filteredArrayUsingPredicate:predicate];
            
            if ([predicationResult count] == 0) {
                MHCollection *createdCollection = [MHDatabaseManager insertCollectionWithObjName:responseDictionary[@"name"]
                                                                                  objDescription:responseDictionary[@"description"]
                                                                                         objTags:responseDictionary[@"tags"]
                                                                                  objCreatedDate:[MHCollection createdDateFromString:responseDictionary[@"created_date"]]
                                                                                 objModifiedDate:nil
                                                                     objOwnerNilAddLogedUserCode:responseDictionary[@"owner"]
                                                                                       objStatus:objectStatusOk
                                                                                         objType:nil];
                
                createdCollection.objId = responseDictionary[@"id"];
                [createdCollection typeFromBoolValue:responseDictionary[@"public"]];
                [createdCollection modifiedDateFromString:responseDictionary[@"modified_date"]];
                
                [[MHCoreDataContext getInstance] saveContext];
            }else {
                
                predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusDeleted];
                NSArray *objStatusDeleted = [predicationResult filteredArrayUsingPredicate:predicate];
                
                if (objStatusDeleted.count) {
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@",[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    NSArray *collectionsPredicatedWithModifiedDate = [objStatusDeleted filteredArrayUsingPredicate:predicate];
                    
                    for (MHCollection *outdatedCollection in collectionsPredicatedWithModifiedDate) {
                        
                        [[MHAPI getInstance] readUserCollection:outdatedCollection completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }
                        }];
                    }
                    
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@",[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    collectionsPredicatedWithModifiedDate = [objStatusDeleted filteredArrayUsingPredicate:predicate];
                    
                    for (MHCollection *upToDateCollection in collectionsPredicatedWithModifiedDate) {
                        
                        [[MHAPI getInstance] deleteCollection:upToDateCollection completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }else {
                                [[MHCoreDataContext getInstance].managedObjectContext deleteObject:upToDateCollection];
                                [[MHCoreDataContext getInstance]saveContext];
                            }
                        }];
                    }
                }
                
                predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@) OR (objStatus == %@)", objectStatusOk, objectStatusModified];
                NSArray *objStatusOkOrModified = [predicationResult filteredArrayUsingPredicate:predicate];
                
                if (objStatusOkOrModified.count) {
                    
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@",[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    NSArray *collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                    
                    for (MHCollection *outdatedCollection in collectionsPredicatedWithModifiedDate) {
                        
                        [[MHAPI getInstance] readUserCollection:outdatedCollection completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }
                        }];
                    }
                    
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", [MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                    
                    for (MHCollection *upToDateCollection in collectionsPredicatedWithModifiedDate) {
                        [[MHAPI getInstance] updateCollection:upToDateCollection completionBlock:^(id object, NSError *error)   {
                            if (error) {
                                completionBlock(NO, error);
                            }
                        }];
                    }
                }
                
                predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@) AND (objModifiedDate == %@)", objectStatusModified, responseDictionary[@"modified_date"]];
                NSArray *objStatusModified = [predicationResult filteredArrayUsingPredicate:predicate];
                
                if (objStatusModified.count) {
                    for (MHCollection *collectionToSend in objStatusModified) {
                        [[MHAPI getInstance] updateCollection:collectionToSend completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }
                        }];
                    }
                }
            }
        }
    }else if ([coreDataCollections count] > 0 && [responseObject count] == 0) {
        for (MHCollection *eachCollection in coreDataCollections) {
            if (![eachCollection.objStatus isEqualToString:collectionTypeOffline]) {
                [[MHAPI getInstance] createCollection:eachCollection completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }
        }
    }
    [[MHCoreDataContext getInstance] saveContext];
    
    completionBlock(YES, nil);

}

- (void)parseSynchronizationItemsAndMediaData:(id)responseObject fromCollection:(MHCollection *)collection withCompletionBlock:(MHCoreDataSyncCompletionBlock)completionBlock {
    
    NSArray *coreDataItems = [collection.items allObjects];
    NSPredicate *predicate;
    NSArray *predicationResult;
    
    if ([coreDataItems count] == 0 && [responseObject count] != 0) {
        for (NSDictionary *responseDictionary in responseObject) {
            
            MHItem *i = [MHDatabaseManager insertItemWithObjName:responseDictionary[@"name"] objDescription:responseDictionary[@"description"] objTags:nil objLocation:nil objCreatedDate:[MHItem createdDateFromString:responseDictionary[@"created_date"]] objModifiedDate:nil collection:collection objStatus:objectStatusOk];
            i.objId = responseDictionary[@"id"];
            [i modifiedDateFromString:responseDictionary[@"modified_date"]];
            [i locationParser:responseDictionary[@"location"]];
            
            for (NSDictionary *d in responseDictionary[@"media"]) {
                MHMedia *m = [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:d[@"id"] item:i objStatus:objectStatusOk];
                m.objId = d[@"id"];
                [[MHAPI getInstance] readMedia:m completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }
            
            [[MHCoreDataContext getInstance] saveContext];
        }
    }else if ([coreDataItems count] != 0 && [responseObject count] != 0){
        
        for (MHItem *eachItem in coreDataItems) {
            for (MHMedia *eachMedia in eachItem.media) {
                if ([eachMedia.objStatus isEqualToString:objectStatusDeleted]) {
                    [[MHAPI getInstance] deleteMedia:eachMedia completionBlock:^(id object, NSError *error) {
                        if (error) {
                            completionBlock(NO, error);
                        }else {
                            [eachItem removeMediaObject:object];
                        }
                    }];
                }
                
                if ([eachMedia.objStatus isEqualToString:objectStatusNew] || [eachMedia.objStatus isEqualToString:objectStatusModified]) {
                    [[MHAPI getInstance] createMedia:eachMedia completionBlock:^(id object, NSError *error) {
                        if (error) {
                            completionBlock(NO, error);
                        }
                    }];
                }
            }
        }
        
        predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusNew];
        NSArray *objStatusNew = [coreDataItems filteredArrayUsingPredicate:predicate];
        
        for (MHItem *itemWithNewStatus in objStatusNew) {
            predicate = [NSPredicate predicateWithFormat:@"id == %@", itemWithNewStatus.objId];
            NSArray *itemsById = [responseObject filteredArrayUsingPredicate:predicate];
            
            if (!itemsById.count) {
                [[MHAPI getInstance] createItem:itemWithNewStatus completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }else {
                        for (MHMedia *media in itemWithNewStatus.media) {
                            [[MHAPI getInstance] createMedia:media completionBlock:^(id object, NSError *error) {
                                if (error) {
                                    completionBlock(NO, error);
                                }
                            }];
                        }
                    }
                }];
            }
        }
        
        predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@)", objectStatusModified];
        NSArray *objStatusModified = [coreDataItems filteredArrayUsingPredicate:predicate];
        
        for (MHItem *itemWithModifiedStatus in objStatusModified) {
            predicate = [NSPredicate predicateWithFormat:@"id == %@", itemWithModifiedStatus.objId];
            NSArray *itemsById = [responseObject filteredArrayUsingPredicate:predicate];
            
            if (!itemsById.count) {
                itemWithModifiedStatus.objStatus = objectStatusNew;
                [[MHAPI getInstance] createItem:itemWithModifiedStatus completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }else {
                        for (MHMedia *media in itemWithModifiedStatus.media) {
                            [[MHAPI getInstance] createMedia:media completionBlock:^(id object, NSError *error) {
                                if (error) {
                                    completionBlock(NO, error);
                                }
                            }];
                        }
                    }
                }];
            }
        }
        
        predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@)", objectStatusOk];
        NSArray *objStatusOk = [coreDataItems filteredArrayUsingPredicate:predicate];
        
        for (MHItem *itemsWithOkStatus in objStatusOk) {
            predicate = [NSPredicate predicateWithFormat:@"id == %@", itemsWithOkStatus.objId];
            NSArray *itemsById = [responseObject filteredArrayUsingPredicate:predicate];
            
            if (!itemsById.count) {
                [itemsWithOkStatus removeMedia:itemsWithOkStatus.media];
                [collection removeItemsObject:itemsWithOkStatus];
            }
        }
        
        for (NSDictionary *responseDictionary in responseObject) {
            
            predicate = [NSPredicate predicateWithFormat:@"objId == %@", responseDictionary[@"id"]];
            predicationResult = [coreDataItems filteredArrayUsingPredicate:predicate];
            
            if ([predicationResult count] == 0) {
                MHItem *i = [MHDatabaseManager insertItemWithObjName:responseDictionary[@"name"] objDescription:responseDictionary[@"description"] objTags:nil objLocation:nil objCreatedDate:[MHItem createdDateFromString:responseDictionary[@"created_date"]] objModifiedDate:nil collection:collection objStatus:objectStatusOk];
                i.objId = responseDictionary[@"id"];
                [i modifiedDateFromString:responseDictionary[@"modified_date"]];
                [i locationParser:responseDictionary[@"location"]];
                
                for (NSDictionary *d in responseDictionary[@"media"]) {
                    MHMedia *m = [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:d[@"id"] item:i objStatus:objectStatusOk];
                    m.objId = d[@"id"];
                    [[MHAPI getInstance] readMedia:m completionBlock:^(id object, NSError *error) {
                        if (error) {
                            completionBlock(NO, error);
                        }
                    }];
                }
                
                [[MHCoreDataContext getInstance] saveContext];
                
            }else {
                
                predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusDeleted];
                NSArray *objStatusDeleted = [predicationResult filteredArrayUsingPredicate:predicate];
                
                if (objStatusDeleted.count) {
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@",[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    NSArray *itemsPredicatedWithModifiedDate = [objStatusDeleted filteredArrayUsingPredicate:predicate];
                    
                    for (MHItem *outdatedItem in itemsPredicatedWithModifiedDate) {
                        [[MHAPI getInstance] readItem:outdatedItem completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }else {
                                for (MHMedia *outdatedMedia in outdatedItem.media) {
                                    [[MHAPI getInstance] readMedia:outdatedMedia completionBlock:^(id object, NSError *error) {
                                        if (error) {
                                            completionBlock(NO, error);
                                        }
                                    }];
                                }
                            }
                        }];
                    }
                    
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@",[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    itemsPredicatedWithModifiedDate = [objStatusDeleted filteredArrayUsingPredicate:predicate];
                    
                    for (MHItem *upToDateItem in itemsPredicatedWithModifiedDate) {
                        [[MHAPI getInstance] deleteItemWithId:upToDateItem completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }else {
                                [upToDateItem removeMedia:upToDateItem.media];
                                [collection removeItemsObject:upToDateItem];
                            }
                        }];
                    }
                }
                
                predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@) OR (objStatus == %@)", objectStatusOk, objectStatusModified];
                NSArray *objStatusOkOrModified = [predicationResult filteredArrayUsingPredicate:predicate];
                
                if (objStatusOkOrModified.count) {
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@",[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    NSArray *itemsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                    
                    for (MHItem *outdatedItem in itemsPredicatedWithModifiedDate) {
                        [[MHAPI getInstance] readItem:outdatedItem completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }else {
                                for (MHMedia *media in outdatedItem.media) {
                                    [[MHAPI getInstance] readMedia:media completionBlock:^(id object, NSError *error) {
                                        if (error) {
                                            completionBlock(NO, error);
                                        }
                                    }];
                                }
                            }
                        }];
                    }
                    
                    predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", [MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    itemsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                    
                    for (MHItem *upToDateItem in itemsPredicatedWithModifiedDate) {
                        [[MHAPI getInstance] updateItem:upToDateItem completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }else {
                                for (MHMedia *mediaToUpdate in upToDateItem.media) {
                                    if ([mediaToUpdate.objStatus isEqualToString:objectStatusModified]) {
                                        [[MHAPI getInstance] updateMedia:mediaToUpdate completionBlock:^(id object, NSError *error) {
                                            if (error) {
                                                completionBlock(NO, error);
                                            }
                                        }];
                                    }
                                }
                            }
                        }];
                    }
                }
                
                predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@) AND (objModifiedDate == %@)", objectStatusModified, responseDictionary[@"modified_date"]];
                NSArray *objStatusModified = [predicationResult filteredArrayUsingPredicate:predicate];
                
                if (objStatusModified.count) {
                    for (MHItem *itemToSend in objStatusModified) {
                        [[MHAPI getInstance] updateItem:itemToSend completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }else {
                                for (MHMedia *mediaToSend in itemToSend.media) {
                                    if ([mediaToSend.objStatus isEqualToString: objectStatusModified]) {
                                        [[MHAPI getInstance] updateMedia:mediaToSend completionBlock:^(id object, NSError *error) {
                                            if (error) {
                                                completionBlock(NO, error);
                                            }
                                        }];
                                    }
                                }
                            }
                        }];
                    }
                }
            }
        }
    }
    
    completionBlock(YES, nil);
}

@end
