//
//  SearchUserView.m
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "SearchUserView.h"
#import "Utils.h"

@implementation SearchUserView {
    UITableView *_tableview;
    NSMutableArray *_filteredFriends;
    BOOL isFiltered;
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
    [_tokenField setPlaceholderText:@"Choose a friends car..."];
    [_tokenField setToLabelText:@""];
    [_tokenField.layer setBorderWidth:.5];
    [_tokenField.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, self.frame.size.height - 40)];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self addSubview:_tableview];
    [self addSubview:_tokenField];
    
    isFiltered = NO;
    _selectedFriends = [NSMutableArray new];
    
    [_tokenField setColorScheme:[Utils defaultColor]];
    _tokenField.maxHeight = 50;
    
    return self;
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
            //NSRange phoneRange = [[friend objectForKey:@"phone"] rangeOfString:text options:NSCaseInsensitiveSearch];
            //NSRange emailRange = [[friend objectForKey:@"email"] rangeOfString:text options:NSCaseInsensitiveSearch];
            //NSRange usernameRange = [[friend objectForKey:@"username"] rangeOfString:text options:NSCaseInsensitiveSearch];
            
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
    
    [cell.textLabel setText:[friendDict valueForKey:@"display_name"]];
    
    if ([_selectedFriends containsObject:friendDict]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
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
    [tableView reloadData];
    [_tokenField reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount;
    if(isFiltered)
        rowCount = _filteredFriends.count;
    else
        rowCount = _friends.count;
    
    return rowCount;
}



@end
