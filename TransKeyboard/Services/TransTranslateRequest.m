/*
 * Copyright (c) 2014 Pawel Ferens. All rights reserved.
 */
#import "TransTranslateRequest.h"
#import "NSString+TransTranslator.h"


NSString *const TRANS_TRANSLATOR_ERROR_DOMAIN = @"TransTranslatorErrorDomain";

@implementation TransTranslateRequest

+ (NSURLSession *)googleTranslateMessage:(NSString *)message
                              withSource:(NSString *)sourceLanguage
                                  target:(NSString *)targetLanguage
                                  apiKey:(NSString *)key
                              completion:(void (^)(NSString *translatedMessage, NSString *detectedSource, NSError *error))completion {
    NSURL *baseUrl = [NSURL URLWithString:@"https://www.googleapis.com/language/translate/v2"];

    NSMutableString *queryString = [NSMutableString string];
    // API key
    [queryString appendFormat:@"?key=%@", key];
    // output style
    [queryString appendString:@"&format=text"];
    [queryString appendString:@"&prettyprint=false"];

    // sourceLanguage language
    if (sourceLanguage)
        [queryString appendFormat:@"&source=%@", sourceLanguage];

    // targetLanguage language
    [queryString appendFormat:@"&target=%@", targetLanguage];

    // message
    [queryString appendFormat:@"&q=%@", [NSString urlEncodedStringFromString:message]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl.absoluteString, queryString]];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:configuration];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    NSURLSessionDataTask *task = [defaultSession dataTaskWithURL:url
                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                   if (error) {
                                                       completion(nil, nil, error);
                                                   } else {
                                                       NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                          options:kNilOptions
                                                                                                                            error:nil];
                                                       NSDictionary *errorDictionary = [responseDictionary objectForKey:@"error"];
                                                       if (errorDictionary) {
                                                           NSError *e = [NSError errorWithDomain:TRANS_TRANSLATOR_ERROR_DOMAIN
                                                                                            code:[errorDictionary objectForKey:@"key"]
                                                                                        userInfo:errorDictionary];
                                                           completion(nil, nil, e);
                                                       } else {
                                                           NSDictionary *translation = [[[responseDictionary objectForKey:@"data"] objectForKey:@"translations"] objectAtIndex:0];
                                                           NSString *translatedText = [translation objectForKey:@"translatedText"];
                                                           NSString *detectedSource = [translation objectForKey:@"detectedSourceLanguage"];
                                                           if (!detectedSource) {
                                                               detectedSource = sourceLanguage;
                                                           }

                                                           completion(translatedText, detectedSource, nil);
                                                       }

                                                   }
                                               }
    ];
    [task resume];

    return task;
}

@end
