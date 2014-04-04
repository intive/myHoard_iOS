//
//  MHAPI.m
//  MyHoard
//
//  Created by Sebastian Jędruszkiewicz on 27/02/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHAPI.h"
#import "MHUserSettings.h"

static MHAPI *_sharedAPI = nil;

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
    return [NSString stringWithFormat:@"%@/%@", [self serverUrl], path];
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
                                                                          completionBlock(nil, error);
                                                                      }];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end
