//
//  FinishView.m
//  Pump
//
//  Created by Clay Jones on 10/12/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "FinishView.h"
#import "TripManager.h"
#import "Utils.h"
#import "PassengerView.h"
#import "UserManager.h"
#import "Database.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation FinishView {
    UITextView *_descriptionField;
    UIActivityIndicatorView *_indicator;
    UIButton *_saveButton;
    UIButton *_discardButton;
    PassengerView *passengerView;
    UIButton *otherCarButton;
    UIButton *myCarButton;
    UIView *buttonBackgroundView;
    BOOL hasPassengers;
    UIButton *_carButton;
    UILabel *_detailLabel;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundColor:[UIColor clearColor]];
    UIView *backView = [[UIView alloc] initWithFrame:frame];
    [backView setBackgroundColor:[Utils defaultColor]];
    [backView setAlpha:.9];
    [self addSubview:backView];
    [self sendSubviewToBack:backView];
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicator setHidden:YES];
    [_indicator setFrame:CGRectMake(self.frame.size.width/2 - 25, self.frame.size.height/2 - 15, 50, 50)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:@"Delete Passengers" object:nil];
    
    UILabel *totalCostLabel = [[UILabel alloc] init];
    NSAttributedString *costString = [Utils defaultString:[NSString stringWithFormat:@"$%.2f", [TripManager sharedManager].distanceTraveled/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue]] size:30 color:[UIColor whiteColor]];
    [totalCostLabel setAttributedText:costString];
    [totalCostLabel sizeToFit];
    [totalCostLabel setFrame:CGRectMake(self.frame.size.width/2 - totalCostLabel.frame.size.width/2, 50 - totalCostLabel.frame.size.height/2, totalCostLabel.frame.size.width, totalCostLabel.frame.size.height)];
    
    [self addSubview:totalCostLabel];
    
    _descriptionField = [[UITextView alloc] initWithFrame:CGRectMake(22.5, 75, self.frame.size.width - 45, 50)];
    [_descriptionField setBackgroundColor:[Utils defaultLightColor]];
    [_descriptionField setText:@"Add a description..."];
    [_descriptionField setTextColor:[UIColor whiteColor]];
    _descriptionField.textContainerInset = UIEdgeInsetsMake(5, 8, 0, 20);
    [_descriptionField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:12]];
    [_descriptionField setEditable:YES];
    [_descriptionField setUserInteractionEnabled:YES];
    _descriptionField.delegate = self;
    [self addSubview:_descriptionField];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self addGestureRecognizer:tap];
    
    hasPassengers = YES;
    
    buttonBackgroundView = [[UIView alloc] init];
    [buttonBackgroundView setBackgroundColor:[Utils defaultLightColor]];
    [buttonBackgroundView.layer setCornerRadius:15];
    [self addSubview:buttonBackgroundView];
    
    
    myCarButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [myCarButton.layer setBorderWidth:1];
    [myCarButton.layer setCornerRadius:15];
    myCarButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [myCarButton addTarget:self action:@selector(switchCars) forControlEvents:UIControlEventTouchUpInside];
    NSAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"My Car"] size:12 color:[UIColor whiteColor]]];
    [myCarButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [myCarButton setAttributedTitle: title forState:UIControlStateNormal];
    [myCarButton setFrame:CGRectMake(self.frame.size.width*1/3 - 60 , 140, 100, 30)];
    [self addSubview:myCarButton];
    [myCarButton setBackgroundColor:[UIColor clearColor]];
    if (hasPassengers) {
        [buttonBackgroundView setFrame:myCarButton.frame];
        [myCarButton setUserInteractionEnabled:NO];
    } else {
        [myCarButton setUserInteractionEnabled:YES];
    }
    
    otherCarButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [otherCarButton.layer setBorderWidth:1];
    [otherCarButton.layer setCornerRadius:15];
    otherCarButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [otherCarButton addTarget:self action:@selector(switchCars) forControlEvents:UIControlEventTouchUpInside];
    title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Other Car"] size:12 color:[UIColor whiteColor]]];
    [otherCarButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [otherCarButton setAttributedTitle: title forState:UIControlStateNormal];
    [otherCarButton setFrame:CGRectMake(self.frame.size.width*2/3 - 40 , 140, 100, 30)];
    [self addSubview:otherCarButton];
    [otherCarButton setBackgroundColor:[UIColor clearColor]];
    if (!hasPassengers) {
        [otherCarButton setUserInteractionEnabled:NO];
        [buttonBackgroundView setFrame:otherCarButton.frame];
    } else {
        [otherCarButton setUserInteractionEnabled:YES];
    }
    
    _carButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [_carButton.layer setCornerRadius:3];
    [_carButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [_carButton setBackgroundColor:[Utils defaultLightColor]];
    [_carButton addTarget:self action:@selector(changeCar) forControlEvents:UIControlEventTouchUpInside];
    if (![TripManager sharedManager].car) {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Choose a car..."] size:12 color:[UIColor whiteColor]]];
    } else {
        title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@'s car", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:12 color:[UIColor whiteColor]]];
        [_carButton.imageView sd_setImageWithURL:[NSURL URLWithString:[[TripManager sharedManager].car objectForKey:@"profile_picture_url"]]
                                    placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
    }
    [_carButton setAttributedTitle: title forState:UIControlStateNormal];
    [_carButton setFrame:CGRectMake(22.5, 195, self.frame.size.width - 45, 40)];
    
    _saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_saveButton setBackgroundColor:[UIColor clearColor]];
    [_saveButton.layer setBorderWidth:1];
    [_saveButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_saveButton addTarget:self action:@selector(saveTrips:) forControlEvents:UIControlEventTouchUpInside];
    _discardButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_discardButton setBackgroundColor:[UIColor clearColor]];
    [_discardButton.layer setBorderWidth:1];
    [_discardButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_discardButton addTarget:self action:@selector(discardTrip) forControlEvents:UIControlEventTouchUpInside];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, 180, 0, 0)];
    [self addSubview:_detailLabel];
    
    if (hasPassengers) {
        [_detailLabel setAttributedText:[Utils defaultString:@"Passengers:" size:14 color:[UIColor whiteColor]]];
        passengerView = [[PassengerView alloc] initWithFrame:CGRectMake(20, 195, self.frame.size.width - 40, self.frame.size.height - 265)];
        [passengerView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self addSubview:passengerView];
        CGFloat height = (([TripManager sharedManager].passengers.count + 2) * 40 > self.frame.size.height - 265) ? self.frame.size.height - 265 + 205 : ([TripManager sharedManager].passengers.count + 2) * 40 + 205;
        [_saveButton setFrame:CGRectMake(self.frame.size.width*2/3 - 50/3 , height, 50, 50)];
        [_discardButton setFrame:CGRectMake(self.frame.size.width/3 - 50*2/3 , height, 50, 50)];
    } else {
        [_detailLabel setAttributedText:[Utils defaultString:@"Driver:" size:14 color:[UIColor whiteColor]]];
        [self addSubview:_carButton];
        [_saveButton setFrame:CGRectMake(self.frame.size.width*2/3 - 50/3 , 245, 50, 50)];
        [_discardButton setFrame:CGRectMake(self.frame.size.width/3 - 50*2/3, 245, 50, 50)];
    }
    [_detailLabel sizeToFit];
    [self addSubview:_descriptionField];
    
    [_saveButton setImage:[UIImage imageNamed:@"Checkmark Filled-25"] forState:UIControlStateNormal];
    [_saveButton.layer setCornerRadius:25];
    [_saveButton clipsToBounds];
    [_saveButton setUserInteractionEnabled:YES];
    [self addSubview:_saveButton];
    
    [_discardButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [_discardButton.layer setCornerRadius:25];
    [_discardButton setUserInteractionEnabled:YES];
    [self addSubview:_discardButton];
    return self;
}

-(void) changeCar {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Choose Car" object:nil];
}

-(void) update {
    if (hasPassengers) {
        [_detailLabel setAttributedText:[Utils defaultString:@"Passengers:" size:14 color:[UIColor whiteColor]]];
        if (!passengerView) {
            passengerView = [[PassengerView alloc] initWithFrame:CGRectMake(20, 195, self.frame.size.width - 40, self.frame.size.height - 265)];
        } else {
            [passengerView.tableView reloadData];
        }
        if (![passengerView superview]) {
            [self addSubview:passengerView];
        }
        if (_carButton && _carButton.superview) {
            [_carButton removeFromSuperview];
        }
         CGFloat height = (([TripManager sharedManager].passengers.count + 2) * 40 > self.frame.size.height - 265) ? self.frame.size.height - 265 + 205 : ([TripManager sharedManager].passengers.count + 2) * 40 + 205;
        [_saveButton setFrame:CGRectMake(self.frame.size.width*2/3 - 50/3 , height, 50, 50)];
        [_discardButton setFrame:CGRectMake(self.frame.size.width/3 - 50 * 2/3 , height, 50, 50)];
        [self bringSubviewToFront:_saveButton];
        [self bringSubviewToFront:_discardButton];
    } else {
        [_detailLabel setAttributedText:[Utils defaultString:@"Driver:" size:14 color:[UIColor whiteColor]]];
        if (passengerView) {
            [passengerView removeFromSuperview];
        }
        if (_carButton) {
            [self addSubview:_carButton];
        }
        NSAttributedString *title;
        if (![TripManager sharedManager].car) {
            title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@", @"Choose a car..."] size:12 color:[UIColor whiteColor]]];
        } else {
            title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:[NSString stringWithFormat:@"%@'s car", [[TripManager sharedManager].car objectForKey:@"display_name"]] size:14 color:[UIColor whiteColor]]];
            [_carButton.imageView sd_setImageWithURL:[NSURL URLWithString:[[TripManager sharedManager].car objectForKey:@"profile_picture_url"]]
                                    placeholderImage:[UIImage imageNamed:@"profile_pic_default"]];
        }
        [_carButton setAttributedTitle: title forState:UIControlStateNormal];
        [_saveButton setFrame:CGRectMake(self.frame.size.width*2/3 - 50 , 245, 50, 50)];
        [_discardButton setFrame:CGRectMake(self.frame.size.width/3 - 50*2/3, 245, 50, 50)];
        [self bringSubviewToFront:_saveButton];
        [self bringSubviewToFront:_discardButton];
    }
    [_detailLabel sizeToFit];
}

-(void) switchCars {
    if (hasPassengers) {
        hasPassengers = NO;
        [buttonBackgroundView setFrame:otherCarButton.frame];
        [myCarButton setUserInteractionEnabled:YES];
        [otherCarButton setUserInteractionEnabled:NO];
        [self update];
    } else {
        hasPassengers = YES;
        [TripManager sharedManager].car = nil;
        [buttonBackgroundView setFrame:myCarButton.frame];
        [myCarButton setUserInteractionEnabled:NO];
        [otherCarButton setUserInteractionEnabled:YES];
        [self update];
    }
}


-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UITableView class]] || [touch.view isKindOfClass:[UIButton class]]) return YES;
    return NO;
}

-(void)dismissKeyboard {
    [_descriptionField resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Add a description..."]) {
        textView.text = @"";
        textView.textColor = [UIColor whiteColor]; //optional
    }
    [textView becomeFirstResponder];
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self dismissKeyboard];
        return NO;
    }
    if(range.length + range.location > textView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return newLength <= 100;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Add a description...";
        textView.textColor = [UIColor whiteColor]; //optional
    } else {
        textView.textColor = [UIColor whiteColor];
    }
    [textView resignFirstResponder];
}

-(void) saveTrips: (UIButton *) sender {
    if ([[UserManager sharedManager] notUsingVenmo]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"You must sign up with Venmo to use this feature." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Sign in", nil];
        alert.tag = 1;
        alert.delegate = self;
        [alert show];
        return;
    }
    if ((![TripManager sharedManager].car && [TripManager sharedManager].passengers.count == 0) || ([_descriptionField.text isEqualToString:@"Add a description..."] && _descriptionField.text.length > 0)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"You must add passengers or a friend's car and write a description before completing this ride." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        [_indicator startAnimating];
        [_indicator setHidden:NO];
        [self addSubview:_indicator];
        [sender setUserInteractionEnabled:NO];
        [Database postTripWithDistance:[NSNumber numberWithDouble:[TripManager sharedManager].distanceTraveled/1609.344] gasPrice:[TripManager sharedManager].gasPrice mpg:[TripManager sharedManager].mpg polyline: [[[[TripManager sharedManager] polyline] path] encodedPath] includeUser: [TripManager sharedManager].includeUserAsPassenger description: _descriptionField.text  andPassengers: [TripManager sharedManager].passengers withBlock:^(NSDictionary *data, NSError *error) {
            if (!error) {
                [_indicator stopAnimating];
                [_indicator setHidden:YES];
                [_indicator removeFromSuperview];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [TripManager sharedManager].passengers = [NSMutableArray new];
                    [[TripManager sharedManager] setStatus:PENDING];
                    _descriptionField.text = @"Add a description...";
                    _descriptionField.textColor = [UIColor lightGrayColor];
                });
            } else {
                [sender setUserInteractionEnabled:YES];
            }
        }];
    }
}

- (void) discardTrip {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Quit trip" message:@"This trip will not be saved." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok", nil];
    alert.tag = 0;
    alert.delegate = self;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 0) {
        [[TripManager sharedManager] setStatus:FINISHED];
        [[TripManager sharedManager] setStatus:PENDING];
        _descriptionField.text = @"Add a description...";
        _descriptionField.textColor = [UIColor lightGrayColor];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
