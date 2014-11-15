//
//  KeyboardViewController.m
//  TransKeyboard
//
//  Created by Pawel Ferens on 15/11/14.
//  Copyright (c) 2014 Pawel Ferens. All rights reserved.
//

#import "KeyboardViewController.h"
#import "TransTranslator.h"

@interface KeyboardViewController ()
@property (nonatomic, copy) NSString *lastWord;
@property (nonatomic) NSRange rangeOfLastWord;
@property (nonatomic ,strong) UIButton *translatedTextButton;
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];

    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.translatedTextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.translatedTextButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.translatedTextButton];
    
    self.translatedTextButton.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, 40);
    self.translatedTextButton.titleLabel.font = [UIFont systemFontOfSize:20];
    self.translatedTextButton.tintColor = [UIColor blackColor];
    [self.translatedTextButton addTarget:self action:@selector(replaceLastWordWithTranslatedWord:) forControlEvents:UIControlEventTouchUpInside];
    
    [self drawRowWithArray:@[@"1", @"2",@"3", @"4", @"5", @"6",@"7" ,@"8" ,@"9" ,@"0", @"<-"] andRowNumber:0];
    [self drawRowWithArray:@[@"Q", @"W",@"E", @"R", @"T", @"Y",@"U" ,@"I" ,@"O" ,@"P"] andRowNumber:1];
    [self drawRowWithArray:@[@"A", @"S",@"D", @"F", @"G", @"H",@"J" ,@"K" ,@"L"] andRowNumber:2];
    [self drawRowWithArray:@[@"SW", @"Z", @"X",@"C", @"V", @"B", @"N",@"M"] andRowNumber:3];
    [self drawRowWithArray:@[@"SPACE"] andRowNumber:4];

}

- (UIButton *)getButtonFromString:(NSString *)string
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    button.tintColor = [UIColor blackColor];
    [button setTitle:string forState:UIControlStateNormal];
    if ([string isEqualToString:@"SW"]) {
        [button addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    return button;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)drawRowWithArray:(NSArray *)array
            andRowNumber:(int)row
{
    CGFloat buttonWidth = [[UIScreen mainScreen] applicationFrame].size.width / array.count;
    __block CGFloat position = 0;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *b = [self getButtonFromString:(NSString *)obj];
        b.frame = CGRectMake(position,40 + row * 35, buttonWidth, 35);
        position +=buttonWidth;
        [self.view addSubview:b];
    }];
}
- (void)buttonTapped:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"<-"]) {
        [self.textDocumentProxy deleteBackward];
    }
    else if ([sender.titleLabel.text isEqualToString:@"SPACE"]) {
        [self.textDocumentProxy insertText:@" "];
        [self findLastWordFromText:self.textDocumentProxy.documentContextBeforeInput];
        [self translateText:[self.lastWord lowercaseString]];
    }
    else {
        [self.textDocumentProxy insertText:[sender.titleLabel.text lowercaseString]];
    }
    

    NSLog(@"%@", self.lastWord);
}

- (void)findLastWordFromText:(NSString *)text
{
    __weak typeof (self) weakSelf = self;
    [text enumerateSubstringsInRange:NSMakeRange(0, [text length]) options:NSStringEnumerationByWords | NSStringEnumerationReverse usingBlock:^(NSString *substring, NSRange subrange, NSRange enclosingRange, BOOL *stop) {
        typeof (weakSelf) strongSelf = weakSelf;
        strongSelf.lastWord = substring;
        strongSelf.rangeOfLastWord = NSMakeRange(enclosingRange.location, enclosingRange.length);
        *stop = YES;
    }];
}

- (void)translateText:(NSString *)text {
    TransTranslator *translator = [[TransTranslator alloc] initWithGoogleAPIKey:@"AIzaSyCtp1w5z9xuf8TuXj0IRy328iHh8M5PpEM"];
    
    [translator translateText:text withSource:@"pl" target:@"en"
                   completion:^(NSError *error, NSString *translated, NSString *sourceLanguage) {
                       if (error) {
                           NSLog(@"DUPA\n%@", error);
                       } else {
                           NSLog(@"%@ %@", translated, sourceLanguage);
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [self.translatedTextButton setTitle:translated forState:UIControlStateNormal];
                           });
                       }
                   }];
}

- (void)replaceLastWordWithTranslatedWord:(UIButton *)sender
{
    for (int i = 0; i < self.rangeOfLastWord.length; i++) {
        [self.textDocumentProxy deleteBackward];
    }
    
    [self.textDocumentProxy insertText:sender.titleLabel.text];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
}

@end
