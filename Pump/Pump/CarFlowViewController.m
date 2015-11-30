//
//  CarFlowViewController.m
//  en
//
//  Created by Clay Jones on 11/18/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "CarFlowViewController.h"
#import "Utils.h"

@implementation CarFlowViewController {
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setBarTintColor:[Utils defaultColor]];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
}

-(instancetype)init {
    return [super initWithRootViewController:[CarYearViewController new]];
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    if ([viewController isKindOfClass:[CarModelViewController class]]) {
        ((CarModelViewController *)viewController).delegate = self;
    }
}

-(void)carModelViewController:(CarModelViewController *)controller didFindMPG:(NSNumber *)mpg {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.flowDelegate carFlowViewController:self didFindMPG:mpg];
    }];
}

-(void)couldNotFindMPGForCarModelViewController:(CarModelViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.flowDelegate couldNotFindMPGForCarFlowViewController:self];
    }];
}

@end
