/*
 * Copyright (c) 2014 Pawel Ferens. All rights reserved.
 */
#import "TransTranslateRequest.h"
#import "NSString+TransTranslator.h"


NSString *const TRANS_TRANSLATOR_ERROR_DOMAIN = @"TransTranslatorErrorDomain";

@implementation TransTranslateRequest

+ (NSURLSession *)googleTranslateMessage:(NSString *)message
                              withSource:(NSString *)source
                                  target:(NSString *)target
                                     key:(NSString *)key
                              completion:(void (^)(NSString *translatedMessage, NSString *detectedSource, NSError *error))completion {
    NSURL *base = [NSURL URLWithString:@"https://www.googleapis.com/language/translate/v2"];

    NSMutableString *queryString = [NSMutableString string];
    // API key
    [queryString appendFormat:@"?key=%@", key];
    // output style
    [queryString appendString:@"&format=text"];
    [queryString appendString:@"&prettyprint=false"];

    // source language
    if (source)
        [queryString appendFormat:@"&source=%@", source];

    // target language
    [queryString appendFormat:@"&target=%@", target];

    // message
    [queryString appendFormat:@"&q=%@", [NSString urlEncodedStringFromString:message]];

    NSURL *requestURL = [NSURL URLWithString:queryString relativeToURL:base];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithURL:requestURL
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"TransTranslator failed translate: %@", response);

                    completion(nil, nil, error);
                } else {
                    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions
                                                                                         error:nil];
                    NSDictionary *translation = [[[responseDictionary objectForKey:@"data"] objectForKey:@"translations"] objectAtIndex:0];
                    NSString *translatedText = [translation objectForKey:@"translatedText"];
                    NSString *detectedSource = [translation objectForKey:@"detectedSourceLanguage"];
                    if (!detectedSource) {
                        detectedSource = source;
                    }

                    completion(translatedText, detectedSource, nil);
                }
            }
    ] resume];

    return session;
}

@end
