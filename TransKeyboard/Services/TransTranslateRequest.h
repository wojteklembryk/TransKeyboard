/*
 * Copyright (c) 2014 Pawel Ferens. All rights reserved.
 */
#import <Foundation/Foundation.h>


extern NSString *const TRANS_TRANSLATOR_ERROR_DOMAIN;

@interface TransTranslateRequest : NSObject

+ (NSURLSessionDataTask *)googleTranslateMessage:(NSString *)message
                              withSource:(NSString *)sourceLanguage
                                  target:(NSString *)targetLanguage
                                  apiKey:(NSString *)key
                              completion:(void (^)(NSString *translatedMessage, NSString *detectedSource, NSError *error))completion;

@end
