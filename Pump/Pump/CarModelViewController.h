//
//  CarModelViewController.h
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarModelViewController;

@protocol CarModelViewControllerDelegate <NSObject>
@optional
- (void) carModelViewController: (CarModelViewController *)controller didFindMPG: (NSNumber *)mpg;
- (void) couldNotFindMPGForCarModelViewController: (CarModelViewController *)controller;
@end

@interface CarModelViewController : UIViewController<NSXMLParserDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property id <CarModelViewControllerDelegate> delegate;
@property (nonatomic) NSString *year;
@property (nonatomic) NSString *make;
@end
