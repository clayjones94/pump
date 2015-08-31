//
//  Utils.m
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (UIColor *)defaultColor {
    return [UIColor colorWithRed:(2.0f/255.0)
                           green:(160.0f/255.0)
                            blue:(175.0f/255.0)
                           alpha:1.0f];
}

+(NSAttributedString *)defaultString: (NSString *)string size: (CGFloat)size color: (UIColor *)color{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjects:@[font, color]
                                                                forKeys: @[NSFontAttributeName, NSForegroundColorAttributeName]];
    return [[NSAttributedString alloc] initWithString:string attributes:attrsDictionary];
}

@end
