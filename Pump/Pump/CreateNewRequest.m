//
//  CreateNewRequest.m
//  Pump
//
//  Created by Clay Jones on 8/30/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "CreateNewRequest.h"
#import "SearchUserView.h"
#import "Utils.h"

@implementation CreateNewRequest

-(void) viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    SearchUserView *searchView = [[SearchUserView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    
    [self.view addSubview: searchView];
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
