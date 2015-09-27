//
//  AddPassengersViewController.m
//  Pump
//
//  Created by Clay Jones on 9/15/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "AddPassengersViewController.h"
#import "Utils.h"
#import "TripManager.h"
#import "UserManager.h"

@interface AddPassengersViewController ()

@end

@implementation AddPassengersViewController

@synthesize searchView = _searchView;

-(void) viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationItem setTitle:@"Add Passengers"];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    
    _searchView = [[SearchUserView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    
    [self.view addSubview: _searchView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UserManager sharedManager].friends.count > 1) {
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray: [UserManager sharedManager].recents];
        [friends removeObjectsInArray:[TripManager sharedManager].passengers];
        [_searchView setFriends: friends];
    }
//    else {
//        [[UserManager sharedManager] updateFriendsWithBlock:^(BOOL updated){
//            NSMutableArray *friends = [[NSMutableArray alloc] initWithArray: [UserManager sharedManager].friends];
//            [friends removeObjectsInArray:[TripManager sharedManager].passengers];
//            [_searchView setFriends: friends];
//        }];
//    }
    
}

-(void) done {
    for (NSDictionary *passenger in _searchView.selectedFriends) {
        if (![[TripManager sharedManager].passengers containsObject:passenger]) {
            [[TripManager sharedManager].passengers addObject:passenger];
            [[UserManager sharedManager] addFriendToRecents:passenger];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Show Popup" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Show Popup" object:nil];
}

@end
