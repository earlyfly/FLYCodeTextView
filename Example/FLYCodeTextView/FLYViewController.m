//
//  FLYViewController.m
//  FLYCodeTextView
//
//  Created by FlyW on 06/04/2019.
//  Copyright (c) 2019 FlyW. All rights reserved.
//

#import "FLYViewController.h"
#import "FLYCodeTextView.h"

@interface FLYViewController ()

@property (nonatomic, strong) FLYCodeTextView *codeTextView;

@end

@implementation FLYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //外部调用
    CGFloat space = 10;
    NSInteger num = 6;
    CGFloat width = self.view.frame.size.width - 50*2;
    CGFloat height = (width - (space * (num - 1)))/num;
    self.codeTextView = [[FLYCodeTextView alloc] initWithFrame:CGRectMake(50, 200, width, height) textNum:num space:space isSecure:NO];
    [self.view addSubview:self.codeTextView];
    //调起键盘
    [self.codeTextView becomeFirstResponder];
    //设置小文本框圆角
    self.codeTextView.cornerRadius = 4;
    //设置小文本框字体
    self.codeTextView.font = [UIFont systemFontOfSize:20];
    //设置小文本框的placeHolder。
    //self.codeTextView.placeHolder = @"";
    //设置小文本框的borderColor
    self.codeTextView.borderColor = [UIColor darkGrayColor];
    //设置小文本框的borderWidth
    self.codeTextView.borderWidth = 0.5;
    //设置小文本框的textColor
    self.codeTextView.textColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //键盘消失
    [self.codeTextView resignFirstResponder];
    NSLog(@"%@",self.codeTextView.text);
}


@end
