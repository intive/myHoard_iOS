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
                    NSArray *coreDataCollections = [self ruleOutOfflineCollections];
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
            [self createCollectionFromServerResponse:responseDictionary];
        }
    }else if ([coreDataCollections count] > 0 && [responseObject count] > 0){
        
        NSArray *objStatusNew = [self predicateArray:coreDataCollections byObjectStatus:objectStatusNew];
        
        for (MHCollection *collectionWithNewStatus in objStatusNew) {
            NSArray *collectionsByType = [self predicateArray:objStatusNew byObjectType:collectionTypeOffline];
            
            if (!collectionsByType.count) {
                [[MHAPI getInstance] createCollection:collectionWithNewStatus completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }
        }
        
        NSArray *objStatusModified = [self predicateArray:coreDataCollections byObjectStatus:objectStatusModified];
        
        for (MHCollection *collectionWithModifiedStatus in objStatusModified) {
            NSArray *collectionsById = [self predicateArray:responseObject byServerId:collectionWithModifiedStatus.objId];
            
            if (!collectionsById.count) {
                collectionWithModifiedStatus.objStatus = objectStatusNew;
                [[MHAPI getInstance] createCollection:collectionWithModifiedStatus completionBlock:^(id object, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }
        }
        
        NSArray *objStatusOk = [self predicateArray:coreDataCollections byObjectStatus:objectStatusOk];
        
        for (MHCollection *collectionWithOkStatus in objStatusOk) {
            NSArray *collectionsById = [self predicateArray:responseObject byServerId:collectionWithOkStatus.objId];
            
            if (!collectionsById.count) {
                [[MHCoreDataContext getInstance].managedObjectContext deleteObject:collectionWithOkStatus];
                [[MHCoreDataContext getInstance]saveContext];
            }
        }
        
        for (NSDictionary *responseDictionary in responseObject) {
            predicationResult = [self predicateArray:coreDataCollections byObjectId:responseDictionary[@"id"]];
            
            if ([predicationResult count] == 0) {
                [self createCollectionFromServerResponse:responseDictionary];
            }else {
                
                NSArray *objStatusDeleted = [self predicateArray:predicationResult byObjectStatus:objectStatusDeleted];
                
                if (objStatusDeleted.count) {
                    NSArray *collectionsPredicatedWithModifiedDate = [self predicateArray:objStatusDeleted bySmallerModifiedDate:[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    
                    for (MHCollection *outdatedCollection in collectionsPredicatedWithModifiedDate) {
                        
                        [[MHAPI getInstance] readUserCollection:outdatedCollection completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }
                        }];
                    }
                    
                    collectionsPredicatedWithModifiedDate = [self predicateArray:objStatusDeleted byLargerModifiedDate:[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    
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
                    
                    NSArray *collectionsPredicatedWithModifiedDate = [self predicateArray:predicationResult bySmallerModifiedDate:[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    
                    for (MHCollection *outdatedCollection in collectionsPredicatedWithModifiedDate) {
                        
                        [[MHAPI getInstance] readUserCollection:outdatedCollection completionBlock:^(id object, NSError *error) {
                            if (error) {
                                completionBlock(NO, error);
                            }
                        }];
                    }
                    
                    collectionsPredicatedWithModifiedDate = [self predicateArray:predicationResult byLargerModifiedDate:[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                    
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
            [self createItemAndMediaFromServerResponse:responseDictionary forCollection:collection withCompletionBlock:^(BOOL didFinishSync, NSError *error) {
                if (error) {
                    completionBlock(NO, error);
                }
            }];
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
        
        NSArray *objStatusNew = [self predicateArray:coreDataItems byObjectStatus:objectStatusNew];
        
        for (MHItem *itemWithNewStatus in objStatusNew) {
            NSArray *itemsById = [self predicateArray:responseObject byServerId:itemWithNewStatus.objId];
            
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
        
        NSArray *objStatusModified = [self predicateArray:coreDataItems byObjectStatus:objectStatusModified];
        
        for (MHItem *itemWithModifiedStatus in objStatusModified) {
            NSArray *itemsById = [self predicateArray:responseObject byServerId:itemWithModifiedStatus.objId];
            
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
        
        NSArray *objStatusOk = [self predicateArray:coreDataItems byObjectStatus:objectStatusOk];
        
        for (MHItem *itemsWithOkStatus in objStatusOk) {
            NSArray *itemsById = [self predicateArray:responseObject byServerId:itemsWithOkStatus.objId];
            
            if (!itemsById.count) {
                [itemsWithOkStatus removeMedia:itemsWithOkStatus.media];
                [collection removeItemsObject:itemsWithOkStatus];
            }
        }
        
        for (NSDictionary *responseDictionary in responseObject) {
            
            predicationResult = [self predicateArray:coreDataItems byObjectId:responseDictionary[@"id"]];
            
            if ([predicationResult count] == 0) {
                [self createItemAndMediaFromServerResponse:responseDictionary forCollection:collection withCompletionBlock:^(BOOL didFinishSync, NSError *error) {
                    if (error) {
                        completionBlock(NO, error);
                    }
                }];
            }else {
                
                NSArray *objStatusDeleted = [self predicateArray:predicationResult byObjectStatus:objectStatusDeleted];
                
                if (objStatusDeleted.count) {
                    NSArray *itemsPredicatedWithModifiedDate = [self predicateArray:objStatusDeleted bySmallerModifiedDate:[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    
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
                    
                    itemsPredicatedWithModifiedDate = [self predicateArray:objStatusDeleted byLargerModifiedDate:[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    
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
                    NSArray *itemsPredicatedWithModifiedDate = [self predicateArray:predicationResult bySmallerModifiedDate:[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    
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
                    
                    itemsPredicatedWithModifiedDate = [self predicateArray:predicationResult byLargerModifiedDate:[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                    
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

- (void)createCollectionFromServerResponse:(NSDictionary *)responseDictionary {
    
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

#pragma mark - utility methods

- (void)createItemAndMediaFromServerResponse:(NSDictionary *)responseDictionary forCollection:(MHCollection *)collection withCompletionBlock:(MHCoreDataSyncCompletionBlock)completionBlock {
    
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


- (NSArray *)ruleOutOfflineCollections {
    
    NSMutableArray *allCollections = [NSMutableArray arrayWithArray:[MHDatabaseManager allCollections]];
    
    [allCollections enumerateObjectsUsingBlock:^(MHCollection *collection, NSUInteger idx, BOOL *stop) {
        if ([collection.objType isEqualToString:collectionTypeOffline]) {
            [allCollections removeObjectAtIndex:idx];
        }
    }];
    
    return allCollections;
}

#pragma mark - predication helpers

- (NSArray *)predicateArray:(NSArray *)arrayToPredicate byObjectId:(NSString *)objectId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objId == %@", objectId];
    NSArray *predicationResultArray = [arrayToPredicate filteredArrayUsingPredicate:predicate];
    
    return predicationResultArray;
}

- (NSArray *)predicateArray:(NSArray *)arrayToPredicate byServerId:(NSString *)objectId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", objectId];
    NSArray *predicationResultArray = [arrayToPredicate filteredArrayUsingPredicate:predicate];
    
    return predicationResultArray;
}

- (NSArray *)predicateArray:(NSArray *)arrayToPredicate byObjectStatus:(NSString *)objectStatus {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatus];
    NSArray *predicationResultArray = [arrayToPredicate filteredArrayUsingPredicate:predicate];
    
    return predicationResultArray;
}

- (NSArray *)predicateArray:(NSArray *)arrayToPredicate byObjectType:(NSString *)objectType {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objType == %@", objectType];
    NSArray *predicationResultArray = [arrayToPredicate filteredArrayUsingPredicate:predicate];
    
    return predicationResultArray;
}

- (NSArray *)predicateArray:(NSArray *)arrayToPredicate bySmallerModifiedDate:(NSDate *)modifiedDate {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@", modifiedDate];
    NSArray *predicationResultArray = [arrayToPredicate filteredArrayUsingPredicate:predicate];
    
    return predicationResultArray;
}

- (NSArray *)predicateArray:(NSArray *)arrayToPredicate byLargerModifiedDate:(NSDate *)modifiedDate {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", modifiedDate];
    NSArray *predicationResultArray = [arrayToPredicate filteredArrayUsingPredicate:predicate];
    
    return predicationResultArray;
}
@end
