//
//  XZYTagsView.m
//  iBazi
//
//  Created by jimmyXie on 15/12/9.
//  Copyright (c) 2015年 jerry. All rights reserved.
//

#import "XZYTagsView.h"
#import "UIView+Category.h"
#import "UIColor+Category.h"


#define TagsmaxtopScrollviewHeight 130
#define TagsbuttonHeight  28
#define TagsneedMoreWidth 20
#define TagsYdistance    38
#define TagsXdistance    10



@implementation XZYTextField
- (void)deleteBackward{
    [super deleteBackward];
    if ([self.XZYDelegate respondsToSelector:@selector(deleteBackwardClick)]) {
        [self.XZYDelegate deleteBackwardClick];
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectMake(10, bounds.origin.y, bounds.size.width-20, bounds.size.height);
}

- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectMake(10, bounds.origin.y, bounds.size.width-30, bounds.size.height);
}

@end


@implementation XZYTagsTopButton
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (NSUInteger)hash{
    return (NSUInteger)self;
}
- (BOOL)isEqual:(id)object{
    return self == object;
}
- (instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor colorWithRed:49/256.0 green:163/256.0 blue:53/256.0 alpha:1] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setBackgroundImage:[[UIImage imageNamed:@"biaoqian_back"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateNormal];
        [self setBackgroundImage:[[UIImage imageNamed:@"biaoqian_back_on"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateSelected];
        [self sizeToFit];
        CGRect rect = self.bounds;
        rect.size.height = TagsbuttonHeight;
        rect.size.width += TagsneedMoreWidth;
        self.bounds = rect;
        [self addTarget:self action:@selector(buttonclick:) forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillHide:) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
    return self;
}

- (void)buttonclick:(UIButton *)button{
    button.selected = !button.selected;
    if (button.selected) {
        if (self.menu == nil) {
            self.menu = [UIMenuController sharedMenuController];
            UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleCommentMenu)];
            self.menu.menuItems = @[item1];
        }
        
        [self.menu setTargetRect:self.bounds inView:self];
        [self becomeFirstResponder];
        [self.menu setMenuVisible:YES animated:YES];
    }else{
        [self.menu setMenuVisible:NO animated:YES];
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(deleCommentMenu)) {
        return YES;
    }
    return NO;
}

- (void)deleCommentMenu{
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)menuWillHide:(NSNotification *)noti{
    self.selected = NO;
}
@end







@interface XZYTagsView ()<UITextFieldDelegate,XZYTextFieldDelegate>
{
    CGFloat _topViewY;
    CGFloat _topViewX;
}
@property (strong,nonatomic) UIScrollView * topScrollview;
@property (strong,nonatomic) UIScrollView * bottomScrollview;
@property (strong,nonatomic) UIView * line;
@property (strong,nonatomic) XZYTextField * mtextfield;
@property (assign,nonatomic) BOOL showKeyboard;
@property (strong,nonatomic) CAShapeLayer * myShapelayer;
@property (strong,nonatomic) NSMutableArray * buttonArry;
@property (strong,nonatomic) UIButton * glbutton;
@end

@implementation XZYTagsView
- (void)dealloc{
    //    [self.topScrollview removeObserver:self forKeyPath:@"bounds"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.topScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 45)];
        self.topScrollview.contentSize = self.topScrollview.frame.size;
        self.topScrollview.alwaysBounceVertical = YES;
        self.topScrollview.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.topScrollview];
        
        self.bottomScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 45, frame.size.width, frame.size.height - 45)];
        self.bottomScrollview.contentSize = self.bottomScrollview.frame.size;
        self.bottomScrollview.alwaysBounceVertical = YES;
        self.bottomScrollview.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self addSubview:self.bottomScrollview];
        self.bottomScrollview.backgroundColor = [UIColor stringToColor:@"#f0eff3"];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 13, 200, 15)];
        label.text = @"所有标签";
        label.tag = -1;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:118/256.0 green:118/256.0 blue:118/256.0 alpha:1];
        [self.bottomScrollview addSubview:label];
        
        self.line = [[UIView alloc]initWithFrame:CGRectMake(0, self.topScrollview.frame.size.height-0.5, SCREEN_WIDTH, 0.5)];
        [self addSubview:self.line];
        self.line.backgroundColor = [UIColor stringToColor:@"#d8d7da"];
        self.glbutton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.glbutton setFrame:CGRectMake(frame.size.width - 90, 13,80 , 20)];
        [self.glbutton setTitle:@"管理标签" forState:UIControlStateNormal];
        self.glbutton.layer.borderWidth = 1;
        self.glbutton.layer.borderColor = [UIColor greenColor].CGColor;
        self.glbutton.layer.cornerRadius = self.glbutton.frame.size.height/2.0;
        self.glbutton.clipsToBounds = YES;
        self.glbutton.backgroundColor = [UIColor whiteColor];
        self.glbutton.tag = -1;
        [self.glbutton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [self.glbutton setTitleColor:[UIColor colorWithRed:118/256.0 green:118/256.0 blue:118/256.0 alpha:1] forState:UIControlStateNormal];
        [self.glbutton addTarget:self action:@selector(manageButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomScrollview addSubview:self.glbutton];
        
        //        [self.topScrollview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:@"topScrollviewframe"];
        
        self.addTagNames = [NSMutableArray array];
        _hasChange = NO;
        _showKeyboard = YES;
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureTopScrollviewClick)];
        [self.topScrollview addGestureRecognizer:tap];
    }
    return self;
}

- (void)manageButtonClick{
    if ([self.delegate respondsToSelector:@selector(XZYTagsViewTagsManageButtonClick)]) {
        [self.delegate XZYTagsViewTagsManageButtonClick];
    }
}
- (void)tapGestureTopScrollviewClick{
    if (self.showKeyboard) {
        [self.mtextfield becomeFirstResponder];
    }else{
        [self textFieldShouldReturn:self.mtextfield];
        [self.mtextfield resignFirstResponder];
    }
    
}
//// 当topScrollview 的frame 变化时，bottomScrollview要跟着变
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if (context == @"topScrollviewframe") {
//        CGFloat yPosition = self.topScrollview.bounds.size.height ;
//        self.bottomScrollview.frame = CGRectMake(0, yPosition , self.frame.size.width, self.frame.size.height - yPosition);
//        self.line.y = self.topScrollview.height - 0.5;
//    }
//
//}





- (void)updateAllTagsIdnamesDicUI{
    for (UIView * view  in self.bottomScrollview.subviews) {
        if (view.tag < 0) {
            continue;
        }
        [view removeFromSuperview];
    }
    CGFloat widthMax = SCREEN_WIDTH - TagsXdistance;
    CGFloat y = 40;
    CGFloat x = TagsXdistance;
    for (NSString * key  in self.tagsIdNamesDic.allKeys) {
        NSString * name = [self.tagsIdNamesDic objectForKey:key];
        UIButton * button = [self makeBottomButtonID:key name:name];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"self MATCHES %@",key];
        NSArray * arry = [self.tagIdsArry filteredArrayUsingPredicate:predicate];
        if (arry.count > 0) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
        
        CGRect rect = button.frame;
        if (x + button.width > widthMax) {
            rect.origin.x = TagsXdistance;
            rect.origin.y = y + TagsYdistance;
        }else{
            rect.origin.x = x;
            rect.origin.y = y;
        }
        
        x = rect.origin.x + button.width + TagsXdistance;
        y = rect.origin.y ;
        
        button.frame = rect;
        
        [self.bottomScrollview addSubview:button];
        
    }
    
    
    
    
    if (y + 100 > self.bottomScrollview.contentSize.height) {
        self.bottomScrollview.contentSize = CGSizeMake(self.bottomScrollview.width, y + 100);
    }
    if (self.hiddenEdit) {
        [self.glbutton setHidden:YES];
    }
}

- (NSMutableArray *)lastTagIdsArry{
    NSMutableArray * tagarry = [NSMutableArray array];
    NSMutableDictionary * nameKeyDic = [NSMutableDictionary dictionary];
    for (NSString  * key  in self.tagsIdNamesDic.allKeys) {
        NSString * name = [self.tagsIdNamesDic objectForKey:key];
        if (name.length > 0) {
            [nameKeyDic setObject:key forKey:name];
        }
    }
    for (NSString * str in self.tagNamesArry) {
        NSString * Id = [nameKeyDic objectForKey:str];
        if (Id.length > 0) {
            [tagarry addObject:Id];
        }
    }
    return tagarry;
}

- (NSMutableArray *)tagNamesArry{
    if (self.buttonArry == nil) {
        return _tagNamesArry;
    }
    NSMutableArray * namesArry = [NSMutableArray array];
    for (UIButton * button in self.buttonArry) {
        NSString * name = button.titleLabel.text;
        if (name.length > 0) {
            [namesArry addObject:name];
        }
    }
    return namesArry;
}

- (void)updateTopTagsUI{
    if (self.buttonArry == nil) {
        NSMutableArray * namesarry = [NSMutableArray array];
        if (self.tagIdsArry == nil) {
            namesarry = [NSMutableArray arrayWithArray:self.tagNamesArry];
        }else{
            for (NSString * key  in self.tagIdsArry) {
                NSString * name = [self.tagsIdNamesDic objectForKey:key];
                if (name.length > 0) {
                    [namesarry addObject:name];
                }
            }
        }
        self.buttonArry = [NSMutableArray array];
        for (NSString * name  in namesarry) {
            [self addOneTopButtonTitle:name];
        }
        
    }
    
    CGFloat widthMax = SCREEN_WIDTH - TagsXdistance;

    _topViewY = 10;
    _topViewX = TagsXdistance;
    for (UIButton * button  in self.buttonArry) {
        [button removeFromSuperview];
        button.selected = NO;
        CGRect rect = button.frame;
        if (_topViewX + button.width > widthMax) {
            rect.origin.x = TagsXdistance;
            rect.origin.y = _topViewY + TagsYdistance;
        }else{
            rect.origin.x = _topViewX;
            rect.origin.y = _topViewY;
        }
        
        _topViewX = rect.origin.x + button.width + TagsXdistance;
        _topViewY = rect.origin.y ;
        
        button.frame = rect;
        
        [self.topScrollview addSubview:button];
        
    }
    
    if (self.mtextfield == nil) {
        self.mtextfield = [[XZYTextField alloc]initWithFrame:CGRectMake(0, 0, 30, TagsbuttonHeight)];
        self.mtextfield.placeholder = @"输入标签";
        self.mtextfield.font = [UIFont systemFontOfSize:14];
        self.mtextfield.clipsToBounds = NO;
        self.mtextfield.delegate = self;
        self.mtextfield.XZYDelegate = self;
        [self.topScrollview addSubview:self.mtextfield];
        self.mtextfield.returnKeyType = UIReturnKeyDone;
        [self.mtextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    [self mtextfieldSizeTofit];
}

- (void)mtextfieldSizeTofit{
    [self.mtextfield sizeToFit];
    CGRect rect = self.mtextfield.frame;
   
    if (_topViewX + self.mtextfield.width > SCREEN_WIDTH - TagsXdistance) {
        rect.origin.x = TagsXdistance;
        rect.origin.y = _topViewY + TagsYdistance;
    }else{
        rect.origin.x = _topViewX;
        rect.origin.y = _topViewY;
    }
    if(self.hiddenEdit)
    {
        self.mtextfield.hidden = YES;
        self.mtextfield.userInteractionEnabled = NO;
        self.mtextfield.placeholder = nil;
        self.mtextfield.width = 0;
        rect.origin.x = _topViewX;
        rect.origin.y = _topViewY;

    }
    rect.size.height = TagsbuttonHeight;
    //    rect.size.width = rect.size.width + TagsneedMoreWidth;
    
    self.mtextfield.frame = rect;
    
    //输入外虚线框
    if (self.mtextfield.text.length < 1) {
        [self.myShapelayer removeFromSuperlayer];
        self.myShapelayer = nil;
    }else{
        if (self.myShapelayer == nil) {
            CAShapeLayer *line =  [CAShapeLayer layer];
            line.lineDashPattern = @[@4,@2];
            line.lineWidth = 0.5f ;
            line.strokeColor = [UIColor colorWithRed:200/256.0 green:200/256.0 blue:200/256.0 alpha:220/256.0].CGColor;
            line.fillColor = [UIColor clearColor].CGColor;
            [self.mtextfield.layer addSublayer:line];
            self.myShapelayer = line;
        }
        UIBezierPath *   path =  [UIBezierPath bezierPathWithRoundedRect:self.mtextfield.bounds cornerRadius:self.mtextfield.bounds.size.height/2.0];
        self.myShapelayer.path = path.CGPath;
        
    }
    
    
    self.topScrollview.contentSize = CGSizeMake(self.topScrollview.width, self.mtextfield.y + TagsbuttonHeight +10);
    if (self.mtextfield.y + TagsbuttonHeight < TagsmaxtopScrollviewHeight) {
        self.topScrollview.height = self.topScrollview.contentSize.height;
        
        CGFloat yPosition = self.topScrollview.bounds.size.height ;
        self.bottomScrollview.frame = CGRectMake(0, yPosition , self.frame.size.width, self.frame.size.height - yPosition);
        self.line.y = self.topScrollview.height - 0.5;
        
    }else if (self.topScrollview.frame.size.height < TagsmaxtopScrollviewHeight){
        self.topScrollview.height = TagsmaxtopScrollviewHeight;
        CGFloat yPosition = self.topScrollview.bounds.size.height ;
        self.bottomScrollview.frame = CGRectMake(0, yPosition , self.frame.size.width, self.frame.size.height - yPosition);
        self.line.y = self.topScrollview.height - 0.5;
    }
    [self.topScrollview setContentOffset:CGPointMake(0, self.topScrollview.contentSize.height - self.topScrollview.height) animated:YES];
    
}

- (UIButton *)makeBottomButtonID:(NSString *)Id name:(NSString *)name{
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 300, TagsbuttonHeight)];
    button.tag = Id.integerValue;
    [button setTitle:name forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:49/256.0 green:163/256.0 blue:53/256.0 alpha:1]forState:UIControlStateSelected];
    [button setBackgroundImage:[[UIImage imageNamed:@"biaoqian_back_normal"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:@"biaoqian_back"] stretchableImageWithLeftCapWidth:14 topCapHeight:14] forState:UIControlStateSelected];
    [button sizeToFit];
    CGRect rect = button.bounds;
    rect.size.height = TagsbuttonHeight;
    rect.size.width += TagsneedMoreWidth;
    button.bounds = rect;
    
    [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)bottomButtonClick:(UIButton *)button{
    button.selected = !button.selected;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"titleLabel.text MATCHES %@",button.titleLabel.text];
    NSArray * arry = [self.buttonArry filteredArrayUsingPredicate:predicate];
    if (button.selected) {
        if (arry.count < 1) {
            [self addOneTopButtonTitle:button.titleLabel.text];
        }
    }else{
        if (arry.count > 0) {
            UIButton * button = arry.firstObject;
            if ([button isKindOfClass:[UIButton class]]) {
                [button removeFromSuperview];
                [self.buttonArry removeObject:button];
            }
        }
    }
    [self updateTopTagsUI];
    self.hasChange = YES;
}

- (void)addOneTopButtonTitle:(NSString *)title{
    NSString * trimmedString = [title stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length < 1) {
        return;
    }
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"titleLabel.text MATCHES %@",trimmedString];
    NSArray * arry = [self.buttonArry filteredArrayUsingPredicate:predicate];
    if (arry.count > 0) {
        UIButton * button = arry.firstObject;
        [self.buttonArry removeObject:button];
        [self.buttonArry addObject:button];
        return ;
    }
    
    XZYTagsTopButton * topbutton = [[XZYTagsTopButton alloc]initWithTitle:trimmedString];
    [topbutton addTarget:self action:@selector(topButtonDele:) forControlEvents:UIControlEventValueChanged];
    [self.buttonArry addObject:topbutton];
    BOOL noSame = YES;
    for (UIButton * usbutton in self.bottomScrollview.subviews) {
        if ([usbutton isKindOfClass:[UIButton class]]) {
            if ([usbutton.titleLabel.text isEqualToString:trimmedString]) {
                usbutton.selected = YES;
                noSame = NO;
            }
        }
    }
    if (noSame) {
        if (self.addTagNames == nil) {
            self.addTagNames = [NSMutableArray array];
        }
        [self.addTagNames addObject:trimmedString];
    }
}

- (void)deleOneTopButton:(UIButton *)button{
    [self.addTagNames removeObject:button.titleLabel.text];
    self.hasChange = YES;
    [button removeFromSuperview];
    [self.buttonArry removeObject:button];
    [self updateTopTagsUI];
    for (UIButton * usbutton in self.bottomScrollview.subviews) {
        if ([usbutton isKindOfClass:[UIButton class]]) {
            if ([usbutton.titleLabel.text isEqualToString:button.titleLabel.text]) {
                usbutton.selected = NO;
            }
        }
    }
}
- (void)topButtonDele:(UIButton *)button{
    [self deleOneTopButton:button];
}


- (void)setHasChange:(BOOL)hasChange{
    _hasChange = hasChange;
    if ([self.delegate respondsToSelector:@selector(XZYTagsViewTagsValueWillChange)]) {
        [self.delegate XZYTagsViewTagsValueWillChange];
    }
}


#pragma mark - textFieldDelegate
- (void)textFieldDidChange:(UITextField *)textField{
    NSString * str = textField.text;
    if (str.length > 16) {
        str = [str substringToIndex:16];
        textField.text = str;
    }
    self.hasChange = YES;
    self.showKeyboard = NO;
    if (str.length > 0) {
        //        [self mtextfieldSizeTofit];
        [self updateTopTagsUI];
    }else{
        [self updateTopTagsUI];
        
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSString * trimmedString = [textField.text stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length < 1) {
        textField.text = nil;
    }
    NSInteger count = 0;
    for (UIButton * button in self.buttonArry) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.selected == YES) {
                count ++;
            }
        }
    }
    if (count > 1) {
        UIButton * button = self.buttonArry.lastObject;
        if ([button isKindOfClass:[UIButton class]]) {
            button.selected = NO;
        }
    }
    
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@""] && self.mtextfield.text.length == 1) {
        self.mtextfield.text = @"  ";
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self addOneTopButtonTitle:textField.text];
    self.mtextfield.text = nil;
    [self updateTopTagsUI];
    self.showKeyboard = YES;
    return YES;
}

#pragma mark - XZYTextFieldDelegate
- (void)deleteBackwardClick{
    if (self.mtextfield.text.length < 1) {
        UIButton * button = self.buttonArry.lastObject;
        if (button.selected) {
            [self deleOneTopButton:button];
        }else{
            button.selected = YES;
        }
        
    }else if([self.mtextfield.text isEqualToString:@" "]){
        self.mtextfield.text = nil;
        [self updateTopTagsUI];
    }
}

- (void)endEditTagInput{
    if (self.mtextfield.text.length > 0) {
        [self addOneTopButtonTitle:self.mtextfield.text];
    }
    [self.mtextfield removeFromSuperview];
    self.mtextfield = nil;
    [self updateTopTagsUI];
    //    [self.mtextfield resignFirstResponder];
    
}
@end
