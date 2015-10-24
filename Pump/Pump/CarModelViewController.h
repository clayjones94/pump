//
//  CarModelViewController.h
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarModelViewController : UIViewController<NSXMLParserDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSString *year;
@property (nonatomic) NSString *make;
@end
