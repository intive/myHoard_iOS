//
//  MHAPI.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAPI.h"
#import "MHUserSettings.h"
#import "MHItem.h"
#import "MHMedia.h"

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

#pragma read existing user

- (AFHTTPRequestOperation *)readUserWithCompletionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setAuthorizationHeaderFieldWithToken:_accessToken];
    
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
    [jsonRequest setAuthorizationHeaderFieldWithToken:_accessToken];
    
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
    [jsonRequest setAuthorizationHeaderFieldWithToken:_accessToken];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"DELETE"
                                                        URLString:[self urlWithPath:@"users"]
                                                       parameters:nil
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

#pragma mark - refresh token

- (AFHTTPRequestOperation *)refreshTokenForUser:(NSString *)email
                                   withPassword:(NSString *)password
                                completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setAuthorizationHeaderFieldWithToken:_accessToken];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"POST"
                                                        URLString:[self urlWithPath:@"oauth/token"]
                                                       parameters:@{@"email": email,
                                                                    @"password": password,
                                                                    @"grant_type": @"refresh_token",
                                                                    @"refresh_token": _refreshToken}
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

#pragma Collections/create collection

- (AFHTTPRequestOperation *)createCollection:(NSString *)name
                             withDescription:(NSString *)desc
                                    withTags:(NSArray *)tags
                             completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setAuthorizationHeaderFieldWithToken:_accessToken];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:@{@"name": name,
                                                                       @"description": desc,
                                                                       @"tags":tags}
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          
                                                                          MHCollection *createdCollection = [[MHCollection alloc]init];

                                                                          createdCollection.objId = responseObject[@"id"];
                                                                          createdCollection.objName = responseObject[@"name"];
                                                                          createdCollection.objDescription = responseObject[@"description"];
                                                                          createdCollection.objTags = responseObject[@"tags"];
                                                                          createdCollection.objItemsNumber = responseObject[@"items_number"];
                                                                          createdCollection.objCreatedDate = responseObject[@"dreated_date"];
                                                                          createdCollection.objModifiedDate = responseObject[@"modified_date"];
                                                                          createdCollection.objOwner = responseObject[@"owner"];
                                                                          
                                                                          completionBlock(createdCollection, error);
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
    [jsonSerializer setAuthorizationHeaderFieldWithToken:_accessToken];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[self urlWithPath:@"collections"]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          NSArray *responseArray = [[NSArray alloc]initWithArray:responseObject];
                                                                          completionBlock(responseArray, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma read specified user collection

- (AFHTTPRequestOperation *)readUserCollectionWithId:(NSString *)collectionId
                                     completionBlock:(MHAPICompletionBlock)completionBlock {
    
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setAuthorizationHeaderFieldWithToken:_accessToken];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"GET"
                                                           URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collectionId]
                                                          parameters:nil
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          NSArray *responseArray = [[NSArray alloc]initWithArray:responseObject];
                                                                          completionBlock(responseArray, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma update collection

- (AFHTTPRequestOperation *)updateCollectionWithId:(NSString *)collectionId
                                      withName:(NSString *)newName
                                   withDescription:(NSString *)newDescription
                                          withTags:(NSArray *)newTags
                       completionBlock:(MHAPICompletionBlock)completionBlock {
    NSError *error;
    
    AFJSONRequestSerializer* jsonRequest = [AFJSONRequestSerializer serializer];
    [jsonRequest setAuthorizationHeaderFieldWithToken:_accessToken];
    
    NSMutableURLRequest *request = [jsonRequest requestWithMethod:@"PUT"
                                                        URLString:[NSString stringWithFormat:@"%@%@",[self urlWithPath:@"collections"],collectionId]
                                                       parameters:@{@"name": newName,
                                                                    @"description": newDescription,
                                                                    @"tags":newTags}
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

- (AFHTTPRequestOperation *)createItem:(MHItem *)item
                       completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    
    AFJSONRequestSerializer *jsonSerializer = [AFJSONRequestSerializer serializer];
    [jsonSerializer setAuthorizationHeaderFieldWithToken:_accessToken];
    NSMutableURLRequest *request = [jsonSerializer requestWithMethod:@"POST"
                                                           URLString:[self urlWithPath:@"items"]
                                                          parameters:@{@"name": item.objName,
                                                                       @"description": item.objDescription,
                                                                       @"location":item.objLocation,
                                                                       @"quantity":item.objQuantity,
                                                                       @"media":item.objMediaIds}
                                                               error:&error];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                          completionBlock(nil, error);
                                                                      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                          completionBlock(nil, error);
                                                                      }];

    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}


- (AFHTTPRequestOperation *)createMedia:(MHMedia *)media
                        completionBlock:(MHAPICompletionBlock)completionBlock
{
    NSError *error;
    //Implementacja potrzebuje poprawy
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setAuthorizationHeaderFieldWithToken:_accessToken];

    NSURL *url = [NSURL fileURLWithPath:media.objLocalPath];
    [manager POST:@"http://78.133.154.18:8080/media" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:url name:media.objId error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(nil, error);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", nil]];
    
    return nil;

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
