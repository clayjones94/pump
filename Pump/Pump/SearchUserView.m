//
//  SearchUserView.m
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SearchUserView.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Database.h"

@implementation SearchUserView {
    UITableView *_tableview;
    NSMutableArray *_filteredFriends;
    BOOL isFiltered;
    UIRefreshControl *_refreshControl;
    UserManager *_userManager;
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
    [_tokenField setPlaceholderText:@"Search Venmo Friends"];
    [_tokenField setToLabelText:@""];
    [_tokenField.layer setBorderWidth:.5];
    [_tokenField.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self addSubview:_tokenField];
    [self addSubview:_tableview];
    
    isFiltered = NO;
    _selectedFriends = [NSMutableArray new];
    
    [_tokenField setColorScheme:[Utils defaultColor]];
    _tokenField.maxHeight = 50;
    
    _userManager = [UserManager sharedManager];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self refresh:_refreshControl];
    [_tableview addSubview:_refreshControl];
    
    _tableview.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
    [_refreshControl beginRefreshing];
    
    return self;
}

-(void) refresh: (UIRefreshControl *) refreshControl {
    [_userManager updateFriendsWithBlock:^(BOOL updated) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshControl endRefreshing];
            [_tableview reloadData];
        });
    }];
}

-(void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text {

}

-(NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index {
    NSDictionary *friendDict = [_selectedFriends objectAtIndex:index];
    return [friendDict valueForKey:@"display_name"];
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
        _filteredFriends = [[NSMutableArray alloc] init];
        
        for (NSDictionary* friend in _friends)
        {
            
            NSRange nameRange = [[friend objectForKey:@"display_name"] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange phoneRange;
            NSRange emailRange;
            NSRange usernameRange;
            //if([friend objectForKey:@"phone"]) phoneRange = [[friend objectForKey:@"phone"] rangeOfString:text options:NSCaseInsensitiveSearch];
            //if([friend objectForKey:@"email"]) emailRange = [[friend objectForKey:@"email"] rangeOfString:text options:NSCaseInsensitiveSearch];
            //if([friend objectForKey:@"username"]) usernameRange = [[friend objectForKey:@"username"] rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound) //|| phoneRange.location != NSNotFound || emailRange.location != NSNotFound || usernameRange.location != NSNotFound)
            {
                [_filteredFriends addObject:friend];
            }
        }
    }
    
    [_tableview reloadData];
}

-(void)setFriends:(NSArray *)friends {
    _friends = friends;
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"display_name"  ascending:YES];
    _friends = [_friends sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
    [_tableview reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Friend Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Friend Cell"];
    }
    NSDictionary *friendDict;
    
    if (isFiltered) {
        friendDict = [_filteredFriends objectAtIndex:indexPath.row];
    } else {
        friendDict = [_friends objectAtIndex:indexPath.row];
    }
    
    CGSize itemSize = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(30 - itemSize.width/2, 30 - itemSize.height/2, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[friendDict objectForKey:@"profile_picture_url"]]
                      placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
    
    [cell.textLabel setText:[friendDict valueForKey:@"display_name"]];
    
    if ([_selectedFriends containsObject:friendDict]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *friend;
    if (isFiltered) {
        friend = [_filteredFriends objectAtIndex:indexPath.row];
        if ([_selectedFriends containsObject:friend]) {
            [_selectedFriends removeObject:friend];
        } else {
            [_selectedFriends addObject:friend];
        }
    } else {
        friend = [_friends objectAtIndex:indexPath.row];
        if ([_selectedFriends containsObject:friend]) {
            [_selectedFriends removeObject:friend];
        } else {
            [_selectedFriends addObject:friend];
        }
    }
    [self.delegate searchView:self didSelectUser:friend];
    [tableView reloadData];
    [_tokenField reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of sections.
    if (_friends.count > 0 || _filteredFriends.count > 0) {
        
        _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableview.backgroundView = nil;
        NSInteger rowCount;
        if(isFiltered)
            rowCount = _filteredFriends.count;
        else
            rowCount = _friends.count;
        return rowCount;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableview.bounds.size.width, _tableview.bounds.size.height)];
        
        messageLabel.attributedText = [Utils defaultString:@"No friends found." size:14 color:[UIColor lightGrayColor]];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        _tableview.backgroundView = messageLabel;
        _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}



@end
