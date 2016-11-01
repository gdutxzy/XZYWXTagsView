//
//  UIColor+Category.h
//  iBazi
//
//  Created by jerry on 15/9/6.
//  Copyright (c) 2015年 jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Category)

+(UIColor *)stringToColor:(NSString *)str;

/// example :  hex -> 0xaef1b3
+(UIColor *)colorFromHex:(NSUInteger )hex;
@end
