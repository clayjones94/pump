//
//  ChooseCarViewController.m
//  Pump
//
//  Created by Clay Jones on 9/18/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "ChooseCarViewController.h"
#import "SearchUserView.h"
#import "TripManager.h"
#import "Utils.h"

@interface ChooseCarViewController ()

@end

@implementation ChooseCarViewController {
    SearchUserView *_searchView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationItem setTitle:@"Select Someone's Car"];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];

    
    _searchView = [[SearchUserView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64)];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UserManager sharedManager].friends.count > 1) {
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray: [UserManager sharedManager].recents];
        [friends removeObjectsInArray:[TripManager sharedManager].passengers];
        [_searchView setFriends: friends];
    }
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Show Popup" object:nil];
}

-(void) selectMyCar {
    [TripManager sharedManager].car = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Select Car" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchView:(SearchUserView *)manager didSelectUser:(NSDictionary *)user {
    [TripManager sharedManager].car = user;
    [[UserManager sharedManager] addFriendToRecents:user];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Select Car" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
