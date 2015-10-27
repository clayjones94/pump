//
//  HomeViewController.m
//  Pump
//
//  Created by Clay Jones on 10/24/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "HomeViewController.h"
#import "ProfileFriendTableViewCell.h"
#import "Utils.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "TripViewController.h"
#import "BorrowTripViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TripHistoryViewController.h"
#import <Parse/Parse.h>
#import "TripManager.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
NSArray *_viewcontrollers;
UIViewController *_currentvc;
BOOL needRefresh;
    UIButton *_cancelButton;
    UIButton *_profileButton;
}

@synthesize segmentedControl = _segmentedControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    _profileButton = [[UIButton alloc] init];
    [_profileButton setBackgroundImage:[UIImage imageNamed:@"User Male Filled-25"] forState:UIControlStateNormal];
    [_profileButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_profileButton addTarget:self action:@selector(profileSelected) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: _profileButton];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [_cancelButton addTarget:self action:@selector(discardTrip) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *settingsButton = [[UIButton alloc] init];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"Settings Filled-25"] forState:UIControlStateNormal];
    [settingsButton setFrame:CGRectMake(0, 0, 25, 25)];
    [settingsButton addTarget:self action:@selector(settingsSelected) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: settingsButton];
    
    
    [self addSegmentedControlSubviews];
    
    
    TripViewController *vc1 = [TripViewController new];
    vc1 setUser
    BorrowTripViewController *vc2 = [BorrowTripViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc2];
    [nav setNavigationBarHidden:YES];
    
    _viewcontrollers = [[NSArray alloc] initWithObjects:vc1, nav, nil];
    
    [((UIViewController *)vc1).view setFrame:CGRectMake(0, _segmentedControl.frame.size.height, self.view.frame.size.width,
                                  self.view.frame.size.height - _segmentedControl.frame.size.height)];
    //((TripViewController *)vc1).parentVC = self;
    [self addChildViewController:(UIViewController *)vc1];
    [self.view addSubview:((UIViewController *)vc1).view];
    [(UIViewController *)vc1 didMoveToParentViewController:self];
    _currentvc = (UIViewController *)vc1;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) {
        [[TripManager sharedManager] setStatus:PENDING];
        LoginViewController *loginvc = [LoginViewController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginvc];
        [self presentViewController:nav animated:YES completion:nil];
        [nav setNavigationBarHidden:YES];
    }
}

- (void)addSegmentedControlSubviews {
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"My Car", @"Other Car"]];
    [_segmentedControl setFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue) forControlEvents:UIControlEventValueChanged];
    NSDictionary *titleTextAttr = @{
                                    NSFontAttributeName:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16],
                                    NSForegroundColorAttributeName: [UIColor lightGrayColor]
                                    };
    NSDictionary *selectedTitleTextAttr = @{
                                            NSFontAttributeName:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16],
                                            NSForegroundColorAttributeName:[[Utils defaultColor] colorWithAlphaComponent:0.9f]
                                            };
    
    _segmentedControl.titleTextAttributes = titleTextAttr;
    _segmentedControl.selectedTitleTextAttributes = selectedTitleTextAttr;
    _segmentedControl.selectionIndicatorColor = [Utils defaultColor];
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    _segmentedControl.selectionIndicatorHeight = 2.0f;
    _segmentedControl.borderType = HMSegmentedControlBorderTypeBottom;
    _segmentedControl.borderWidth = 0.5f;
    _segmentedControl.borderColor = [UIColor lightGrayColor];
    [self.view addSubview:_segmentedControl];
}

- (void)displayViewController:(UIViewController *)vc {
    if (vc == _currentvc) {
        return;
    }
    
    [vc.view setFrame:CGRectMake(0, _segmentedControl.frame.size.height, self.view.frame.size.width,
                                 self.view.frame.size.height - _segmentedControl.frame.size.height)];
    [_currentvc willMoveToParentViewController:nil];
    [self addChildViewController:vc];
    
    [self transitionFromViewController:_currentvc
                      toViewController:vc
                              duration:0.0f
                               options:UIViewAnimationOptionLayoutSubviews
                            animations:^{}
                            completion:^(BOOL finished) {
                                [_currentvc removeFromParentViewController];
                                [vc didMoveToParentViewController:self];
                                _currentvc = vc;
                            }];
}

- (void)segmentedControlChangedValue {
    [self displayViewController:_viewcontrollers[_segmentedControl.selectedSegmentIndex]];
}

-(void) settingsSelected {
    SettingsViewController *settingsVC = [SettingsViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [nav.navigationBar setBackgroundColor:[Utils defaultColor]];
    [nav.navigationBar setBarTintColor:[Utils defaultColor]];
    [nav.navigationBar setTintColor:[Utils defaultColor]];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self presentViewController:nav animated:YES completion:nil];
}

-(void) showHistory {
//    if (!_tripHistoryVC) {
//        _tripHistoryVC = [TripHistoryViewController new];
//    }
//    [self.navigationController pushViewController:_tripHistoryVC animated:YES];
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
