//
//  ViewController.m
//  WXTagsView
//
//  Created by mac on 2016/11/1.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ViewController.h"
#import "XZYTagsView.h"
#import "UIView+Category.h"

@interface ViewController ()<XZYTagsViewDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) UIButton * rightbutton;

@property (strong,nonatomic) XZYTagsView * tagsView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupTagsView];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"bt_back"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarbuttonClick)];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarbuttonClick)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:49/256.0 green:163/256.0 blue:53/256.0 alpha:1]];
}




- (void)setupTagsView{
    [self.tagsView removeFromSuperview];
    
    self.tagsView = [[XZYTagsView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
   
    self.tagsView.tagsIdNamesDic = @{@"1":@"tag1",@"4":@"tag4",@"5":@"tag5"};
    self.tagsView.tagIdsArry = @[@"1",@"5"];
    [self.tagsView updateAllTagsIdnamesDicUI];
    [self.tagsView updateTopTagsUI];
    self.tagsView.delegate = self;
    
    [self.view addSubview:self.tagsView];
}
- (void)XZYTagsViewTagsValueWillChange{
    if (self.tagsView.hasChange) {
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor greenColor]];
    }else{
        [self.navigationItem.rightBarButtonItem setTintColor:[UIColor colorWithRed:49/256.0 green:163/256.0 blue:53/256.0 alpha:1]];
    }
    
}

- (void)XZYTagsViewTagsManageButtonClick{
    

}
- (void)rightBarbuttonClick{
    if (self.tagsView.hasChange) {
        [self.tagsView endEditTagInput];
        self.tagsView->_hasChange = NO;
        
//        if (!XZYNETWORKCONNECT) {
//            [XZYCommonTools MBPropressHUDAlert:@"无网络"];
//            return;
//        }
    }
}

- (void)httpUpALLTags{
   
}
- (void)leftBarbuttonClick{
    [self.tagsView endEditTagInput];
    if (self.tagsView.hasChange) {
        
        UIAlertView * alr = [[UIAlertView alloc]initWithTitle:@"保存本次编辑?" message:nil delegate:self cancelButtonTitle:@"不保存" otherButtonTitles:@"保存", nil];
        [alr show];
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        //        [self.view endEditing:YES];
        //         [self.tagsView endEditTagInput];
        //        self.tagsView->_hasChange = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else if (buttonIndex == 1){
        [self rightBarbuttonClick];
    }
}


@end
