/*
 * Copyright (c) 2014 Pawel Ferens. All rights reserved.
 */
#import "TransTranslator.h"
#import "TransTranslateRequest.h"


typedef NSInteger TransTranslatorState;

enum TransTranslatorState {
    TransTranslatorStateInitial = 0,
    TransTranslatorStateInProgress = 1,
    TransTranslatorStateCompleted = 2
};

@interface TransTranslator ()

@property(nonatomic) TransTranslatorState translatorState;
@property(nonatomic) NSString *googleAPIKey;
@property(nonatomic, copy) TransTranslatorCompletionHandler completionHandler;
@property(nonatomic) NSURLSessionDataTask *dataTask;

@end

@implementation TransTranslator

- (id)initWithGoogleAPIKey:(NSString *)key {
    self = [super init];
    if (self) {
        self.translatorState = TransTranslatorStateInitial;

        self.googleAPIKey = key;
    }

    return self;
}

- (void)translateText:(NSString *)textToTranslate
           withSource:(NSString *)sourceLanguage
               target:(NSString *)targetLanguage
           completion:(TransTranslatorCompletionHandler)completion {
    if (!completion || !textToTranslate || textToTranslate.length == 0)
        return;

    if (self.googleAPIKey.length == 0) {
        NSError *error = [self errorWithCode:TransTranslatorErrorMissingCredentials
                                 description:@"missing Google credentials"];
        completion(error, nil, nil);
        return;
    }

    if (self.translatorState == TransTranslatorStateInProgress) {
        NSError *error = [self errorWithCode:TransTranslatorErrorTranslationInProgress
                                 description:@"translation already in progress"];
        completion(error, nil, nil);
        return;
    } else if (self.translatorState == TransTranslatorStateCompleted) {
        NSError *error = [self errorWithCode:TransTranslatorErrorAlreadyTranslated
                                 description:@"translation already completed"];
        completion(error, nil, nil);
        return;
    }
    else {
        self.translatorState = TransTranslatorStateInProgress;
    }

    // check cache for existing translation
    NSCache *cache = [TransTranslator translationCache];
    NSDictionary *cached = [cache objectForKey:textToTranslate];
    if (cached) {
        NSString *cachedSource = [cached objectForKey:@"src"];
        NSString *cachedTranslation = [cached objectForKey:@"txt"];

        NSLog(@"TransTranslator: returning cached translation");

        completion(nil, cachedTranslation, cachedSource);
        return;
    }

    sourceLanguage = [self filteredLanguageCodeFromCode:sourceLanguage];
    if (!targetLanguage) {
        targetLanguage = [self filteredLanguageCodeFromCode:[[NSLocale preferredLanguages] objectAtIndex:0]];
    }

    if ([[sourceLanguage lowercaseString] isEqualToString:targetLanguage]) {
        sourceLanguage = nil;
    }

    self.completionHandler = completion;

    if (self.googleAPIKey) {
        self.dataTask = [TransTranslateRequest googleTranslateMessage:textToTranslate
                                                            withSource:sourceLanguage
                                                                target:targetLanguage
                                                                apiKey:self.googleAPIKey
                                                            completion:^(NSString *translatedMessage, NSString *detectedSource, NSError *error) {
                                                                if (error) {
                                                                    [self handleError:error];
                                                                } else {
                                                                    [self handleSuccessWithOriginal:textToTranslate
                                                                                  translatedMessage:translatedMessage
                                                                                     detectedSource:detectedSource];
                                                                }

                                                                self.translatorState = TransTranslatorStateCompleted;
                                                            }];
    } else {
        NSError *error = [self errorWithCode:TransTranslatorErrorMissingCredentials
                                 description:@"missing Google credentials"];
        completion(error, nil, nil);

        self.translatorState = TransTranslatorStateCompleted;
    }
}

#pragma mark - Helpers

- (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description {
    NSDictionary *userInfo = nil;
    if (description)
        userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey];

    return [NSError errorWithDomain:TRANS_TRANSLATOR_ERROR_DOMAIN code:code userInfo:userInfo];
}

// massage languge code to make Google Translate happy
- (NSString *)filteredLanguageCodeFromCode:(NSString *)code {
    if (!code || code.length <= 3)
        return code;

    if ([code isEqualToString:@"zh-Hant"] || [code isEqualToString:@"zh-TW"])
        return @"zh-TW";
    else if ([code hasSuffix:@"input"])
        // use phone's default language if crazy (keyboard) inputs are detected
        return [[NSLocale preferredLanguages] objectAtIndex:0];
    else
        // trim stuff like en-GB to just en which Google Translate understands
        return [code substringToIndex:2];
}

- (void)handleError:(NSError *)error {
    if (self.completionHandler) {
        error.code == TransTranslatorErrorUnableToTranslate;
        self.completionHandler(error, nil, nil);
    }
}

- (void)handleSuccessWithOriginal:(NSString *)original
                translatedMessage:(NSString *)translatedMessage
                   detectedSource:(NSString *)detectedSource {
    if ([self isTranslated:translatedMessage sameAsOriginal:original]) {
        NSError *fgError = [self errorWithCode:TransTranslatorErrorUnableToTranslate
                                   description:@"unable to translate"];
        if (self.completionHandler)
            self.completionHandler(fgError, nil, nil);
    } else {
        self.completionHandler(nil, translatedMessage, detectedSource);
        [self cacheText:original translated:translatedMessage source:detectedSource];
    }
}

- (BOOL)isTranslated:(NSString *)translated sameAsOriginal:(NSString *)original {
    if (!translated || !original)
        return NO;

    NSString *t = [translated stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *o = [original stringByReplacingOccurrencesOfString:@" " withString:@""];

    return [t caseInsensitiveCompare:o] == NSOrderedSame;
}

#pragma mark - Cache

+ (NSCache *)translationCache {
    static dispatch_once_t pred = 0;
    __strong static NSCache *translationCache = nil;
    dispatch_once(&pred, ^{
        translationCache = [[NSCache alloc] init];
    });
    return translationCache;
}

- (void)cacheText:(NSString *)text translated:(NSString *)translated source:(NSString *)source {
    if (!text || !translated)
        return;

    NSMutableDictionary *cached = [NSMutableDictionary new];
    [cached setObject:translated forKey:@"txt"];
    if (source)
        [cached setObject:source forKey:@"src"];

    [[TransTranslator translationCache] setObject:cached forKey:text];
}


@end
