//
//  SearchUserView.m
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SearchUserView.h"
#import "Utils.h"
#import "Database.h"
#import "SearchViewTableViewCell.h"
#import <Parse/Parse.h>
#import "TripManager.h"
#import "UserManager.h"

@implementation SearchUserView {
    UITableView *_tableview;
    NSMutableArray *_filteredFriends;
    NSMutableArray *_contactUsers;
    NSMutableArray *_recentUsers;
    NSMutableArray *_pumpUsers;
    NSMutableArray *_contacts;
    NSMutableArray *_filteredContacts;
    NSMutableArray *_filteredContactUsers;
    NSMutableArray *_filteredRecentUsers;
    NSMutableArray *_filteredPumpUsers;
    NSMutableArray *_contactNumbers;
    BOOL isFiltered;
    BOOL isVenmoFriends;
    UserManager *_userManager;
    UIActivityIndicatorView *_indicator;
}

@synthesize tokenField = _tokenField;
@synthesize friends = _friends;
@synthesize selectedFriends = _selectedFriends;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor whiteColor]];
    _tokenField = [[VENTokenField alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    _tokenField.delegate = self;
    _tokenField.dataSource = self;
    [_tokenField setPlaceholderText:@"Search Friends"];
    [_tokenField setToLabelText:@""];
    [_tokenField.layer setBorderWidth:.5];
    [_tokenField.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self addSubview:_tokenField];
    [self addSubview:_tableview];
    
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
    
    
    [self contactPhonesNumbersWithBlock:^(BOOL finished) {

    }];
    
    
    
    return self;
}

-(void)contactPhonesNumbersWithBlock: (void (^)(BOOL finished))block{
    _contactNumbers = [NSMutableArray new];
    _contacts = [NSMutableArray new];
    NSError *error;
    CNContactFetchRequest *fetch = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactFamilyNameKey]];
    CNContactStore *store = [UserManager sharedManager].contactStore;
    block([store enumerateContactsWithFetchRequest:fetch error:&error usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        if (contact.phoneNumbers.count > 0) {
            [_contacts addObject:contact];
        }
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_tokenField resignFirstResponder];
}

-(void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {

}

-(NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    id user = [_selectedFriends objectAtIndex:index];
    if ([user isKindOfClass:[CNContact class]]) {
        return [NSString stringWithFormat:@"%@ %@", ((CNContact *)user).givenName,((CNContact *)user).familyName];
    }
    return @"";
}

-(NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField {
    return [NSString stringWithFormat:@"%lu passengers", (unsigned long)_selectedFriends.count];
}

-(NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField {
    [_tableview setFrame:CGRectMake(0, _tokenField.frame.origin.y + _tokenField.frame.size.height, self.frame.size.width, self.frame.size.height - (_tokenField.frame.origin.y + _tokenField.frame.size.height))];
    
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
    if(text.length == 0)
    {
        isFiltered = FALSE;
    }
    else
    {
        isFiltered = true;
        _filteredRecentUsers = [[NSMutableArray alloc] init];
        _filteredContactUsers = [[NSMutableArray alloc] init];
        _filteredContacts = [[NSMutableArray alloc] init];;
        
        
        for (CNContact* friend in _contacts)
        {
            
            NSRange nameRange = [[NSString stringWithFormat: @"%@ %@", friend.givenName, friend.familyName] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange phoneRange = [friend.phoneNumbers.firstObject.value.stringValue rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound || phoneRange.location != NSNotFound)
            {
                [_filteredContacts addObject:friend];
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
    SearchViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    [cell setUserInteractionEnabled:YES];
    if (!cell) {
        cell = [[SearchViewTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Friend Cell"];
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
    
        if (isFiltered) {
            [cell setContact:_filteredContacts[indexPath.row]];
            if ([_selectedFriends containsObject:_filteredContacts[indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            [cell setContact:_contacts[indexPath.row]];
            if ([_selectedFriends containsObject:_filteredContacts[indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    
//    if ([_selectedFriends containsObject:user]) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    
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
    } else if (section == 2) {
        if (isFiltered) {
            if (_filteredContacts.count > 0) {
                return @"My contacts";
            }
            return @"";
        } else {
            if (_contacts.count > 0) {
                return @"My contacts";
            }
            return @"";
        }
    } else {
        if (_pumpUsers.count > 0) {
            return @"Other users";
        }
        return @"";
    }
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(12, 12, self.frame.size.width, 8);
    UIFont *font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:10];
    myLabel.font = font;
    myLabel.textColor = [UIColor grayColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor colorWithRed:242.0f/255 green:242.0f/255 blue:242.0f/255 alpha:1.0]];
    headerView.frame = CGRectMake(0, 0, self.frame.size.width, 8);
    [headerView addSubview:myLabel];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id user;
    if (isFiltered) {
        if (indexPath.section == 0) {
            user = [_filteredRecentUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            user = [_filteredContactUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 3) {
            user = [_pumpUsers objectAtIndex:indexPath.row];
        } else {
            user = [_filteredContacts objectAtIndex:indexPath.row];
        }
        
        if (user) {
            if ([_selectedFriends containsObject:user]) {
                [_selectedFriends removeObject:user];
            } else {
                [_selectedFriends addObject:user];
            }
        }
    } else {
        if (indexPath.section == 0) {
            user = [_recentUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 1) {
            user = [_contactUsers objectAtIndex:indexPath.row];
        } else if(indexPath.section == 3) {
            user = [_pumpUsers objectAtIndex:indexPath.row];
        } else {
            user = [_contacts objectAtIndex:indexPath.row];
        }
        if (user) {
            if ([_selectedFriends containsObject:user]) {
                [_selectedFriends removeObject:user];
            } else {
                [_selectedFriends addObject:user];
            }
        }
    }
    [self.delegate searchView:self didSelectUser:user];
    [tableView reloadData];
    [_tokenField reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of sections.
    if (_filteredRecentUsers.count > 0 || _recentUsers.count > 0 || _filteredContactUsers.count > 0 || _contactUsers.count > 0 || _pumpUsers.count > 0 || _contacts.count > 0 || _filteredContacts.count > 0) {
        _tableview.backgroundView = nil;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableview.backgroundView = nil;
        NSInteger rowCount = 0;
        if(isFiltered)
            if (section == 0) {
                rowCount = _filteredRecentUsers.count;
            } else if (section == 1) {
                rowCount = _filteredContactUsers.count;
            } else if (section == 2) {
                rowCount = _filteredContacts.count;
            } else {
                rowCount = _pumpUsers.count;
            }
        else
            if (section == 0) {
                rowCount = _recentUsers.count;
            } else if (section == 1) {
                rowCount = _contactUsers.count;
            } else if (section == 2) {
                rowCount = _contacts.count;
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
