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
#import "FinishViewController.h"

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
    
    UIButton *settingsButton = [[UIButton alloc] init];
    [settingsButton setBackgroundImage:[UIImage imageNamed:@"Settings Filled-25"] forState:UIControlStateNormal];
    [settingsButton setFrame:CGRectMake(0, 0, 25, 25)];
    [settingsButton addTarget:self action:@selector(settingsSelected) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: settingsButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideSegment) name:@"Hide Segment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSegment) name:@"Show Segment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishTrip) name:@"Finish Trip" object:nil];
    
    [self addSegmentedControlSubviews];
    
    
    TripViewController *vc1 = [TripViewController new];
    [vc1 setUser:[PFUser currentUser]];
    BorrowTripViewController *vc2 = [BorrowTripViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc2];
    [nav setNavigationBarHidden:YES];
    
    _viewcontrollers = [[NSArray alloc] initWithObjects:vc1, nav, nil];
    
    [vc1.view setFrame:CGRectMake(0, _segmentedControl.frame.size.height, self.view.frame.size.width,
                                  self.view.frame.size.height - _segmentedControl.frame.size.height)];
    //((TripViewController *)vc1).parentVC = self;
    [self addChildViewController:vc1];
    [self.view addSubview:vc1.view];
    [vc1 didMoveToParentViewController:self];
    _currentvc = vc1;
    
}

-(void) finishTrip {
    FinishViewController *vc = [FinishViewController new];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void) hideSegment {
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_currentvc.view setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [_segmentedControl setFrame:CGRectMake(_segmentedControl.frame.origin.x, _segmentedControl.frame.origin.y - _segmentedControl.frame.size.height, _segmentedControl.frame.size.width, _segmentedControl.frame.size.height)];
    } completion:^(BOOL finished) {
        if (finished) {
            [_segmentedControl removeFromSuperview];
        }
    }];
    [UIView animateWithDuration:0 delay:.15 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    } completion:nil];
}

-(void) showSegment {
    [self.view addSubview:_segmentedControl];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [_segmentedControl setFrame:CGRectMake(_segmentedControl.frame.origin.x, 0, _segmentedControl.frame.size.width, _segmentedControl.frame.size.height)];
        [_currentvc.view setFrame:CGRectMake(0, _segmentedControl.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _segmentedControl.frame.size.height)];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    } completion:nil];
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
