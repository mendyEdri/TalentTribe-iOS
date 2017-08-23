//
//  CommManager.m
//  TalentTribe
//
//  Created by Bogdan Andresyuk on 3/25/15.
//  Copyright (c) 2015 OnOApps. All rights reserved.
//

#import "CommManager.h"
#import "GeneralMethods.h"
#import <AFNetworking/AFNetworking.h>
#import <Photos/Photos.h>

#define BASE_BACKOFFICE_URL [NSString stringWithFormat:@"%@/backoffice", self.baseURLString.length > 0 ? self.baseURLString : SERVER_URL]
#define BASE_TT_SERVER_URL [NSString stringWithFormat:@"%@/tt-server/rest", self.baseURLString.length > 0 ? self.baseURLString : SERVER_URL]

@interface CommManager()

@property (nonatomic, strong) NSDictionary *loginDict;

@end

@implementation CommManager

#pragma mark Initialization

+ (instancetype)sharedManager {
    static CommManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CommManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        /*AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager.securityPolicy setAllowInvalidCertificates:YES];
        [manager.securityPolicy setValidatesCertificateChain:NO];
        [manager.securityPolicy setValidatesDomainName:NO];*/
    }
    return self;
}

-(NSString *)stringFromEnum:(ContentType)type
{
    switch (type) {
        case Json:
            return @"json";
            break;
        case Octet_Stream:
            return @"octet-stream";
            break;
        default:
            return @"json";
            break;
    }
}

#pragma mark Login handling

- (void)loginWithDictionary:(NSDictionary *)loginDict completionHandler:(SimpleResultBlock)completion {
    if (loginDict) {
        DLog(@"BASE BACKOFFICE %@ %@ %@", BASE_BACKOFFICE_URL, self.baseURLString, SERVER_URL);
        self.loginDict = loginDict;
        
        //step 1, make login.html call
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
        [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
        
        DLog(@"Account login request %@ %@, headers %@", [NSString stringWithFormat:@"%@/%@", BASE_BACKOFFICE_URL, @"index.html"], loginDict, manager.requestSerializer.HTTPRequestHeaders);
        
        
        [manager GET:[NSString stringWithFormat:@"%@/%@", BASE_BACKOFFICE_URL, @"index.html"] parameters:loginDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSHTTPURLResponse *response = [operation response];
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:operation.request.URL];
            NSString *decodedString = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
            DLog(@"Response for login.html: %@, headers %@", decodedString, [response allHeaderFields]);
            __block NSUInteger idCookieIndex = NSNotFound;
            [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSHTTPCookie class]]) {
                    NSHTTPCookie *cookie = (NSHTTPCookie *)obj;
                    if ([cookie.name isEqualToString:@"JSESSIONID"] && cookie.value) {
                        idCookieIndex = idx;
                        *stop = YES;
                    }
                }
            }];
            
            if (idCookieIndex != NSNotFound) {
                void (^performSecurityCheck)(AFHTTPRequestOperation *operation) = ^(AFHTTPRequestOperation *operation){
                    NSHTTPURLResponse *response = [operation response];
                    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:operation.request.URL];
                    
                    NSString *decodedString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    DLog(@"Response for j_security_check: %@, headers %@", decodedString, [response allHeaderFields]);
                    
                    __block NSUInteger ssoCookieIndex = NSNotFound;
                    [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([obj isKindOfClass:[NSHTTPCookie class]]) {
                            NSHTTPCookie *cookie = (NSHTTPCookie *)obj;
                            if ([cookie.name isEqualToString:@"JSESSIONIDSSO"] && cookie.value) {
                                ssoCookieIndex = idx;
                                *stop = YES;
                            }
                        }
                    }];
                    
                    if (ssoCookieIndex != NSNotFound) {
                        DLog(@"Authorized");
                        if (completion) {
                            completion(responseObject, nil);
                        }
                    } else {
                        //probably we got an error
                        DLog(@"No cookie found in j_security_check response");
                        [[DataManager sharedManager] clearCurrentUser];
                        if (completion) {
                            completion(nil, [NSError errorWithDomain:@"Looks like email or password is incorrect." code:0 userInfo:nil]);
                        }
                    }
                };
                //step 2, make j_security_check call
                [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
                [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
                DLog(@"JSecurity check to URL %@ with headers %@",[NSString stringWithFormat:@"%@/%@", BASE_BACKOFFICE_URL, @"j_security_check"], manager.requestSerializer.HTTPRequestHeaders)
                [manager POST:[NSString stringWithFormat:@"%@/%@", BASE_BACKOFFICE_URL, @"j_security_check"] parameters:loginDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    performSecurityCheck(operation);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    DLog(@"Request for j_security_check failed. Reason %@", error);
                    performSecurityCheck(operation);
                }];
            } else {
                //probably we got an error
                DLog(@"No cookie found in index.html response");
                [[DataManager sharedManager] clearCurrentUser];
                if (completion) {
                    completion(nil, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSHTTPURLResponse *response = [operation response];
            DLog(@"Request for index.html failed: %@, headers %@", error, [response allHeaderFields]);
            if (completion) {
                completion(nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
            }
        }];
    } else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:0 userInfo:nil]);
        }
    }
}

- (void)logoutWithDictionary:(NSDictionary *)logoutDict completionHandler:(SimpleCompletionBlock)completion {
    self.loginDict = nil;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager GET:[NSString stringWithFormat:@"%@/%@", BASE_BACKOFFICE_URL, @"logout"] parameters:logoutDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Request for logout succeed");
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request for logout failed: %@", error);
        if (completion) {
            completion(NO, error);
        }
    }];
}

- (void)updateCurrentUserWithDictionary:(NSDictionary *)userDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUpdateUser] params:userDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/updateUser: %@", responseObject);
            if (completion) {
                completion(responseObject, nil);
            }
            /*if ([responseObject isKindOfClass:[NSArray class]]) {
             if (completion) {
             completion(responseObject, nil);
             }
            } else {
                DLog(@"Request for user/updateUser failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[chanNSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }*/
        } else {
            DLog(@"Request for user/updateUser failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)updatePasswordWithDictionary:(NSDictionary *)passDict completionHandler:(SimpleCompletionBlock)completion {
    __block NSString *newPassword = passDict[@"newPassword"];
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUpdatePassword] params:passDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            
            DLog(@"Response for user/changePassword: %@", responseObject);
            // save new password in credential
            NSNumber *code = responseObject[@"messageId"];
            if ([code integerValue] == 2000) {
                [[DataManager sharedManager] setPassword:newPassword];
            }
            if (completion) {
                completion(responseObject, nil);
            }
        } else {
            DLog(@"Request for user/changePassword failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)registerUserWithLinkedinToken:(NSString *)token completionHandler:(SimpleResultBlock)completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [manager POST:[NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/linkedinRegister"] parameters:@{@"accessToken" : token} success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        completion(responseObject, nil);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
            if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
        }
    }];
}

- (void)registerWithDictionary:(NSDictionary *)pushDict completionHandler:(SimpleResultBlock)completion {
    DLog(@"Account registration request %@ %@", [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/register"], pushDict);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager POST:[NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/register"] parameters:pushDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Response for user/register: %@", responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request for user/register failed: %@", error);
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
        }
    }];
}

- (void)registerToPushWithDictionary:(NSDictionary *)pushDict completionHandler:(SimpleCompletionBlock)completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager POST:[NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/registerToPush"] parameters:pushDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Response for user/registerToPush: %@", responseObject);
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request for user/registerToPush failed: %@", error);
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
        }
    }];
}

- (void)userNotification:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager POST:[NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/getUserNotifications"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Response for user/registerToPush: %@", responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request for user/registerToPush failed: %@", error);
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
        }
    }];
}

- (void)getStoryWithParams:(NSDictionary *)params completionHandler:(SimpleResultBlock)completion
{
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[[self baseURLStringForRequestType:RequestTypeGetStory] stringByAppendingString:@"/"] params:params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error)
    {
        if (responseObject && !error)
        {
            DLog(@"Response for user/getStory: %@", responseObject);
            if (completion)
            {
                completion(responseObject, nil);
            }
        }
        else
        {
            DLog(@"Request for user/getStory failed: %@", error);
            if (completion)
            {
                completion(nil, error);
            }
        }
    }];
}

- (void)uploadVideoWithParams:(NSMutableDictionary *)params completionHandler:(SimpleResultBlock)completion
{
    [self performRequestWithMethod:@"POST" contentType:Octet_Stream toURL:[[self baseURLStringForRequestType:RequestTypeUploadVideo] stringByAppendingString:@"/"] params:params completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error)
     {
         if (responseObject && !error)
         {
             DLog(@"Response for media/uploadVideo: %@", responseObject);
             if (completion)
             {
                 completion(responseObject, nil);
             }
         }
         else
         {
             DLog(@"Request for media/uploadVideo: %@", error);
             if (completion)
             {
                 completion(nil, error);
             }
         }
     }];
}



- (void)userProfileWithUserId:(NSString *)userId completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[[self baseURLStringForRequestType:RequestTypeGetProfile] stringByAppendingFormat:@"/%@", userId] params:nil completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/getUserProfile: %@", responseObject);
            if (completion) {
                completion(responseObject, nil);
            }
        } else {
            DLog(@"Request for user/getUserProfile failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)getUserIdWithCompletionHandler:(SimpleResultBlock)completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager GET:[NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/detailedWhoami"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Response for user/detailedWhoami: %@", responseObject);
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request for user/detailedWhoami failed: %@", error);
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
        }
    }];
}

- (void)unregisterFromPushWithDictionary:(NSDictionary *)pushDict completionHandler:(SimpleCompletionBlock)completion {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
    [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
    [manager POST:[NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/unregisterFromPush"] parameters:pushDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DLog(@"Response for user/unregisterFromPush: %@", responseObject);
        if (completion) {
            completion(YES, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"Request for user/unregisterFromPush failed: %@", error);
        if (completion) {
            completion(NO, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
        }
    }];
}

#pragma mark Story loading

- (void)storyFeedWithDictionary:(NSDictionary *)storyFeedDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeStoryFeedForCategory] params:storyFeedDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for getUserFeed: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]] || [responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"/: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for getUserFeed failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)storyFeedIndexesWithDictionary:(NSDictionary *)paramsDictionary completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeGetFeedIndexes] params:paramsDictionary completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for getUserFeedIndexes: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, error);
                }
            } else {
                DLog(@"Request for getUserFeedIndexes failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for getUserFeedIndexes failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }

    }];
}

- (void)storyFeedStoriesById:(NSDictionary *)paramsDictionary completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeGetFeedStoriesById] params:paramsDictionary completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for getStoriesByIds: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]] || [responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, error);
                }
            } else {
                DLog(@"Request for getStoriesByIds failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for getStoriesByIds failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)storyFeedWithCategoryName:(NSString *)categoryName completionHandler:(SimpleResultBlock)completion {
    NSString *requestUrl = [NSString stringWithFormat:@"%@?categoryName=%@", [self baseURLStringForRequestType:RequestTypeFeedByCategory], categoryName];
    requestUrl = [requestUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self performRequestWithMethod:@"GET" contentType:Json toURL:requestUrl params:nil completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for getStoriesByCategory: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]] || [responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"/: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for getStoriesByCategory failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)addStoryFromDictionary:(NSDictionary *)storyDict anonymously:(BOOL)anonymously completionHandler:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[NSString stringWithFormat:@"%@%@", [self baseURLStringForRequestType:RequestTypeAddStory], anonymously ? @"/true" : @""] params:storyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/getUserFeedIndexes: %@", responseObject);
            if (completion) {
                completion(YES, nil);
            }
        } else {
            DLog(@"Request for story/getUserFeedIndexes failed: %@", error);
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

- (void)updateStoryFromDictionary:(NSDictionary *)storyDict completionHandler:(SimpleCompletionBlock)completion
{
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUpdateStory] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:storyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/updateStory: %@", responseObject);
            if (completion) {
                completion(YES, nil);
            }
        } else {
            if (error) {
                DLog(@"Request for story/updateStory failed: %@", error);
            }
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

- (void)removeStoryFromDictionary:(NSDictionary *)storyDict storyId:(NSString *)storyId completionHandler:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"DELETE" contentType:Json toURL:[NSString stringWithFormat:@"%@/%@", [self baseURLStringForRequestType:RequestTypeRemoveStory], storyId] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:storyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/deleteStory: %@", responseObject);
            if (completion) {
                completion(YES, nil);
            }
        } else {
            DLog(@"Request for story/deleteStory failed: %@", error);
            if (completion) {
                completion(NO, error);
            }
        }
    }];
}

#pragma mark Comments handling

- (void)commentsFromDictionary:(NSDictionary *)commentDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeCommentsForPage] params:commentDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for comment/getStoryComments: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for comment/getStoryComments failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for comment/getStoryComments failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)addCommentFromDictionary:(NSDictionary *)commentDict storyId:(NSString *)storyId completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[NSString stringWithFormat:@"%@/%@", [self baseURLStringForRequestType:RequestTypeAddComment], storyId] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:commentDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/addComment: %@", responseObject);
            if ([responseObject isKindOfClass:[NSData class]]) {
                if (completion) {
                    completion([[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding], nil);
                }
            } else {
                DLog(@"Request for story/addComment failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for story/addComment failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)removeCommentFromDictionary:(NSDictionary *)commentDict commentId:(NSString *)commentId completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"DELETE" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeRemoveComment] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:commentDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for comment/deleteComment: %@", responseObject);
            if (completion) {
                completion(responseObject, nil);
            }
        } else {
            DLog(@"Request for comment/deleteComment failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)updateCommentFromDictionary:(NSDictionary *)commentDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUpdateComment] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:commentDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for comment/updateComment: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
            if ([responseObject isKindOfClass:[NSData class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for comment/updateComment failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for comment/updateComment failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

#pragma mark Wanna work

- (void)wannaWorkWithDictionary:(NSDictionary *)companyDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeWannaWork] params:companyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/wannaWork: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for user/wannaWork failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for user/wannaWork failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)likeStoryWithDictionary:(NSDictionary *)storyDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeLikeStory] params:storyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/like: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for story/like failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for story/like failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}


#pragma mark Profile handling

- (void)likedCompaniesFromDictionary:(NSDictionary *)likedDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUserLikedCompanies] params:likedDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/getUserWannaWorkCompanies: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for user/getUserWannaWorkCompanies failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for user/getUserWannaWorkCompanies failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)likedStoriesFromDictionary:(NSDictionary *)likedDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUserLikedStories] params:likedDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/getLikedStories: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for user/getLikedStories failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for user/getLikedStories failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)uploadCVRequestFromDictionary:(NSDictionary *)cvDict completionHandler:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUploadCV] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:cvDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/sendUploadCvRequest: %@", responseObject);
            if (completion) {
                completion(responseObject, nil);
            }
        } else {
            DLog(@"Request for user/sendUploadCvRequest failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)uploadWitoutUserSessionCVRequestFromDictionary:(NSDictionary *)cvDict completionHandler:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUploadCVWithoutSession] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:cvDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/sendUploadLiveCvRequest: %@", responseObject);
            if (completion) {
                completion(responseObject, nil);
            }
        } else {
            if (!error) {
                return ;
            }
            DLog(@"Request for user/sendUploadLiveCvRequest failed:");
            if (completion) {
                completion(nil, nil);
            }
        }
    }];
}

- (void)deleteCVRequestFromDictionary:(NSDictionary *)cvDict completionHandler:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeDeleteCV] requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFHTTPResponseSerializer serializer] retryCount:1 params:cvDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/deleteUserCV: %@", responseObject);
            if (completion) {
                completion(responseObject, nil);
            }
        } else {
            DLog(@"Request for user/deleteUserCV failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)userFeedFromDictionary:(NSDictionary *)userFeedDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeUserStories] params:userFeedDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/getStoriesByUser: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for story/getStoriesByUser failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for story/getStoriesByUser failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)refreshIndexesWithEncrypedIds:(NSString *)sha1String completionHandler:(SimpleResultBlock)completion {
    NSString *fullUrl = [NSString stringWithFormat:@"%@/%@", [self baseURLStringForRequestType:RequestTypeRefreshIndexes], sha1String];
    [self performRequestWithMethod:@"GET" contentType:Json toURL:fullUrl params:nil completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for RefreshFeed: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, error);
                }
            } else {
                DLog(@"Request for RefreshFeed failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for RefreshFeed failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
        
    }];
}

#pragma mark - Search

- (void)quickSearchWithString:(NSString *)searchString completion:(SimpleResultBlock)completion {
    NSString *requestUrl = [NSString stringWithFormat:@"%@?q=%@", [self baseURLStringForRequestType:RequestTypeQuickSearch], searchString];
    [self performRequestWithMethod:@"GET" contentType:Json toURL:requestUrl params:nil completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        completion(responseObject, error);
    }];
}

#pragma mark Company Info handling

- (void)validateUserEmailToCompany:(NSString *)email completion:(SimpleCompletionBlock)completion
{
    NSString *url = [self baseURLStringForRequestType:RequestTypeValidateUserEmailToCompany];
    
    [self performRequestWithMethod:@"POST" contentType:Json toURL:url params:@{@"email" : email} completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        
        if (!completion) {
            return ;
        }
        
        completion((!error), error); // Returns 204 no-content if OK, error if not.
    }];
}

-(void)validateUserCodeToCompany:(NSString *)code completion:(SimpleResultBlock)completion
{
    NSString *url = [self baseURLStringForRequestType:RequestTypeValidateUserCodeToCompany];
    [self performRequestWithMethod:@"POST" contentType:Json toURL:url params:@{@"code" : code} completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error)
    {
        if (!completion)
        {
            return ;
        }
        
        completion(responseObject, error); // Returns "true"/"false" if validation successes.
    }];
}

-(void)companyById:(NSString *)companyId completionHandler:(SimpleResultBlock)completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%@",[self baseURLStringForRequestType:RequestTypeCompanyInfo],companyId];
    
    [self performRequestWithMethod:@"GET" contentType:Json toURL:url params:nil completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error)
     {
         if (!completion)
         {
             return ;
         }
         
         completion(responseObject, error);
     }];
}


- (void)companyInfoFromDictionary:(NSDictionary *)companyInfoDict companyId:(NSString *)companyId completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[NSString stringWithFormat:@"%@/%@", [self baseURLStringForRequestType:RequestTypeCompanyInfo], companyId] params:companyInfoDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for company/getCompanyDetails: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for company/getCompanyDetails failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for company/getCompanyDetails failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)companyFeedFromDictionary:(NSDictionary *)companyFeedDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeCompanyStories] params:companyFeedDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for story/getCompanyFeed: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for story/getCompanyFeed failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for story/getCompanyFeed failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)companyPositionsFromDictionary:(NSDictionary *)companyDict companyId:(NSString *)companyId completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"GET" contentType:Json toURL:[NSString stringWithFormat:@"%@/%@", [self baseURLStringForRequestType:RequestTypeCompanyPositions], companyId] params:companyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for positionCompany/getAllOpenPositionsByCompany: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for positionCompany/getAllOpenPositionsByCompany failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for positionCompany/getAllOpenPositionsByCompany failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];

}

#pragma mark Trending categories

- (void)exploreCategoriesFromDictionary:(NSDictionary *)trendingDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeExploreCategories] params:trendingDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for category/explore: %@", responseObject);
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for category/explore failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for category/explore failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

#pragma mark Filters

- (void)categoriesFromDictionary:(NSDictionary *)categoriesDict completionHandler:(SimpleResultBlock)completion {
}

- (void)companiesFromDictionary:(NSDictionary *)companyDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeCompaniesForPage] params:companyDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for company/findCompanies: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for company/findCompanies failed: unknown responseObject class");
                if (completion) {
                    completion(nil, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for company/findCompanies failed: %@", error);
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}

- (void)industryFromDictionary:(NSDictionary *)industryDict completionHandler:(SimpleResultBlock)completion {
}

- (void)fundingStageFromDictionary:(NSDictionary *)fundingDict completionHandler:(SimpleResultBlock)completion {
}

- (void)stageFromDictionary:(NSDictionary *)stageDict completionHandler:(SimpleResultBlock)completion {
}

- (void)getCompanyNameFromDictionary:(NSDictionary *)searchDict completionHandler:(SimpleResultBlock)completion {
    return [self quickSearchWithDictionary:searchDict completionHandler:completion];
}

- (void)quickSearchWithDictionary:(NSDictionary *)searchDict completionHandler:(SimpleResultBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeQuickSearchOLD] params:searchDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/quickSearch: %@", responseObject);
            if ([responseObject isKindOfClass:[NSArray class]]) {
                if (completion) {
                    completion(responseObject, nil);
                }
            } else {
                DLog(@"Request for user/quickSearch failed: unknown responseObject class");
                if (completion) {
                    completion(responseObject, [NSError errorWithDomain:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__] code:0 userInfo:nil]);
                }
            }
        } else {
            DLog(@"Request for user/quickSearch failed: %@", error);
            if (completion) {
                completion(nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
            }
        }
    }];
}

- (void)recoverPasswordWithDict:(NSDictionary *)passwordDict completionHandler:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeRecoverPassword] params:passwordDict completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (!error) {
            DLog(@"Response for user/passwordRecovery: %@", responseObject);
            if (completion) {
                completion(YES, nil);
            }
        } else {
            DLog(@"Request for user/passwordRecovery failed: %@", error);
            if (completion) {
                completion(NO, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
            }
        }
    }];
}

- (void)performRequestWithMethod:(NSString *)method contentType:(ContentType)type toURL:(NSString *)urlString params:(NSDictionary *)params completionHandler:(void(^)(AFHTTPRequestOperation *operation, id responseObject, NSError *error))completion {
    [self performRequestWithMethod:method contentType:type toURL:urlString requestSerializer:[AFJSONRequestSerializer serializer] responseSerializer:[AFJSONResponseSerializer serializer] retryCount:1 params:params completionHandler:completion];
}

- (void)performRequestWithMethod:(NSString *)method contentType:(ContentType)type toURL:(NSString *)urlString requestSerializer:(AFHTTPRequestSerializer *)requestSerializer responseSerializer:(AFHTTPResponseSerializer *)responseSerializer retryCount:(NSInteger)retryCount params:(NSDictionary *)params completionHandler:(void(^)(AFHTTPRequestOperation *operation, id responseObject, NSError *error))completion {
    
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    mutableRequest.HTTPMethod = @"POST";
    [mutableRequest addValue:@"ios" forHTTPHeaderField:@"os"];
    NSString *contentType = [NSString stringWithFormat:@"application/%@",[self stringFromEnum:type]];

    [mutableRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (type == Octet_Stream)
    {
        [self uploadVideoUrl:urlString params:params completionHandler:completion];
    }
    else
    {
        [manager setResponseSerializer:responseSerializer];
        [manager setRequestSerializer:requestSerializer];
        [[manager requestSerializer] setValue:@"ios" forHTTPHeaderField:@"os"];
        [[manager requestSerializer] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];
        [[manager requestSerializer] setValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSString *jsonString;
        
        if (params) {
            NSError *writeError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&writeError];
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }

        DLog(@"Making request to URL %@ with params %@ headers %@", urlString, jsonString, manager.requestSerializer.HTTPRequestHeaders);
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        DLog(@"Start %f", time);
        void (^innerSuccessHandler)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            if (completion) {
                DLog(@"End %f", [[NSDate date] timeIntervalSince1970] - time);
                completion(operation, responseObject, nil);
            }
        };
        
        void (^innerFailureHandler)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
            void (^failure)(void) = ^{
                DLog(@"Request failed with status code %ld, returning", (long)operation.response.statusCode);
                if (completion) {
                    completion(operation, nil, [NSError errorWithDomain:@"" code:operation.response.statusCode userInfo:operation.responseObject]);
                }};
            if (retryCount > 0) {
                if (operation.response.statusCode == 500) {
                    DLog(@"Request failed with status code 500, retrying");
                    NSString *str = [NSHTTPURLResponse localizedStringForStatusCode:operation.response.statusCode];
                    DLog(@"str = %@", str);
                    
                    [self performRequestWithMethod:method contentType:Json toURL:urlString requestSerializer:requestSerializer responseSerializer:responseSerializer retryCount:retryCount - 1 params:params completionHandler:completion];
                } else if (operation.response.statusCode == 403) {
                    DLog(@"Request failed with status code 403, making login call");
                    [self clearCookies];
                    if (self.loginDict) {
                        [self loginWithDictionary:self.loginDict completionHandler:^(id result, NSError *error) {
                            if (result && !error) {
                                [self performRequestWithMethod:method contentType:Json toURL:urlString requestSerializer:requestSerializer responseSerializer:responseSerializer retryCount:retryCount - 1 params:params completionHandler:completion];
                            } else {
                                failure();
                            }
                        }];
                    } else {
                        failure();
                    }
                } else {
                    failure();
                }
            } else {
                failure();
            }
        };
        
        if ([[method uppercaseString] isEqualToString:@"GET"]) {
            [manager GET:urlString parameters:params success:innerSuccessHandler failure:innerFailureHandler];
        } else if ([[method uppercaseString] isEqualToString:@"POST"]) {
            [manager POST:urlString parameters:params success:innerSuccessHandler failure:innerFailureHandler];
        } else if ([[method uppercaseString] isEqualToString:@"DELETE"]) {
            [manager DELETE:urlString parameters:params success:innerSuccessHandler failure:innerFailureHandler];
        }
    }

}

-(NSData *)getDataFromPath:(id)path
{
    NSString *str;
    if ([path isMemberOfClass:[NSURL class]])
    {
        str = [((NSURL *)path) absoluteString];
    }
    else if ([path isMemberOfClass:[NSString class]] == NO)
    {
        return 0;
    }
    
    NSData *resultData;
    
    if ([str containsString:@"assets-library://"]) // file from device library...
    {
        NSURL *myMovieURL = [NSURL URLWithString:str];
        PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[myMovieURL] options:nil];
        PHAsset *asset = [result firstObject];
        resultData = [self getDataFromAsset:asset];
    }
    else if([str containsString:@"file:///"]) // file from video recorder...
    {
        str = [((NSURL *)path) path];
        resultData = [NSData dataWithContentsOfFile:str];
    }

    return resultData;
}

- (NSData *)getDataFromAsset:(PHAsset *)asset
{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    __block NSData *data;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:
     ^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
     {
         if (imageData)
         {
             data = imageData;
         }
     }];
    return data;
}

- (void)uploadVideoUrl:(NSString *)url params:(NSDictionary *)params completionHandler:(void(^)(AFHTTPRequestOperation *operation, id responseObject, NSError *error))completion
{
    NSData *videoData = [self getDataFromPath:params[@"videoFile"]];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        [formData appendPartWithFileData:videoData name:@"videoFile" fileName:@"video.mp4" mimeType:@"video/quicktime"];
    } error:nil];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
         NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        float uploadPercentge = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
        
        if ([self.delegate respondsToSelector:@selector(commManager:uploadProcessDidUpdatedWithPercent:)])
        {
            [self.delegate commManager:self uploadProcessDidUpdatedWithPercent:uploadPercentge];
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"%@ - %@",@"Upload Complete",operation.responseString);
        NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDict = [[NSDictionary alloc]initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        completion(nil, resultDict,nil);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"error: %@", operation.responseString);
        NSLog(@"%@",error);
        if ([self.delegate respondsToSelector:@selector(commManager:didFinishUploadingWithResult:error:)])
        {
            completion(nil,nil,error);
//            [self.delegate commManager:self didFinishUploadingWithResult:nil error:error];
        }
    }];
    
    [operation start];
}

- (void)followCompanyWithData:(NSDictionary *)body completion:(SimpleCompletionBlock)completion {
    [self performRequestWithMethod:@"POST" contentType:Json toURL:[self baseURLStringForRequestType:RequestTypeFollowCompany] params:body completionHandler:^(AFHTTPRequestOperation *operation, id responseObject, NSError *error) {
        if (responseObject && !error) {
            DLog(@"Response for user/userFollowRequest: %@", responseObject);
            [[NSUserDefaults standardUserDefaults] setObject:body[@"email"] forKey:@"userEmail"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (completion) {
                completion(YES, nil);
            }
        } else {
            DLog(@"Request for user/userFollowRequest failed: %@", error);
            if (completion) {
                completion(NO, error);
            }
        }
    }];

}


#pragma mark Misc methods

#pragma mark Requests handling

- (void)cancelRequestsForTypes:(NSArray *)types {
    NSMutableArray *itemsToCancel = [NSMutableArray new];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    for (NSNumber *number in types) {
        RequestType requestType = (RequestType)number.integerValue;
        NSString *requestURLString = [self baseURLStringForRequestType:requestType];
        for (AFHTTPRequestOperation *operation in manager.operationQueue.operations) {
            if ([operation.request.URL.absoluteString containsString:requestURLString]) {
                [itemsToCancel addObject:operation];
            }
        }
    }
    
    for (AFHTTPRequestOperation *operation in itemsToCancel) {
        [operation setCompletionBlockWithSuccess:nil failure:nil];
        [operation cancel];
    }
}

- (NSString *)baseURLStringForRequestType:(RequestType)type {
    switch (type) {
        case RequestTypeStoryFeedForCategory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getUserFeed"];
        } break;
        case RequestTypeGetFeedIndexes: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getUserFeedIndexes"];
        } break;
        case RequestTypeRefreshIndexes: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/refreshFeed"];
        } break;
        case RequestTypeGetFeedStoriesById: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getStoriesByIds"];
        } break;
        case RequestTypeAddStory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/addStory"];
        } break;
        case RequestTypeUpdateStory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/updateStory"];
        } break;
        case RequestTypeRemoveStory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/deleteStory"];
        } break;
        case RequestTypeGetStory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getStory"];
        } break;
        case RequestTypeCompanyInfo: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"company/getCompanyDetails"];
        } break;
        case RequestTypeCompanyStories: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getCompanyFeed"];
        } break;
        case RequestTypeCompanyPositions: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"positionCompany/getAllOpenPositionsByCompany"];
        } break;
        case RequestTypeWannaWork: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/wannaWork"];
        } break;
        case RequestTypeLikeStory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/like"];
        } break;
        case RequestTypeExploreCategories: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"category/explore"];
        } break;
        case RequestTypeQuickSearchOLD: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/quickSearch"];
        } break;
        case RequestTypeCompaniesForPage: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"company/findCompanies"];
        } break;
        case RequestTypeCommentsForPage: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"comment/getStoryComments"];
        } break;
        case RequestTypeAddComment: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/addComment"];
        } break;
        case RequestTypeUpdateComment: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"comment/updateComment"];
        } break;
        case RequestTypeRemoveComment: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"comment/deleteComment"];
        } break;
        case RequestTypeRecoverPassword: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/passwordRecovery"];
        } break;
        case RequestTypeUpdateUser: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/updateUser"];
        } break;
        case RequestTypeGetProfile: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/getUserProfile"];
        } break;
        case RequestTypeUserStories: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getStoriesByUser"];
        } break;
        case RequestTypeUserLikedStories: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/getLikedStories"];
        } break;
        case RequestTypeUserLikedCompanies: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/getUserWannaWorkCompanies"];
        } break;
        case RequestTypeUploadCV: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/sendUploadCvRequest"];
        } break;
        case RequestTypeUploadCVWithoutSession: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/sendCvRequest"];
        } break;
        case RequestTypeDeleteCV: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/deleteUserCV"];
        } break;
        case RequestTypeUpdatePassword: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/changePassword"];
        } break;
        case RequestTypeValidateUserEmailToCompany: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/validateCompany"];
        } break;
        case RequestTypeValidateUserCodeToCompany: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/companyEmailValidationCodeValidated"];
        } break;
        case RequestTypeUploadVideo: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"media/uploadVideo"];
        } break;
        case RequestTypeQuickSearch: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/quickSearch"];
        } break;
        case RequestTypeFeedByCategory: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"story/getStoriesByCategory"];
        } break;
        case RequestTypeFollowCompany: {
            return [NSString stringWithFormat:@"%@/%@", BASE_TT_SERVER_URL, @"user/userFollowRequest"];
        } break;
        default: {
            return nil;
        } break;
    }
}

- (void)clearCookies {
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in storage.cookies) {
        [storage deleteCookie:cookie];
    }
}

- (void)cancelAllRequests {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    for (AFHTTPRequestOperation *operation in manager.operationQueue.operations) {
        [operation setCompletionBlockWithSuccess:nil failure:nil];
    }
    [manager.operationQueue cancelAllOperations];
}

@end
