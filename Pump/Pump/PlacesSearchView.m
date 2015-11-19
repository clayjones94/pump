//
//  PlacesSearchView.m
//  en
//
//  Created by Clay Jones on 10/27/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "PlacesSearchView.h"
#import "PlacesTableViewCell.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation PlacesSearchView{
    UITableView *_tableview;
    NSArray *_places;
    NSMutableArray *_filteredPlaces;
    BOOL isFiltered;
    UserManager *_userManager;
    UIActivityIndicatorView *_indicator;
    GMSPlacesClient *_placesClient;
    
    PFQuery *_userQuery;
    CGRect maxFrame;
    BOOL tableHidden;
    GMSAutocompletePrediction *_place;
}

@synthesize searchBar = _searchBar;
@synthesize friends = _friends;
@synthesize selectedFriends = _selectedFriends;
@synthesize mapBounds = _mapBounds;
@synthesize hasAddress = _hasAddress;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    maxFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 50*3 + 40);
    [self setBackgroundColor:[UIColor whiteColor]];
    _searchBar = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    _searchBar.delegate = self;
    [_searchBar.layer setBorderWidth:0];
    [_searchBar setPlaceholder:@"Get directions"];
    [_searchBar setTextColor:[UIColor grayColor]];
    [_searchBar.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [_searchBar setBackgroundColor:[UIColor whiteColor]];
    [_searchBar setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:18]];
    _searchBar.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    [_searchBar addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
//    [_searchBar imageForSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
//    [_searchBar setSearchBarStyle:UISearchBarStyleMinimal];
//    [_searchBar setBarTintColor:[UIColor whiteColor]];
    for (UIView *view in _searchBar.subviews) {
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 50*3)];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self addSubview:_searchBar];
    [self addSubview:_tableview];
    
    [self setTableHidden:YES];
    tableHidden = YES;
    isFiltered = NO;
    _selectedFriends = [NSMutableArray new];
    
    _userManager = [UserManager sharedManager];
    
    _friends = [[UserManager sharedManager] recents];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setHidden:YES];
    
    _places = [NSMutableArray new];
    _placesClient = [[GMSPlacesClient alloc] init];
    
    return self;
}



-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    maxFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 50*3 + 40);
    [_tableview setFrame:CGRectMake(0, 40, frame.size.width, 50*3)];
    [_searchBar setFrame:CGRectMake(0, 0, frame.size.width, 40)];
}

-(void) layoutSubviews {
}

-(BOOL) array: (NSMutableArray *) array containsUser: (PFUser *)user {
    for (PFUser *u in array) {
        if ([user.objectId isEqualToString:u.objectId]) {
            return YES;
        }
    }
    return NO;
}

-(void)setTableHidden:(BOOL)hidden {
    tableHidden = hidden;
    if (hidden) {
        [self setFrame:CGRectMake(maxFrame.origin.x, maxFrame.origin.y, _searchBar.frame.size.width, _searchBar.frame.size.height)];
        if (_tableview.superview) {
            [_tableview removeFromSuperview];
        }
    } else {
        [self setFrame:maxFrame];
        [_tableview setFrame:CGRectMake(0, 40, self.frame.size.width, 50*3)];
        if (!_tableview.superview) {
            [self addSubview:_tableview];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

-(BOOL)textFieldShouldBeginEditing:(UITextView *)textView {
    [_searchBar setText:@""];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextView *)textView {
    [_searchBar resignFirstResponder];
    [self setTableHidden:YES];
    return YES;
}

//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if ([text containsString:@"\r"]) {
//        [self resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}


-(void)textFieldDidChange:(UITextField *)textField {
    NSString *searchText = textField.text;
    if(searchText.length == 0)
    {
        isFiltered = NO;
        _places = nil;
        [self setTableHidden:YES];
    }
    else
    {
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        filter.type = kGMSPlacesAutocompleteTypeFilterCity;
        
        [_placesClient autocompleteQuery:searchText
                                  bounds:_mapBounds
                                  filter:nil
                                callback:^(NSArray *results, NSError *error) {
                                    if (error != nil) {
                                        NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                        return;
                                    }
                                    
                                    _places = results;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [_tableview reloadData];
                                    });
                                }];
        [self setTableHidden:NO];
    }
    
    [_tableview reloadData];
}

-(void) searchPlacesWithText:(NSString *)text withBlock: (void (^)(NSArray *data, NSError *error))block {
    NSString *searchText = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    CLLocation *location = [TripManager sharedManager].locationManager.location;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&location=%f,%f&radius=5000&key=AIzaSyBXLn6XVgKVl1rKT1BjgpN2IdkqPbFJ8E0", searchText, location.coordinate.latitude, location.coordinate.longitude]]];
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    isFiltered = NO;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *placesArray = [dataDict objectForKey:@"results"];
        block(placesArray, error);
    }];
    
    [task resume];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    [cell setUserInteractionEnabled:YES];
    if (!cell) {
        cell = [[PlacesTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Friend Cell"];
    }
    
    GMSAutocompletePrediction *place;
    if (isFiltered) {
        place = [_filteredPlaces objectAtIndex:indexPath.row];
    } else {
        place = [_places objectAtIndex:indexPath.row];
    }
    
    [cell setPlace:place];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return @"";
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GMSAutocompletePrediction *place;
    if (isFiltered) {
        place = [_filteredPlaces objectAtIndex:indexPath.row];
    } else {
        place = [_places objectAtIndex:indexPath.row];
    }
    _hasAddress = YES;
    _place = place;
    [self.delegate searchView:self didSelectPlace:place];
    [self setTableHidden:YES];
    [tableView reloadData];
    [_searchBar setText:_place.attributedFullText.string];
    [_searchBar resignFirstResponder];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (section == 1) {
        if (!isFiltered && _places.count > 0) {
            [self setTableHidden:NO];
            return _places.count;
        } else if (isFiltered && _filteredPlaces.count > 0) {
            [self setTableHidden:NO];
            return _filteredPlaces.count;
        }
    //}
    [self setTableHidden:YES];
    return 0;
}

@end
