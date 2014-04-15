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
#import "MHItem.h"
#import "MHMedia.h"
#import "MHDatabaseManager.h"
#import "MHCoreDataContext.h"
#import "NSString+RFC3339.h"

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
            ret = @"http://78.133.154.18:8080";
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
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"GET" URLString:[self urlWithPath:@"users"] parameters:nil error:&error];
    
    
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
                                                        URLString:[self urlWithPath:@"users"]
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
    
#warning - this is wrong, we should use 'users/user_id'
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[self urlWithPath:@"users"]
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

#pragma get token/login

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

#pragma Collections/create collection

- (AFHTTPRequestOperation *)createCollection:(MHCollection *)collection
                             completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:@{@"name": collection.objName,
                                                                       @"description": collection.objDescription,
                                                                       @"tags":collection.objTags}
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

#pragma read all of user collections

- (AFHTTPRequestOperation *)readUserCollectionsWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          for (NSDictionary *responseDictionary in responseObject) {
                                                                              
                                                                              NSString* date = responseObject[@"created_date"];
                                                                              NSDate* created = [date dateFromRFC3339String];
                                                                              date = responseObject[@"modified_date"];
                                                                              NSDate* modified = [date dateFromRFC3339String];

                                                                              
                                                                              MHCollection *createdCollection = [MHDatabaseManager insertCollectionWithObjName:responseDictionary[@"name"]
                                                                                                                                                objDescription:responseDictionary[@"description"]
                                                                                                                                                       objTags:responseDictionary[@"tags"]
                                                                                                                                                objCreatedDate:created
                                                                                                                                               objModifiedDate:modified
                                                                                                                                                      objOwner:responseDictionary[@"owner"]];
                                                                              
                                                                              createdCollection.objId = responseDictionary[@"id"];
                                                                          }
                                                                          
                                                                          [[MHCoreDataContext getInstance] saveContext];
                                                                          
                                                                          completionBlock(nil, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma read specified user collection

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
                                                                          c.objName = responseObject[@"name"];
                                                                          c.objDescription = responseObject[@"description"];
                                                                          c.objTags = responseObject[@"tags"];
                                                                          NSString* date = responseObject[@"created_date"];
                                                                          c.objCreatedDate = [date dateFromRFC3339String];
                                                                          date = responseObject[@"modified_date"];
                                                                          c.objModifiedDate = [date dateFromRFC3339String];
                                                                          c.objOwner = responseObject[@"owner"];
                                                                          c.objId = responseObject[@"id"];
                                                                          
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

#pragma update collection

- (AFHTTPRequestOperation *)updateCollection:(MHCollection *)collection
                       completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
                                                       parameters:@{@"name": collection.objName,
                                                                    @"description": collection.objDescription,
                                                                    @"tags":collection.objTags}
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

#pragma delete collection

- (AFHTTPRequestOperation *)deleteCollection:(MHCollection *)collection
                                   completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setValue:_accessToken forHTTPHeaderField:@"Authorization"];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collection.objId]
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

#pragma Media/create media

- (AFHTTPRequestOperation *)createMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];

    __block MHMedia* m = media;
    NSURL *url = [NSURL fileURLWithPath:media.objLocalPath];
#warning test and update this method if needed
    [manager POST:[self urlWithPath:@"media"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:url name:media.objId error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        m.objId = responseObject[@"id"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;

}

#pragma read media

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
                                                                          NSData* imageData = responseObject;
                                                                          NSString* imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", responseObject[@"id"]]];
                                                                          [imageData writeToFile:imagePath atomically:YES];
                                                                          
                                                                          [self updateMedia:tmpMedia completionBlock:nil];
                                                                          
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma update media

- (AFHTTPRequestOperation *)updateMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:_accessToken forHTTPHeaderField:@"Authorization"];

    NSURL *url = [NSURL fileURLWithPath:media.objId];
#warning test and update if needed
    [manager POST:[NSString stringWithFormat:@"%@%@/",[self urlWithPath:@"media"],media.objId] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:url name:media.objId error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(nil, error);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;
}

#pragma delete media

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
#warning remove media object from database?
                                                                          completionBlock(nil, nil);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma read thumbnail

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

#pragma Item/create item

- (AFHTTPRequestOperation *)createItem:(MHItem *)item
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
                                                                          
                                                                          for (MHMedia *media in i.media) {
                                                                              for (NSDictionary *d in responseObject[@"media"]) {
                                                                                  media.objId = [d valueForKey:@"url"];
                                                                                  media.objLocalPath = [d valueForKey:@"url"];
                                                                              }
                                                                          }
                                                                          
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

#pragma update item

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

#pragma delete item

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
