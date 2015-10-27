//
//  Utils.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+(void) addDefaultGradientToView: (UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    UIColor *topColor = [UIColor colorWithRed:(14.0f/255.0)
                                       green:(102.0f/255.0)
                                        blue:(143.0f/255.0)
                                       alpha:1.0f];
    UIColor *bottomColor = [UIColor colorWithRed:(117.0f/255.0)
                                       green:(214.0f/255.0)
                                        blue:(255.0f/255.0)
                                       alpha:1.0f];
    gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
}

+ (UIColor *)defaultColor {
    return [UIColor colorWithRed:(14.0f/255.0)
                           green:(102.0f/255.0)
                            blue:(143.0f/255.0)
                           alpha:1.0f];
//    return [UIColor colorWithRed:(2.0f/255.0)
//                           green:(160.0f/255.0)
//                            blue:(175.0f/255.0)
//                           alpha:1.0f];
//        return [UIColor colorWithRed:(66.0f/255.0)
//                               green:(152.0f/255.0)
//                                blue:(195.0f/255.0)
//                               alpha:.9f];
}

+ (UIColor *)defaultLightColor {
    return [UIColor colorWithRed:(117.0f/255.0)
                           green:(214.0f/255.0)
                            blue:(255.0f/255.0)
                           alpha:1.0f];
//    return [UIColor colorWithRed:(72.0f/255.0)
//                           green:(183.0f/255.0)
//                            blue:(193.0f/255.0)
//                           alpha:1.0f];
    //        return [UIColor colorWithRed:(66.0f/255.0)
    //                               green:(152.0f/255.0)
    //                                blue:(195.0f/255.0)
    //                               alpha:.9f];
}


+(UIColor *) mpgColor {
    return [UIColor colorWithRed:(255.0f/255.0)
                           green:(173.0f/255.0)
                            blue:(0.0f/255.0)
                           alpha:1.0f];
}

+(UIColor *) mpgLightColor {
    return [UIColor colorWithRed:(255.0f/255.0)
                           green:(203.0f/255.0)
                            blue:(93.0f/255.0)
                           alpha:1.0f];
}

+(UIColor *) gasColor {
    return [UIColor colorWithRed:(255.0f/255.0)
                           green:(13.0f/255.0)
                            blue:(0.0f/255.0)
                           alpha:1.0f];
}

+(UIColor *) gasLightColor {
    return [UIColor colorWithRed:(255.0f/255.0)
                           green:(101.0f/255.0)
                            blue:(93.0f/255.0)
                           alpha:1.0f];
}

+(NSAttributedString *)defaultString: (NSString *)string size: (CGFloat)size color: (UIColor *)color{
    UIFont *font = [UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:size];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:@[font, color]
                                                                forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];
    return [[NSAttributedString alloc] initWithString:string attributes:attrsDictionary];
}

@end
