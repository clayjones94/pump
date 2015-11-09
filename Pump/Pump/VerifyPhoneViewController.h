//
//  VerifyPhoneViewController.h
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DecimalKeypad.h"

@interface VerifyPhoneViewController : UIViewController<DecimalKeypadDelegate, UIAlertViewDelegate>
@property (nonatomic) NSString *code;
@property (nonatomic) NSString *phoneNumber;
@end
