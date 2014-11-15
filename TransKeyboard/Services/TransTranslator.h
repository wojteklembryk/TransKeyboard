/*
 * Copyright (c) 2014 Pawel Ferens. All rights reserved.
 */
#import <Foundation/Foundation.h>


/**
 * Error domain for TransTranslator errors.
 */
typedef NSInteger TransTranslatorError;

/**
 * TransTranslator specific error
 */
enum TransTranslatorError {
    TransTranslatorErrorUnableToTranslate = 0,
    TransTranslatorErrorNetworkError = 1,
    TransTranslatorErrorSame = 2,
    TransTranslatorErrorTranslationInProgress = 3,
    TransTranslatorErrorAlreadyTranslated = 4,
    TransTranslatorErrorMissingCredentials = 5
};

extern float const TransTranslatorUnknownConfidence;

@interface TransTranslator : NSObject

typedef void (^TransTranslatorCompletionHandler)(NSError *error, NSString *translatedText, NSString *sourceLanguage);

@property(nonatomic, readonly) NSString *googleAPIKey;

- (id)initWithGoogleAPIKey:(NSString *)key;

- (void)translateText:(NSString *)textToTranslate
           withSource:(NSString *)sourceLanguage
               target:(NSString *)targetLanguage
           completion:(TransTranslatorCompletionHandler)completion;

@end
