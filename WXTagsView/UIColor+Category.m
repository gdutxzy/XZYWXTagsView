//
//  UIColor+Category.m
//  iBazi
//
//  Created by jerry on 15/9/6.
//  Copyright (c) 2015年 jerry. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

//十六进制颜色  转换uicolor
+(UIColor *)stringToColor:(NSString *)str{
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    return color;
}


+(UIColor *)colorFromHex:(NSUInteger )hex{
    return [UIColor colorWithRed:(((hex & 0xFF0000) >> 16))/255.0 green:(((hex &0xFF00) >>8))/255.0 blue:((hex &0xFF))/255.0 alpha:1.0];
}

@end
