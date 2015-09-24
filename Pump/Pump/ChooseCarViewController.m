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

    
    UIButton *myCarButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [myCarButton setBackgroundColor:[Utils defaultColor]];
    [myCarButton setFrame:CGRectMake(self.view.frame.size.width * .1, self.view.frame.size.height * .02, self.view.frame.size.width * .8, self.view.frame.size.height * .06)];
    [myCarButton addTarget:self action:@selector(selectMyCar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myCarButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"My Car" size:20 color:[UIColor whiteColor]];
    [myCarButton.layer setCornerRadius:5];
    [myCarButton setAttributedTitle: titleString forState:UIControlStateNormal];
    
    _searchView = [[SearchUserView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * .1, self.view.frame.size.width, self.view.frame.size.height * .9)];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UserManager sharedManager].friends.count > 1) {
        NSMutableArray *friends = [[NSMutableArray alloc] initWithArray: [UserManager sharedManager].friends];
        [friends removeObjectsInArray:[TripManager sharedManager].passengers];
        [_searchView setFriends: friends];
    } else {
        [[UserManager sharedManager] updateFriendsWithBlock:^(BOOL updated){
            NSMutableArray *friends = [[NSMutableArray alloc] initWithArray: [UserManager sharedManager].friends];
            [friends removeObjectsInArray:[TripManager sharedManager].passengers];
            [_searchView setFriends: friends];
        }];
    }
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) selectMyCar {
    [TripManager sharedManager].car = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Select Car" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchView:(SearchUserView *)manager didSelectUser:(NSDictionary *)user {
    [TripManager sharedManager].car = user;
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
