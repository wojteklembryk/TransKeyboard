//
//  KeyboardViewController.m
//  TransKeyboard
//
//  Created by Pawel Ferens on 15/11/14.
//  Copyright (c) 2014 Pawel Ferens. All rights reserved.
//

#import "KeyboardViewController.h"

@interface KeyboardViewController ()
@end

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad {
    [super viewDidLoad];

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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self drawRowWithArray:@[@"1", @"2",@"3", @"4", @"5", @"6",@"7" ,@"8" ,@"9" ,@"0", @"<-"] andRowNumber:0];
    [self drawRowWithArray:@[@"Q", @"W",@"E", @"R", @"T", @"Y",@"U" ,@"I" ,@"O" ,@"P"] andRowNumber:1];
    [self drawRowWithArray:@[@"A", @"S",@"D", @"F", @"G", @"H",@"J" ,@"K" ,@"L"] andRowNumber:2];
    [self drawRowWithArray:@[@"SW", @"Z", @"X",@"C", @"V", @"B", @"N",@"M"] andRowNumber:3];
    [self drawRowWithArray:@[@"SPACE"] andRowNumber:4];

 
}

- (void)drawRowWithArray:(NSArray *)array
            andRowNumber:(int)row
{
    CGFloat buttonWidth = self.view.frame.size.width / array.count;
    __block CGFloat position = 0;

    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *b = [self getButtonFromString:(NSString *)obj];
        b.frame = CGRectMake(position, (self.view.frame.size.height - 175) + row * 35, buttonWidth, 35);
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
    }
    else {
        [self.textDocumentProxy insertText:sender.titleLabel.text];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
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
