//
//  Database.h
//  Pump
//
//  Created by Clay Jones on 9/3/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Database : NSObject

+(void) createUserWithMPG: (NSNumber *)mpg forVenmoID: (NSString *)ven_id withBlock: (void (^)(NSDictionary *data))block ;
+(void) sendRequestType: (NSString *)type toURL: (NSString *) urlStr withData: (NSDictionary *) data withBlock:(void (^)(NSDictionary *data))block;
@end
