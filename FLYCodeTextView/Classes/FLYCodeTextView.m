//
//  FLYCodeTextView.m
//  ZTTextField_Example
//
//  Created by trs on 2019/6/4.
//  Copyright © 2019 hfzdeyx@163.com. All rights reserved.
//

#import "FLYCodeTextView.h"

#define ZTBaseTag 10000
@interface FLYCodeTextView()

// 小textField之间的间隙
@property (nonatomic, assign) CGFloat space;
// 小textField的个数 (用textfield的目的是为了拓展光标功能)
@property (nonatomic, assign) NSInteger textNum;
// 隐藏的textField
@property (nonatomic, strong) UITextField *carNumTextField;
// 是否为密码型
@property (nonatomic, assign) BOOL isSecureTextEntry;
@property(nonatomic,strong)NSMutableArray <CAShapeLayer *> * lines;

@end

@implementation FLYCodeTextView

- (instancetype)initWithFrame:(CGRect)frame textNum:(NSInteger)num space:(CGFloat)space isSecure:(BOOL)isSecureTextEntry {
    
    if (self = [super initWithFrame:frame]) {
        self.space = space;
        self.textNum = num;
        _cornerRadius = 6;
        _font = [UIFont systemFontOfSize:15];
        _borderColor = [UIColor blackColor];
        _borderWidth = 1;
        _textColor = [UIColor blackColor];
        _isSecureTextEntry = isSecureTextEntry;
        [self createUI];
        [self addMethod];
    }
    return self;
}

- (NSString *)text {
    return self.carNumTextField.text;
}

#pragma mark--创建UI
- (void)createUI {
    
    //创建隐藏的textField
    [self createCarNumTextField];
    //创建小的textField
    [self createTextFields];
}

- (void)createTextFields {
    
    CGFloat textW = (self.frame.size.width - self.space * (self.textNum - 1)) * 1.0 / self.textNum;
    CGFloat textH = CGRectGetHeight(self.frame);
    textW = (textW < 0) ? 0 : textW;
    
    // 创建text field
    for (NSInteger i=0; i<self.textNum; i++) {
        UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(i * (textW + self.space), 0, textW, textH)];
        [self addSubview:textField];
        textField.secureTextEntry = self.isSecureTextEntry;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.tag = ZTBaseTag + i;
        textField.enabled = NO;
        textField.layer.cornerRadius = self.cornerRadius;
        textField.font = self.font;
        
        if (i < self.placeHolder.length) {
            textField.placeholder = [self.placeHolder substringWithRange:NSMakeRange(i, 1)];
        }
        
        textField.layer.borderColor = self.borderColor.CGColor;
        textField.layer.borderWidth = self.borderWidth;
        textField.textColor = self.textColor;
        
        //光标
        CGFloat lineH = 30;
        CGFloat lineTop = 10;
        if (lineH > (textH - 2 * lineTop)) {
            lineH = (textH - 2 * lineTop);
        }
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(textW / 2, lineTop, 2, lineH)];
        CAShapeLayer *line = [CAShapeLayer layer];
        line.path = path.CGPath;
        line.fillColor =  [UIColor darkGrayColor].CGColor;
        [textField.layer addSublayer:line];
        if (i == 0) {
            [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
            //高亮颜色
            line.hidden = NO;
        }else {
            line.hidden = YES;
        }
        //把光标对象和label对象装进数组
        [self.lines addObject:line];
    }
}

- (void)createCarNumTextField {
    self.carNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.carNumTextField];
    self.carNumTextField.hidden = YES;
    self.carNumTextField.keyboardType = UIKeyboardTypeNumberPad;
}

#pragma mark--添加方法
-(void)addMethod{
    // 监听文本框变化
    [self.carNumTextField addTarget:self
                             action:@selector(carNumTextFieldChange:)
                   forControlEvents:UIControlEventEditingChanged];
    
    //添加tap手势，textFields
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(textFieldsBecomeFirstResponder)];
    [self addGestureRecognizer:tap];
}

#pragma mark--内部方法实现
- (void)textFieldsBecomeFirstResponder {
    [self.carNumTextField becomeFirstResponder];
}

-(void)carNumTextFieldChange:(UITextField *)textField{
    
    if (textField.text.length >= self.textNum) {
        textField.text = [textField.text substringToIndex:self.textNum];
        [self.carNumTextField resignFirstResponder];
    }
    for (NSInteger i=0; i < self.textNum; i++) {
        
        UITextField *textField1 = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        textField1.text = @"";
        if (i < textField.text.length) {
            textField1.text = [textField.text substringWithRange:NSMakeRange(i, 1)];
        }
        
        NSString *verStr = textField.text;
        if (i < verStr.length) {
            [self changeViewLayerIndex:i linesHidden:YES];
        }else {
            [self changeViewLayerIndex:i linesHidden:i == verStr.length ? NO : YES];
            //textView的text为空的时候
            if (!verStr && verStr.length == 0) {
                [self changeViewLayerIndex:0 linesHidden:NO];
            }
        }
    }
}

//闪动动画
- (CABasicAnimation *)opacityAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.9;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return opacityAnimation;
}

//设置光标显示隐藏
- (void)changeViewLayerIndex:(NSInteger)index linesHidden:(BOOL)hidden {
    CAShapeLayer *line = self.lines[index];
    if (hidden) {
        [line removeAnimationForKey:@"kOpacityAnimation"];
    }else{
        [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
    }
    [UIView animateWithDuration:0.25 animations:^{
        line.hidden = hidden;
    }];
}

#pragma mark--外部方法的实现
- (void)becomeFirstResponder {
    [self textFieldsBecomeFirstResponder];
}

- (void)resignFirstResponder {
    [self.carNumTextField resignFirstResponder];
}

#pragma mark--属性赋值
//对象初始化
- (NSMutableArray *)lines {
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    for (NSInteger i=0; i < self.textNum; i++) {
        UITextField *textField = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        textField.layer.cornerRadius = cornerRadius;
    }
}

- (void)setFont:(UIFont *)font {
    for (NSInteger i=0; i < self.textNum; i++) {
        UITextField *textField = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        textField.font = font;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    for (NSInteger i=0; i < self.textNum; i++) {
        UITextField *textField = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        if (i < placeHolder.length) {
            textField.placeholder = [placeHolder substringWithRange:NSMakeRange(i, 1)];
        }
    }
}

- (void)setBorderColor:(UIColor *)borderColor {
    for (NSInteger i=0; i < self.textNum; i++) {
        UITextField *textField = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        textField.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    for (NSInteger i=0; i < self.textNum; i++) {
        UITextField *textField = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        textField.layer.borderWidth = borderWidth;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    for (NSInteger i=0; i < self.textNum; i++) {
        UITextField *textField = (UITextField *)[self viewWithTag:ZTBaseTag + i];
        textField.textColor = textColor;
    }
}

#pragma mark--重写touchesBegagn方法，防止和外部点击事件冲突
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}


@end
