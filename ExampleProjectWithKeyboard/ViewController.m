//
//  ViewController.m
//  ExampleProjectWithKeyboard
//
//  Created by Pawel Ferens on 15/11/14.
//  Copyright (c) 2014 Pawel Ferens. All rights reserved.
//

#import "ViewController.h"
#import "TransTranslator.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self translateText:@"nazwisko"];
}

- (void)translateText:(NSString *)text {
    TransTranslator *translator = [[TransTranslator alloc] initWithGoogleAPIKey:@"AIzaSyCtp1w5z9xuf8TuXj0IRy328iHh8M5PpEM"];

    [translator translateText:text withSource:@"pl" target:@"en"
                   completion:^(NSError *error, NSString *translated, NSString *sourceLanguage) {
                       if (error) {
                           NSLog(@"DUPA\n%@", error);
                       } else {
                           NSLog(@"%@ %@", translated, sourceLanguage);
                       }
                   }];
}


@end
