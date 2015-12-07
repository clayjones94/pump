//
//  PlacesSearchView.h
//  en
//
//  Created by Clay Jones on 10/27/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "Database.h"
#import "SearchViewTableViewCell.h"
#import <Parse/Parse.h>
#import "TripManager.h"
#import "UserManager.h"
#import <VENTokenField/VENTokenField.h>

@class PlacesSearchView;

@protocol PlacesSearchViewDelegate <NSObject>
@optional
- (void) searchView: (PlacesSearchView *)manager didSelectPlace: (GMSAutocompletePrediction *)place;
@end

@interface PlacesSearchView : UIView <UITextFieldDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property id <PlacesSearchViewDelegate> delegate;
@property UITextField *searchBar;
@property (nonatomic) NSArray *friends;
@property (nonatomic) NSMutableArray *selectedFriends;
@property (nonatomic) GMSCoordinateBounds *mapBounds;
@property (nonatomic) BOOL hasAddress;

-(void) setTableHidden:(BOOL)hidden;
@end
