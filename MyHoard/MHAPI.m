//
//  MHAPI.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <CoreLocation/CLLocation.h>

#import "MHAPI.h"
#import "MHUserSettings.h"
#import "MHItem+UtilityMethods.h"
#import "MHMedia.h"
#import "MHDatabaseManager.h"
#import "MHCoreDataContext.h"
#import "NSString+RFC3339.h"
#import "MHImageCache.h"

static MHAPI *_sharedAPI = nil;

@interface MHAPI() {
    
    NSString* _accessToken;
    NSString* _refreshToken;
}

@end

@implementation MHAPI

+ (instancetype)getInstance
{
    return _sharedAPI;
}

+ (void)setSharedAPIInstance:(MHAPI *)api
{
    @synchronized (self) {
        _sharedAPI = api;
    }
}

- (NSString *)serverUrl {
    NSString *ret = @"";
    switch([MHUserSettings serverType]) {
        case MHServerTypePython:
            ret = @"http://78.133.154.18:8081";
            break;
        case MHServerTypeJava1:
            ret = @"http://78.133.154.39:1080";
            break;
        case MHServerTypeJava2:
            ret = @"http://78.133.154.39:2080";
            break;
    }
    return ret;
}

- (NSString *)urlWithPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@/%@/", [self serverUrl], path];
}

#pragma User + Authorization & Authentication

- (void)logout:(MHAPICompletionBlock)completionBlock {
    _accessToken = nil;
    _refreshToken = nil;
    _userId = nil;
    completionBlock(nil, nil);
}

- (BOOL)activeSession {
    
    if (_accessToken && _refreshToken) {
        return YES;
    }else {
        return NO;
    }
    
}

- (AFHTTPRequestOperation *)createUser:(NSString *)email
                          withPassword:(NSString *)password
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer* s = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [s requestWithMethod:@"POST"
                                              URLString:[self urlWithPath:@"users"]
                                             parameters:@{@"email": email,
                                                          @"password": password}
                                                  error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma read existing user

- (AFHTTPRequestOperation *)readUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"GET" URLString:[NSString stringWithFormat:@"%@%@/", [self urlWithPath:@"users"],_userId] parameters:nil error:&error];
    
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          MHUserProfile *userProfile = [[MHUserProfile alloc]init];
                                                                          
                                                                          userProfile.username = [responseObject valueForKeyPath:@"username"];
                                                                          userProfile.email = [responseObject valueForKeyPath:@"email"];
                                                                          
                                                                          completionBlock(userProfile, nil);                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              completionBlock(nil, error);
                                                                          }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - update user

- (AFHTTPRequestOperation *)updateUser:(NSString *)username
                          withPassword:(NSString *)password
                              andEmail:(NSString *)email
                       completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@/", [self urlWithPath:@"users"],_userId]
                                                       parameters:@{@"username": username,
                                                                    @"password": password,
                                                                    @"email": email}
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(responseObject, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - delete user

- (AFHTTPRequestOperation *)deleteUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@/", [self urlWithPath:@"users"],_userId]
                                                       parameters:nil
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark - refresh token

- (AFHTTPRequestOperation *)refreshTokenForUser:(NSString *)email
                                   withPassword:(NSString *)password
                                completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"POST"
                                                        URLString:[self urlWithPath:@"oauth/token"]
                                                       parameters:@{@"email": email,
                                                                    @"password": password,
                                                                    @"grant_type": @"refresh_token",
                                                                    @"refresh_token": _refreshToken}
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          _accessToken = responseObject[@"access_token"];
                                                                          _refreshToken = responseObject[@"refresh_token"];
                                                                          _userId = responseObject[@"user_id"];
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark get token/login

- (AFHTTPRequestOperation *)accessTokenForUser:(NSString *)email
                                  withPassword:(NSString *)password
                               completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"POST"
                                                        URLString:[self urlWithPath:@"oauth/token"]
                                                       parameters:@{@"email": email,
                                                                    @"password": password,
                                                                    @"grant_type": @"password"}
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          _accessToken = [responseObject valueForKeyPath:@"access_token"];
                                                                          _refreshToken = [responseObject valueForKeyPath:@"refresh_token"];
                                                                          _userId = [responseObject valueForKeyPath:@"user_id"];
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark Collections/create collection

- (AFHTTPRequestOperation *)createCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSNumber *objType;
    
    if ([collection.objType isEqualToString:@"public"]) {
        objType = @YES;
    }else {
        objType = @NO;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": collection.objName,
                                                                                  @"tags":collection.objTags,
                                                                                  @"public":objType}];
    if (collection.objDescription) {
        params[@"description"] = collection.objDescription;
    }
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:params
                                                               error:&error];
    
    __block MHCollection* c = collection;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          NSString* date = responseObject[@"created_date"];
                                                                          c.objCreatedDate = [date dateFromRFC3339String];
                                                                          date = responseObject[@"modified_date"];
                                                                          c.objModifiedDate = [date dateFromRFC3339String];
                                                                          c.objOwner = responseObject[@"owner"];
                                                                          c.objId = responseObject[@"id"];
                                                                          [c typeFromBoolValue:responseObject[@"public"]];
                                                                          c.objStatus = objectStatusOk;
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          
                                                                          completionBlock(c, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read all of user collections

- (AFHTTPRequestOperation *)readUserCollectionsWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:nil
                                                               error:&error];
    
    __block NSArray *coreDataCollections = [MHDatabaseManager allCollections];
    __block NSPredicate *predicate;
    __block NSArray *predicationResult;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                                                                      [self createCollection:collectionWithNewStatus completionBlock:^(id object, NSError *error) {
                                                                                          if (error) {
                                                                                              completionBlock(nil, error);
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
                                                                                      [self createCollection:collectionWithModifiedStatus completionBlock:^(id object, NSError *error) {
                                                                                          if (error) {
                                                                                              completionBlock(nil, error);
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
                                                                                              
                                                                                              [self readUserCollection:outdatedCollection completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                          
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@",[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                          collectionsPredicatedWithModifiedDate = [objStatusDeleted filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          for (MHCollection *upToDateCollection in collectionsPredicatedWithModifiedDate) {
                                                                                              
                                                                                              [self deleteCollection:upToDateCollection completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
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
                                                                                              
                                                                                              [self readUserCollection:outdatedCollection completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                          
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", [MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                          collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          for (MHCollection *upToDateCollection in collectionsPredicatedWithModifiedDate) {
                                                                                              [self updateCollection:upToDateCollection completionBlock:^(id object, NSError *error)   {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                      }
                                                                                      
                                                                                      predicate = [NSPredicate predicateWithFormat:@"(objStatus == %@) AND (objModifiedDate == %@)", objectStatusModified, responseDictionary[@"modified_date"]];
                                                                                      NSArray *objStatusModified = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                      
                                                                                      if (objStatusModified.count) {
                                                                                          for (MHCollection *collectionToSend in objStatusModified) {
                                                                                              [self updateCollection:collectionToSend completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                      }
                                                                                  }
                                                                              }
                                                                          }else if ([coreDataCollections count] > 0 && [responseObject count] == 0) {
                                                                              for (MHCollection *eachCollection in coreDataCollections) {
                                                                                  if (eachCollection.objStatus != collectionTypeOffline) {
                                                                                      [self createCollection:eachCollection completionBlock:^(id object, NSError *error) {
                                                                                          if (error) {
                                                                                              completionBlock(nil, error);
                                                                                          }
                                                                                      }];
                                                                                  }
                                                                              }
                                                                          }
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read specified user collection

- (AFHTTPRequestOperation *)readUserCollection:(MHCollection *)collection
                               completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block MHCollection* c = collection;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          c = [MHDatabaseManager insertCollectionWithObjName:responseObject[@"name"] objDescription:responseObject[@"description"] objTags:responseObject[@"tags"] objCreatedDate:[MHCollection createdDateFromString:responseObject[@"created_date"]] objModifiedDate:nil objOwnerNilAddLogedUserCode:responseObject[@"owner"] objStatus:objectStatusOk objType:nil];
                                                                          c.objId = responseObject[@"id"];
                                                                          [c typeFromBoolValue:responseObject[@"public"]];
                                                                          [c modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          [[MHCoreDataContext getInstance]saveContext];
                                                                          
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update collection

- (AFHTTPRequestOperation *)updateCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSNumber *objType;
    
    if ([collection.objType isEqualToString:@"public"]) {
        objType = @YES;
    }else {
        objType = @NO;
    }
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
                                                       parameters:@{@"name": collection.objName,
                                                                    @"description": collection.objDescription,
                                                                    @"tags":collection.objTags,
                                                                    @"public":objType}
                                                            error:&error];
    __block MHCollection *c = collection;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          c.objStatus = objectStatusOk;
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark delete collection

- (AFHTTPRequestOperation *)deleteCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"collections"],collection.objId]
                                                       parameters:nil
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark Media/create media

- (AFHTTPRequestOperation *)createMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    __block MHMedia* m = media;
    
    NSData* assetData = [[MHImageCache sharedInstance]dataForKey:media.objKey];
    
    [manager POST:[self urlWithPath:@"media"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:m.objKey mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m.objId = responseObject[@"id"];
        m.objStatus = objectStatusOk;
        completionBlock(nil, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;
}

#pragma mark read media

- (AFHTTPRequestOperation *)readMedia:(MHMedia *)media
                      completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block MHMedia *tmpMedia = media;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          [[MHImageCache sharedInstance] cacheImage:responseObject forKey:media.objId];
                                                                          tmpMedia.objKey = media.objId;
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update media

- (AFHTTPRequestOperation *)updateMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    __block MHMedia *tmpMedia = media;
    
    NSData* assetData = [[MHImageCache sharedInstance] dataForKey:media.objKey];
    [manager POST:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:media.objKey mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tmpMedia.objStatus = objectStatusOk;
        completionBlock(nil, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;
}

#pragma mark delete media

- (AFHTTPRequestOperation *)deleteMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"DELETE"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(media, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read thumbnail

- (AFHTTPRequestOperation *)readThumbnail:(MHThumbnailSize)size
                                 forMedia:(MHMedia *)media
                          completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSString *thumbnailSize = @"";
    
    switch (size) {
        case MHThumbnailx160:
            thumbnailSize = @"160";
            break;
        case MHThumbnailx300:
            thumbnailSize = @"300";
            break;
        case MHThumbnailx340:
            thumbnailSize = @"340";
            break;
        case MHThumbnailx500:
            thumbnailSize = @"500";
            break;
    }
    
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/?size=%@",[self urlWithPath:@"media"],media.objId,thumbnailSize]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(responseObject, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark Item/create item

- (AFHTTPRequestOperation *)createItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray* mediaIds = [[NSMutableArray alloc] init];
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    
    if ([item.media count] > 0) {
        for (MHMedia* media in item.media) {
            if (!media.objId) {
                params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                         @"description": item.objDescription,
                                                                         @"collection": item.collection.objId}];
                
            }else {
                [mediaIds addObject:media.objId];
            }
        }
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                 @"description": item.objDescription,
                                                                 @"media": mediaIds,
                                                                 @"collection": item.collection.objId}];
    }else {
        
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                 @"description": item.objDescription,
                                                                 @"collection": item.collection.objId}];
    }
    
    CLLocation *l = item.objLocation;
    if (l) {
        params[@"location"] = @{@"lat": @(l.coordinate.latitude),
                                @"lng": @(l.coordinate.longitude)};
    }
    
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"items"]
                                                          parameters:params
                                                               error:&error];
    
    __block MHItem* i = item;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          i.objId = responseObject[@"id"];
                                                                          i.objName = responseObject[@"name"];
                                                                          i.objDescription = responseObject[@"description"];
                                                                          [i locationParser:responseObject[@"location"]];
                                                                          i.objCreatedDate = [MHItem createdDateFromString:responseObject[@"created_date"]];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          [i modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          i.objStatus = objectStatusOk;
                                                                          
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(i, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read single item

- (AFHTTPRequestOperation *)readItem:(MHItem *)item
                     completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"items"],item.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block MHItem* i = item;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          i.objId = responseObject[@"id"];
                                                                          i.objName = responseObject[@"name"];
                                                                          i.objDescription = responseObject[@"description"];
                                                                          i.objCreatedDate = [MHItem createdDateFromString:responseObject[@"created_date"]];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          [i locationParser:responseObject[@"location"]];
                                                                          [i modifiedDateFromString:responseObject[@"modified_date"]];
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          completionBlock(i, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark read items of a collection

- (AFHTTPRequestOperation *)readAllItemsOfCollection:(MHCollection *)collection
                                     completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@/items/",[self urlWithPath:@"collections"],collection.objId]
                                                          parameters:nil
                                                               error:&error];
    
    __block NSArray *coreDataItems = [collection.items allObjects];
    __block NSPredicate *predicate;
    __block NSArray *predicationResult;
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          if ([coreDataItems count] == 0 && [responseObject count] != 0) {
                                                                              for (NSDictionary *responseDictionary in responseObject) {
                                                                                  
                                                                                  MHItem *i = [MHDatabaseManager insertItemWithObjName:responseDictionary[@"name"] objDescription:responseDictionary[@"description"] objTags:nil objLocation:nil objCreatedDate:[MHItem createdDateFromString:responseDictionary[@"created_date"]] objModifiedDate:nil collection:collection objStatus:objectStatusOk];
                                                                                  i.objId = responseDictionary[@"id"];
                                                                                  [i modifiedDateFromString:responseDictionary[@"modified_date"]];
                                                                                  [i locationParser:responseDictionary[@"location"]];
                                                                                  
                                                                                  for (NSDictionary *d in responseDictionary[@"media"]) {
                                                                                      MHMedia *m = [MHDatabaseManager insertMediaWithCreatedDate:[NSDate date] objKey:d[@"id"] item:i objStatus:objectStatusOk];
                                                                                      m.objId = d[@"id"];
                                                                                      [self readMedia:m completionBlock:^(id object, NSError *error) {
                                                                                          if (error) {
                                                                                              completionBlock(nil, error);
                                                                                          }
                                                                                      }];
                                                                                  }
                                                                                  
                                                                                  [[MHCoreDataContext getInstance] saveContext];
                                                                              }
                                                                          }else if ([coreDataItems count] != 0 && [responseObject count] != 0){
                                                                              
                                                                              for (MHItem *eachItem in coreDataItems) {
                                                                                  for (MHMedia *eachMedia in eachItem.media) {
                                                                                      if (eachMedia.objStatus == objectStatusDeleted) {
                                                                                          [self deleteMedia:eachMedia completionBlock:^(id object, NSError *error) {
                                                                                              if (error) {
                                                                                                  completionBlock(nil, error);
                                                                                              }else {
                                                                                                  [eachItem removeMediaObject:object];
                                                                                              }
                                                                                          }];
                                                                                      }
                                                                                      
                                                                                      if (eachMedia.objStatus == objectStatusNew || eachMedia.objStatus == objectStatusModified) {
                                                                                          [self createMedia:eachMedia completionBlock:^(id object, NSError *error) {
                                                                                              if (error) {
                                                                                                  completionBlock(nil, error);
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
                                                                                      [self createItem:itemWithNewStatus completionBlock:^(id object, NSError *error) {
                                                                                          if (error) {
                                                                                              completionBlock(nil, error);
                                                                                          }else {
                                                                                              for (MHMedia *media in itemWithNewStatus.media) {
                                                                                                  [self createMedia:media completionBlock:^(id object, NSError *error) {
                                                                                                      if (error) {
                                                                                                          completionBlock(nil, error);
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
                                                                                      [self createItem:itemWithModifiedStatus completionBlock:^(id object, NSError *error) {
                                                                                          if (error) {
                                                                                              completionBlock(nil, error);
                                                                                          }else {
                                                                                              for (MHMedia *media in itemWithModifiedStatus.media) {
                                                                                                  [self createMedia:media completionBlock:^(id object, NSError *error) {
                                                                                                      if (error) {
                                                                                                          completionBlock(nil, error);
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
                                                                                          [self readMedia:m completionBlock:^(id object, NSError *error) {
                                                                                              if (error) {
                                                                                                  completionBlock(nil, error);
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
                                                                                              [self readItem:outdatedItem completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }else {
                                                                                                      for (MHMedia *outdatedMedia in outdatedItem.media) {
                                                                                                          [self readMedia:outdatedMedia completionBlock:^(id object, NSError *error) {
                                                                                                              if (error) {
                                                                                                                  completionBlock(nil, error);
                                                                                                              }
                                                                                                          }];
                                                                                                      }
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                          
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@",[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                          itemsPredicatedWithModifiedDate = [objStatusDeleted filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          for (MHItem *upToDateItem in itemsPredicatedWithModifiedDate) {
                                                                                              [self deleteItemWithId:upToDateItem completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
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
                                                                                              [self readItem:outdatedItem completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }else {
                                                                                                      for (MHMedia *media in outdatedItem.media) {
                                                                                                          [self readMedia:media completionBlock:^(id object, NSError *error) {
                                                                                                              if (error) {
                                                                                                                  completionBlock(nil, error);
                                                                                                              }
                                                                                                          }];
                                                                                                      }
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                          
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", [MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                          itemsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          for (MHItem *upToDateItem in itemsPredicatedWithModifiedDate) {
                                                                                              [self updateItem:upToDateItem completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }else {
                                                                                                      for (MHMedia *mediaToUpdate in upToDateItem.media) {
                                                                                                          if (mediaToUpdate.objStatus == objectStatusModified) {
                                                                                                              [self updateMedia:mediaToUpdate completionBlock:^(id object, NSError *error) {
                                                                                                                  if (error) {
                                                                                                                      completionBlock(nil, error);
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
                                                                                              [self updateItem:itemToSend completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil,error);
                                                                                                  }else {
                                                                                                      for (MHMedia *mediaToSend in itemToSend.media) {
                                                                                                          if (mediaToSend.objStatus == objectStatusModified) {
                                                                                                              [self updateMedia:mediaToSend completionBlock:^(id object, NSError *error) {
                                                                                                                  if (error) {
                                                                                                                      completionBlock(nil, error);
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
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark update item

- (AFHTTPRequestOperation *)updateItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray* mediaIds = [[NSMutableArray alloc] init];
    for (MHMedia* media in item.media) {
        [mediaIds addObject:media.objId];
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:@{@"name": item.objName,
                                                                                  @"description": item.objDescription,
                                                                                  @"media": mediaIds,
                                                                                  @"collection": item.collection.objId}];
    
    CLLocation *l = item.objLocation;
    if (l) {
        params[@"location"] = @{@"lat": @(l.coordinate.latitude),
                                @"lng": @(l.coordinate.longitude)};
    }
    
    __block MHItem* i = item;
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"PUT"
                                                           URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"items"],item.objId]
                                                          parameters:params
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          i.objStatus = objectStatusOk;
                                                                          completionBlock(nil, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark delete item

- (AFHTTPRequestOperation *)deleteItemWithId:(MHItem *)item
                             completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"items"],item.objId]
                                                       parameters:nil
                                                            error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          [self localizedDescriptionForErrorCode:error];
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (void)localizedDescriptionForErrorCode:(NSError *)error {
    
    NSString *domain = @"com.blstream.MyHoard";
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    switch ([error code]) {
        case 401:
            [userInfo setValue:@"Bad credentials" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:401 userInfo:userInfo];
            break;
        case 403:
            [userInfo setValue:@"Forbidden" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:403 userInfo:userInfo];
            break;
        case 400:
            [userInfo setValue:@"Validation error" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:400 userInfo:userInfo];
            break;
        case 404:
            [userInfo setValue:@"Resource not found" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:404 userInfo:userInfo];
            break;
        case 500:
            [userInfo setValue:@"Internal server error" forKey:NSLocalizedDescriptionKey];
            error = [[NSError alloc]initWithDomain:domain code:500 userInfo:userInfo];
            break;
    }
}

@end
