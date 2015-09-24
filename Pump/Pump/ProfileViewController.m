//
//  ProfileViewController.m
//  Pump
//
//  Created by Clay Jones on 9/13/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "ProfileViewController.h"
#import "PendingOwnershipsViewController.h"
#import "PendingMembershipsViewController.h"
#import "ProfileFriendTableViewCell.h"
#import "Utils.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "TripsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TripHistoryViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController {
    NSArray *_viewcontrollers;
    UIViewController *_currentvc;
    TripHistoryViewController *_tripHistoryVC;
    BOOL needRefresh;
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
    
    UIButton *historyButton = [[UIButton alloc] init];
    [historyButton setBackgroundImage:[UIImage imageNamed:@"Literature Filled-25"] forState:UIControlStateNormal];
    [historyButton setFrame:CGRectMake(0, 0, 25, 25)];
    [historyButton addTarget:self action:@selector(showHistory) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: historyButton];
    
    [self addSegmentedControlSubviews];
    
    
    PendingOwnershipsViewController *vc1 = [PendingOwnershipsViewController new];
    PendingMembershipsViewController *vc2 = [PendingMembershipsViewController new];
    
    _viewcontrollers = [[NSArray alloc] initWithObjects:vc1, vc2, nil];
    
    // Init with notifications vc
    [vc1.view setFrame:CGRectMake(0, _segmentedControl.frame.size.height, self.view.frame.size.width,
                                              self.view.frame.size.height - _segmentedControl.frame.size.height)];
    [self addChildViewController:vc1];
    [self.view addSubview:vc1.view];
    [vc1 didMoveToParentViewController:self];
    _currentvc = vc1;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (needRefresh) {
        [[_viewcontrollers firstObject] refresh];
        [[_viewcontrollers lastObject] refresh];
    }
    [self.navigationItem setTitle:@"Pending"];
}

-(void)refresh {
    needRefresh = YES;
    if (_viewcontrollers) {
        [[_viewcontrollers firstObject] refresh];
        [[_viewcontrollers lastObject] refresh];
        needRefresh = NO;
    }
}

- (void)addSegmentedControlSubviews {
    _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Requests", @"Payments"]];
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

-(void) showHistory {
    if (!_tripHistoryVC) {
        _tripHistoryVC = [TripHistoryViewController new];
    }
    [self.navigationController pushViewController:_tripHistoryVC animated:YES];
}

-(void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
