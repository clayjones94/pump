//
//  Utils.h
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Utils : NSObject

+ (UIColor *)defaultColor;
+ (UIColor *)defaultLightColor;
+(UIColor *) mpgColor;
+(UIColor *) mpgLightColor;
+(UIColor *) gasColor;
+(UIColor *) gasLightColor;
+(NSAttributedString *)defaultString: (NSString *)string size: (CGFloat)size color: (UIColor *)color;

@end
