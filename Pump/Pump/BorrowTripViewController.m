//
//  BorrowTripViewController.m
//  Pump
//
//  Created by Clay Jones on 10/24/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "BorrowTripViewController.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Database.h"
#import "BorrowCarTableViewCell.h"
#import <Parse/Parse.h>
#import "TripManager.h"
#import "UserManager.h"

@interface BorrowTripViewController ()

@end

@implementation BorrowTripViewController {
    UITableView *_tableview;
    NSMutableArray *_filteredFriends;
    NSMutableArray *_contactUsers;
    NSMutableArray *_recentUsers;
    NSMutableArray *_pumpUsers;
    NSMutableArray *_filteredContactUsers;
    NSMutableArray *_filteredRecentUsers;
    NSMutableArray *_filteredPumpUsers;
    NSMutableArray *_contactNumbers;
    BOOL isFiltered;
    BOOL isVenmoFriends;
    UserManager *_userManager;
    UIActivityIndicatorView *_indicator;
    
    PFQuery *_userQuery;
}

@synthesize tokenField = _tokenField;
@synthesize friends = _friends;
@synthesize selectedFriends = _selectedFriends;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"Select a car"];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    _tokenField.delegate = self;
    _tokenField.dataSource = self;
    [_tokenField setPlaceholderText:@"Find Car"];
    [_tokenField setToLabelText:@""];
    [_tokenField.layer setBorderWidth:.5];
    [_tokenField.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40)];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    //[_tableview setBackgroundColor:[Utils defaultColor]];
    [_tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tokenField];
    [self.view addSubview:_tableview];
    
    isVenmoFriends = NO;
    isFiltered = NO;
    _selectedFriends = [NSMutableArray new];
    
    [_tokenField setColorScheme:[Utils defaultColor]];
    _tokenField.maxHeight = 50;
    
    _userManager = [UserManager sharedManager];
    
    _friends = [[UserManager sharedManager] recents];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_indicator setHidden:YES];
    
    _pumpUsers = [NSMutableArray new];
    
    //    PFQuery *recentQuery = [PFQuery queryWithClassName:@"Trip"];
    //    [recentQuery whereKey:@"owner" notEqualTo:[PFUser currentUser].objectId];
    //    [recentQuery includeKey:@"passengers"];
    //    recentQuery.limit = 10;
    //    [recentQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    //        _recentUsers = [NSMutableArray new];
    //        int counter = 0;
    //        for (PFObject *trip in objects) {
    //            for(PFUser *passenger in trip[@"passengers"]){
    //                if (![self array:_recentUsers containsUser:passenger]) {
    //                    [_recentUsers addObject:passenger];
    //                    counter ++
    //                }
    //                if (counter > 20)break;
    //            }
    //        }
    //    }];
    
    [self contactPhonesNumbersWithBlock:^(BOOL finished) {
        [PFCloud callFunctionInBackground:@"retrieveUsersWithPhoneNumbers"
                           withParameters:@{ @"phone_numbers" : _contactNumbers
                                             }
                                    block:^(id object, NSError *error) {
                                        _contactUsers = object;
                                        [self filterOutPassengers];
                                        [_tableview reloadData];
                                    }];
    }];
    
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" hasPrefix:@""];
    PFQuery *firstnameQuery = [PFUser query];
    [firstnameQuery whereKey:@"first_name" hasPrefix:@""];
    PFQuery *lastnameQuery = [PFUser query];
    [lastnameQuery whereKey:@"last_name" hasPrefix:@""];
    _userQuery = [PFQuery orQueryWithSubqueries:@[usernameQuery, firstnameQuery, lastnameQuery]];
    [_userQuery whereKey:@"using_car" equalTo:[NSNumber numberWithBool:YES]];
    _userQuery.limit = 10;
    [_userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        _pumpUsers = [NSMutableArray arrayWithArray: objects];
        [_tableview reloadData];
    }];
    
    [PFCloud callFunctionInBackground:@"retrieveRecentPassengers"
                       withParameters:nil
     
                                block:^(id object, NSError *error) {
                                    _recentUsers = object;
                                    [self filterOutPassengers];
                                    [_tableview reloadData];
                                }];
}

-(BOOL) array: (NSMutableArray *) array containsUser: (PFUser *)user {
    for (PFUser *u in array) {
        if ([user.objectId isEqualToString:u.objectId]) {
            return YES;
        }
    }
    return NO;
}

-(void)contactPhonesNumbersWithBlock: (void (^)(BOOL finished))block{
    _contactNumbers = [NSMutableArray new];
    NSError *error;
    CNContactFetchRequest *fetch = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactPhoneNumbersKey]];
    CNContactStore *store = [UserManager sharedManager].contactStore;
    block([store enumerateContactsWithFetchRequest:fetch error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        for (CNLabeledValue *number in contact.phoneNumbers) {
            CNPhoneNumber *phone = number.value;
            [_contactNumbers addObject:[self formatPhoneNumber: phone.stringValue]];
        }
    }]);
}

-(NSString *)formatPhoneNumber: (NSString *)number {
    number = [[number componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
              componentsJoinedByString:@""];
    if (number.length > 10) {
        number = [number substringFromIndex:number.length - 10];
    }
    if (number.length == 10) {
        NSMutableString *string = [NSMutableString stringWithString:number];
        [string insertString:@"-" atIndex:3];
        [string insertString:@"-" atIndex:7];
        return string;
    }
    return @"";
}

-(void) filterOutPassengers {
    for (PFUser *user in [TripManager sharedManager].passengers) {
        [_contactUsers removeObjectIdenticalTo:user];
        [_recentUsers removeObjectIdenticalTo:user];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tokenField resignFirstResponder];
}

-(void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {
    
}

-(NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    PFUser *user = [_selectedFriends objectAtIndex:index];
    return user[@"username"];
}

-(NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField {
    return [NSString stringWithFormat:@"%lu passengers", (unsigned long)_selectedFriends.count];
}

-(NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField {
    [_tableview setFrame:CGRectMake(0, _tokenField.frame.origin.y + _tokenField.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (_tokenField.frame.origin.y + _tokenField.frame.size.height))];
    
    return _selectedFriends.count;
}

-(void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index {
    [_selectedFriends removeObjectAtIndex:index];
    [tokenField reloadData];
}

-(UIColor *)tokenField:(VENTokenField *)tokenField colorSchemeForTokenAtIndex:(NSUInteger)index {
    return [Utils defaultColor];
}

-(void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text {
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" hasPrefix:text.lowercaseString];
    PFQuery *firstnameQuery = [PFUser query];
    [firstnameQuery whereKey:@"first_name" hasPrefix:text.lowercaseString];
    PFQuery *lastnameQuery = [PFUser query];
    [lastnameQuery whereKey:@"last_name" hasPrefix:text.lowercaseString];
    _userQuery = [PFQuery orQueryWithSubqueries:@[usernameQuery, firstnameQuery, lastnameQuery]];
    [_userQuery whereKey:@"using_car" equalTo:[NSNumber numberWithBool:YES]];
    _userQuery.limit = 10;
    [_userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        _pumpUsers = [NSMutableArray arrayWithArray: objects];
        [_tableview reloadData];
    }];
    if(text.length == 0)
    {
        isFiltered = FALSE;
    }
    else
    {
        isFiltered = true;
        _filteredRecentUsers = nil;//[[NSMutableArray alloc] init];
        _filteredContactUsers = [[NSMutableArray alloc] init];
        
        for (PFUser* friend in _recentUsers)
        {
            
            NSRange nameRange = [[NSString stringWithFormat: @"%@ %@", friend[@"first_name"], friend[@"last_name"]] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange phoneRange = [friend[@"phone"] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange usernameRange = [friend[@"username"] rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound || phoneRange.location != NSNotFound ||  usernameRange.location != NSNotFound)
            {
                [_filteredRecentUsers addObject:friend];
            }
        }
        
        for (PFUser* friend in _contactUsers)
        {
            
            NSRange nameRange = [[NSString stringWithFormat: @"%@ %@", friend[@"first_name"], friend[@"last_name"]] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange phoneRange = [friend[@"phone"] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange usernameRange = [friend[@"username"] rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound || phoneRange.location != NSNotFound ||  usernameRange.location != NSNotFound)
            {
                [_filteredContactUsers addObject:friend];
            }
        }
    }
    
    [_tableview reloadData];
}



-(void)setFriends:(NSArray *)friends {
    _friends = friends;
    
    [_tableview reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BorrowCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    [cell setUserInteractionEnabled:YES];
    if (!cell) {
        cell = [[BorrowCarTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Friend Cell"];
    }
    
    PFUser *user;
    
    if (isFiltered) {
        if (indexPath.section == 0) {
            user = [_filteredRecentUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            user = [_filteredContactUsers objectAtIndex:indexPath.row];
        } else {
            user = [_pumpUsers objectAtIndex:indexPath.row];
        }
    } else {
        if (indexPath.section == 0) {
            user = [_recentUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            user = [_contactUsers objectAtIndex:indexPath.row];
        } else {
            user = [_pumpUsers objectAtIndex:indexPath.row];
        }
    }
    
    //    CGSize itemSize = CGSizeMake(40, 40);
    //    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    //    CGRect imageRect = CGRectMake(30 - itemSize.width/2, 30 - itemSize.height/2, itemSize.width, itemSize.height);
    //    [cell.imageView.image drawInRect:imageRect];
    //    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //
    //    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[friendDict objectForKey:@"profile_picture_url"]]
    //                      placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
    
    [cell setUser:user];
    
    if ([_selectedFriends containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (isFiltered) {
            if (_filteredRecentUsers.count > 0) {
                return @"Recent passengers";
            }
            return @"";
        } else {
            if (_recentUsers.count > 0) {
                return @"Recent passengers";
            }
            return @"";
        }
    } else if (section == 1) {
        if (isFiltered) {
            if (_filteredContactUsers.count > 0) {
                return @"Contacts in pump";
            }
            return @"";
        } else {
            if (_contactUsers.count > 0) {
                return @"Contacts in pump";
            }
            return @"";
        }
    } else {
        if (_pumpUsers.count > 0) {
            return @"Pump users";
        }
        return @"";
    }
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(12, 12, self.view.frame.size.width, 8);
    UIFont *font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:10];
    myLabel.font = font;
    myLabel.textColor = [UIColor grayColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:242.0f/255 green:242.0f/255 blue:242.0f/255 alpha:1.0]];
    headerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 8);
    [headerView addSubview:myLabel];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user;
    if (isFiltered) {
        if (indexPath.section == 0) {
            user = [_filteredRecentUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            user = [_filteredContactUsers objectAtIndex:indexPath.row];
        } else {
            user = [_pumpUsers objectAtIndex:indexPath.row];
        }
    } else {
        if (indexPath.section == 0) {
            user = [_recentUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            user = [_contactUsers objectAtIndex:indexPath.row];
        } else {
            user = [_pumpUsers objectAtIndex:indexPath.row];
        }
        if ([_selectedFriends containsObject:user]) {
            [_selectedFriends removeObject:user];
        } else {
            [_selectedFriends addObject:user];
        }
    }
    //[self.delegate searchView:self didSelectUser:user];
    [tableView reloadData];
    [_tokenField reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of sections.
    if (_filteredRecentUsers.count > 0 || _recentUsers.count > 0 || _filteredContactUsers.count > 0 || _contactUsers.count > 0 || _pumpUsers.count > 0) {
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableview.backgroundView = nil;
        NSInteger rowCount = 0;
        if(isFiltered)
            if (section == 0) {
                rowCount = _filteredRecentUsers.count;
            } else if (section == 1) {
                rowCount = _filteredContactUsers.count;
            } else {
                rowCount = _pumpUsers.count;
            }
            else
                if (section == 0) {
                    rowCount = _recentUsers.count;
                } else if (section == 1) {
                    rowCount = _contactUsers.count;
                } else {
                    rowCount = _pumpUsers.count;
                }
        return rowCount;
        
    } else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableview.bounds.size.width, _tableview.bounds.size.height)];
        
        messageLabel.attributedText = [Utils defaultString:@"No results" size:14 color:[UIColor lightGrayColor]];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        _tableview.backgroundView = messageLabel;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

@end
