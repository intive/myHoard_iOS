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
                                                                                                                                                         objStatus:objectStatusNew
                                                                                                                                                           objType:nil];
                                                                                  
                                                                                  createdCollection.objId = responseDictionary[@"id"];
                                                                                  [createdCollection typeFromBoolValue:responseDictionary[@"public"]];
                                                                                  [createdCollection modifiedDateFromString:responseDictionary[@"modified_date"]];
                                                                                  
                                                                                  [[MHCoreDataContext getInstance] saveContext];
                                                                              }
                                                                          }else if ([coreDataCollections count] > 0 && [responseObject count] > 0){
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
                                                                                                                                                             objStatus:objectStatusNew
                                                                                                                                                               objType:nil];
                                                                                      
                                                                                      createdCollection.objId = responseDictionary[@"id"];
                                                                                      [createdCollection typeFromBoolValue:responseDictionary[@"public"]];
                                                                                      [createdCollection modifiedDateFromString:responseDictionary[@"modified_date"]];
                                                                                      
                                                                                      [[MHCoreDataContext getInstance] saveContext];
                                                                                  }else {
                                                                                      predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@",[MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                      NSArray *collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                      
                                                                                      if ([collectionsPredicatedWithModifiedDate count] > 0) {
                                                                                          for (MHCollection *result in collectionsPredicatedWithModifiedDate) {
                                                                                              
                                                                                              [[MHCoreDataContext getInstance].managedObjectContext deleteObject:result];
                                                                                              [[MHCoreDataContext getInstance] saveContext];
                                                                                              
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
                                                                                      }else {
                                                                                          
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", [MHCollection createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                          NSArray *collectionsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          if ([predicationResult count] > 0) {
                                                                                              for (MHCollection *result in collectionsPredicatedWithModifiedDate) {
                                                                                                  [self updateCollection:result completionBlock:^(id object, NSError *error)   {
                                                                                                      if (error) {
                                                                                                          completionBlock(nil, error);
                                                                                                      }
                                                                                                  }];
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                  }
                                                                                  [[MHCoreDataContext getInstance] saveContext];
                                                                              }
                                                                                  predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusDeleted];
                                                                                  predicationResult = [coreDataCollections filteredArrayUsingPredicate:predicate];
                                                                              
                                                                                  if ([predicationResult count] > 0) {
                                                                                      for (MHCollection *eachCollectionWithStatus in predicationResult) {
                                                                                          predicate = [NSPredicate predicateWithFormat:@"id == %@", eachCollectionWithStatus.objId];
                                                                                          predicationResult = [responseObject filteredArrayUsingPredicate:predicate];
                                                                                          if ([predicationResult count] > 0) {
                                                                                              for (MHCollection *collectionsWithStatus in predicationResult) {
                                                                                                  [self deleteCollection:collectionsWithStatus completionBlock:^(id object, NSError *error) {
                                                                                                      if (error) {
                                                                                                          completionBlock(nil, error);
                                                                                                      }else {
                                                                                                          [[MHCoreDataContext getInstance].managedObjectContext deleteObject:collectionsWithStatus];
                                                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                                                      }
                                                                                                  }];
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                  }else {
                                                                                      for (MHCollection *eachCollectionWithoutStatus in coreDataCollections) {
                                                                                          predicate = [NSPredicate predicateWithFormat:@"id == %@", eachCollectionWithoutStatus.objId];
                                                                                          predicationResult = [responseObject filteredArrayUsingPredicate:predicate];
                                                                                          if ([predicationResult count] == 0) {
                                                                                              [self createCollection:eachCollectionWithoutStatus completionBlock:^(id object, NSError *error) {
                                                                                                  if (error) {
                                                                                                      completionBlock(nil, error);
                                                                                                  }
                                                                                              }];
                                                                                          }
                                                                                      }
                                                                                  }
                                                                          }else if ([coreDataCollections count] > 0 && [responseObject count] == 0) {
                                                                              for (MHCollection *collection in coreDataCollections) {
                                                                                  if ([collection.objStatus isEqualToString:objectStatusNew]) {
                                                                                      if ([collection.objType isEqualToString:collectionTypePublic] || [collection.objType isEqualToString:collectionTypePrivate]) {
                                                                                          [self createCollection:collection completionBlock:^(id object, NSError *error) {
                                                                                              if (error) {
                                                                                                  completionBlock(nil, error);
                                                                                              }
                                                                                          }];
                                                                                      }
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
    __block MHCollection *coreDataCollection = [MHDatabaseManager collectionWithObjName:collection.objId];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          if ([coreDataCollection.objType isEqualToString:collectionTypePublic]) {
                                                                              NSDate *laterThanDate = [responseObject[@"created_date"] dateFromRFC3339String];
                                                                              if ([[coreDataCollection.objModifiedDate laterDate: laterThanDate] isEqualToDate:coreDataCollection.objModifiedDate]) {
                                                                                  [self updateCollection:c completionBlock:^(id object, NSError *error) {
                                                                                      if (error) {
                                                                                          completionBlock(nil, error);
                                                                                      }
                                                                                  }];
                                                                              }else {
                                                                                  [[MHCoreDataContext getInstance].managedObjectContext deleteObject:collection];
                                                                                  [[MHCoreDataContext getInstance]saveContext];
                                                                                  MHCollection * collection = [MHDatabaseManager insertCollectionWithObjName:responseObject[@"name"] objDescription:responseObject[@"description"] objTags:responseObject[@"tags"] objCreatedDate:[MHCollection createdDateFromString:responseObject[@"created_date"]] objModifiedDate:nil objOwnerNilAddLogedUserCode:responseObject[@"owner"] objStatus:objectStatusOk objType:nil];
                                                                                  collection.objId = responseObject[@"id"];
                                                                                  [collection typeFromBoolValue:responseObject[@"public"]];
                                                                                  [collection modifiedDateFromString:responseObject[@"modified_date"]];
                                                                                  [[MHCoreDataContext getInstance]saveContext];
                                                                              }
                                                                          }else {
                                                                              [self deleteCollection:collection completionBlock:^(id object, NSError *error) {
                                                                                  if (error) {
                                                                                      completionBlock(nil, error);
                                                                                  }
                                                                              }];
                                                                          }
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

    NSData* assetData = [[MHImageCache sharedInstance] dataForKey:media.objKey];
    [manager POST:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:assetData name:@"image" fileName:media.objKey mimeType:@"image/*"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                                                          [[MHCoreDataContext getInstance].managedObjectContext deleteObject:media];
                                                                          [[MHCoreDataContext getInstance]saveContext];
                                                                          completionBlock(nil, nil);
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
                                                                          i.objLocation = responseObject[@"location"];
                                                                          NSString* date = responseObject[@"created_date"];
                                                                          i.objCreatedDate = [date dateFromRFC3339String];
                                                                          date = responseObject[@"modified_date"];
                                                                          i.objModifiedDate = [date dateFromRFC3339String];
                                                                          i.objOwner = responseObject[@"owner"];
                                                                          
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
                                                                                      predicate = [NSPredicate predicateWithFormat:@"objModifiedDate < %@",[MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                      NSArray *itemsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                      
                                                                                      if ([itemsPredicatedWithModifiedDate count] > 0) {
                                                                                          for (MHItem *result in itemsPredicatedWithModifiedDate) {
                                                                                              
                                                                                              [collection removeItemsObject:result];
                                                                                              
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
                                                                                      }else {
                                                                                          predicate = [NSPredicate predicateWithFormat:@"objModifiedDate > %@", [MHItem createdDateFromString:responseDictionary[@"modified_date"]]];
                                                                                          NSArray *itemsPredicatedWithModifiedDate = [predicationResult filteredArrayUsingPredicate:predicate];
                                                                                          
                                                                                          if ([predicationResult count] > 0) {
                                                                                              for (MHItem *result in itemsPredicatedWithModifiedDate) {
                                                                                                  [self updateItem:result completionBlock:^(id object, NSError *error) {
                                                                                                      if (error) {
                                                                                                          completionBlock(nil, error);
                                                                                                      }
                                                                                                  }];
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                  }
                                                                                  
                                                                                  [[MHCoreDataContext getInstance] saveContext];
                                                                                  
                                                                                   predicate = [NSPredicate predicateWithFormat:@"objStatus == %@", objectStatusDeleted];
                                                                                   predicationResult = [coreDataItems filteredArrayUsingPredicate:predicate];
                                                                                   
                                                                                   if ([predicationResult count] > 0) {
                                                                                       for (MHItem *eachItemWithStatus in predicationResult) {
                                                                                           predicate = [NSPredicate predicateWithFormat:@"id == %@", eachItemWithStatus.objId];
                                                                                           predicationResult = [responseObject filteredArrayUsingPredicate:predicate];
                                                                                           if ([predicationResult count] > 0) {
                                                                                               for (MHItem *itemWithStatus in predicationResult) {
                                                                                                   [self deleteItemWithId:itemWithStatus completionBlock:^(id object, NSError *error) {
                                                                                                       if (error) {
                                                                                                           completionBlock(nil, error);
                                                                                                       }else {
                                                                                                           [collection removeItemsObject:itemWithStatus];
                                                                                                       }
                                                                                                   }];
                                                                                               }
                                                                                           }
                                                                                       }
                                                                                   }else {
                                                                                       for (MHItem *eachItemWithoutStatus in coreDataItems) {
                                                                                           predicate = [NSPredicate predicateWithFormat:@"id == %@", eachItemWithoutStatus.objId];
                                                                                           predicationResult = [responseObject filteredArrayUsingPredicate:predicate];
                                                                                           if ([predicationResult count] == 0) {
                                                                                               [self createItem:eachItemWithoutStatus completionBlock:^(id object, NSError *error) {
                                                                                                   if (error) {
                                                                                                       if (error) {
                                                                                                           completionBlock(nil, error);
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
                                                                          completionBlock(i, error);
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
