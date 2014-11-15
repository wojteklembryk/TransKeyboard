/*
 * Copyright (c) 2014 Pawel Ferens. All rights reserved.
 */
#import <Foundation/Foundation.h>


extern NSString *const TRANS_TRANSLATOR_ERROR_DOMAIN;

@interface TransTranslateRequest : NSObject

+ (NSURLSession *)googleTranslateMessage:(NSString *)message
                              withSource:(NSString *)source
                                  target:(NSString *)target
                                     key:(NSString *)key
                              completion:(void (^)(NSString *translatedMessage, NSString *detectedSource, NSError *error))completion;

@end
