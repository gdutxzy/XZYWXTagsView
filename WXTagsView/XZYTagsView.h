//
//  XZYTagsView.h
//  iBazi
//
//  Created by jimmyXie on 15/12/9.
//  Copyright (c) 2015年 jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XZYTagsViewDelegate <NSObject>

- (void)XZYTagsViewTagsValueWillChange;
- (void)XZYTagsViewTagsManageButtonClick;

@end


/**
 说明：此页面是模仿微信的个人标签页
 支持防止标签重名、单击标签显示删除、键盘删除键删除
 
 开始时，赋值tagsIdNamesDic的初值，即现有的标签，这里面包括了标签id与标签名的对应关系，如@{@"tagID":@"tagName"}
 然后赋值tagIdsArry表明这个人持有其中的哪些标签 ，例 @[@"tagID"]
 完毕。
 
*/
@interface XZYTagsView : UIView
{
 @public   BOOL _hasChange;
}
// 注：新建的标签，指的是没有id的标签名，需要先请求服务器建立标签后拿到对应id

@property (weak,nonatomic) id<XZYTagsViewDelegate> delegate;
/// 标签有可能有变动过,用来标识是否应该允许进行更改标签网络请求
@property (assign,nonatomic) BOOL hasChange;
/// 标签有可能有变动过,用来标识是否应该允许进行更改标签网络请求
@property (assign,atomic) BOOL hiddenEdit;
/// 目前所有的 tags 的id 与 标签名的对应关系
@property (strong,nonatomic) NSDictionary * tagsIdNamesDic;
/// tags 的id 数组 , 刚开始时的数据
@property (strong,nonatomic) NSArray * tagIdsArry;
/// tags 的 标签名数组 （包含"新建的标签名数组",即选中的所有标签名）
@property (strong,nonatomic) NSMutableArray * tagNamesArry;
/// 变化后 tags 的id 数组 （不包含新建的标签，因为新建标签还没有请求到对应的id）
@property (strong,nonatomic) NSMutableArray * lastTagIdsArry;
/// 新建的标签名数组
@property (strong,nonatomic) NSMutableArray * addTagNames;

/// 更新所有标签状态UI(即底部scrollview)
- (void)updateAllTagsIdnamesDicUI;
/// 更新用户的标签状态UI(即顶部scrollview)
- (void)updateTopTagsUI;

/// 给其它方法调用，使得XZYTagsView的键盘收起，textField结束编辑状态
- (void)endEditTagInput;
@end


@interface XZYTagsTopButton : UIButton
- (instancetype)initWithTitle:(NSString *)title;
// UIControlEventValueChanged 此事件是点击删除按钮事件
@property (strong,nonatomic)  UIMenuController * menu;
@end


@protocol XZYTextFieldDelegate <NSObject>
- (void)deleteBackwardClick;
@end
@interface XZYTextField : UITextField
@property (weak,nonatomic) id<XZYTextFieldDelegate> XZYDelegate;
@end