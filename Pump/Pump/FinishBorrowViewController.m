//
//  FinishBorrowViewController.m
//  en
//
//  Created by Clay Jones on 11/10/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import "FinishBorrowViewController.h"
#import "TripManager.h"
#import "Utils.h"
#import "UserManager.h"
#import "Database.h"
#import <Venmo-iOS-SDK/Venmo.h>
#import "AddPassengersViewController.h"
#import "ConnectWithVenmoViewController.h"

@interface FinishBorrowViewController ()

@end

@implementation FinishBorrowViewController {
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
    NSMutableDictionary *_errors;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundColor:[Utils defaultColor]];
    [self.navigationController.navigationBar setBarTintColor:[Utils defaultColor]];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    
    
    _descriptionField = [[UITextView alloc] initWithFrame:CGRectMake(0, 86, self.view.frame.size.width, 50)];
    [_descriptionField setBackgroundColor:[UIColor clearColor]];
    //    [_descriptionField.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    //    [_descriptionField.layer setBorderWidth:1];
    [_descriptionField setText:@"Add a description..."];
    [_descriptionField setTextColor:[UIColor lightGrayColor]];
    _descriptionField.textContainerInset = UIEdgeInsetsMake(5, 8, 0, 20);
    [_descriptionField setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:12]];
    [_descriptionField setEditable:YES];
    [_descriptionField setUserInteractionEnabled:YES];
    _descriptionField.delegate = self;
    [self.view addSubview:_descriptionField];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width * .05, _descriptionField.frame.origin.y + _descriptionField.frame.size.height + 1, self.view.frame.size.width * .9, 1)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:lineView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    buttonBackgroundView = [[UIView alloc] init];
    [buttonBackgroundView setBackgroundColor:[Utils defaultLightColor]];
    [buttonBackgroundView.layer setCornerRadius:15];
    [self.view addSubview:buttonBackgroundView];
    
    
    
    _saveButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [_saveButton setBackgroundColor:[Utils venmoColor]];
    //    [_saveButton.layer setBorderWidth:1];
    //    [_saveButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [_saveButton addTarget:self action:@selector(saveTrips:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *venmoLabel = [[UILabel alloc] init];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithAttributedString:[Utils defaultString:@"POWERED BY " size:12 color:[UIColor darkGrayColor]]];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"venmo_logo_blue"];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    [title appendAttributedString:attachmentString];
    [venmoLabel setAttributedText:title];
    [venmoLabel sizeToFit];
    
    //    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.5, 180, 0, 0)];
    //    [self.view addSubview:_detailLabel];
    
    //    if (hasPassengers) {
    [_detailLabel setAttributedText:[Utils defaultString:@"Passengers:" size:14 color:[UIColor whiteColor]]];
    passengerView = [[PassengerView alloc] initWithFrame:CGRectMake(0, 136, self.view.frame.size.width, self.view.frame.size.height - 226)];
    [passengerView.layer setBorderColor:[UIColor blackColor].CGColor];
    passengerView.delegate = self;
    [self.view addSubview:passengerView];
    CGFloat height = (passengerView.frame.origin.y + 40 > self.view.frame.size.height - 50 - 10) ? self.view.frame.size.height - 50 - 10 : passengerView.frame.origin.y + 40 + 30;
    [_saveButton setFrame:CGRectMake(self.view.frame.size.width * .5 - 70 , height, 140, 35)];
    [venmoLabel setFrame:CGRectMake(self.view.frame.size.width * .5 - venmoLabel.frame.size.width * .5, _saveButton.frame.origin.y + _saveButton.frame.size.height + 10, venmoLabel.frame.size.width, venmoLabel.frame.size.height)];
    [self.view addSubview:_descriptionField];
    
    [_saveButton setTitle:@"SEND PAYMENT" forState:UIControlStateNormal];
    [_saveButton.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:12]];
    [_saveButton.layer setCornerRadius:10];
    [_saveButton clipsToBounds];
    [_saveButton setUserInteractionEnabled:YES];
    [self.view addSubview:_saveButton];
    [self.view addSubview:venmoLabel];
    
    _errors = [NSMutableDictionary new];
    
    [TripManager sharedManager].paymentStatuses = [[NSMutableArray alloc] init];
    [[TripManager sharedManager].paymentStatuses addObject:[NSNumber numberWithInt: PAYMENT_PENDING]];
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
        textView.textColor = [UIColor grayColor]; //optional
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
        textView.textColor = [UIColor lightGrayColor]; //optional
    } else {
        textView.textColor = [UIColor grayColor];
    }
    [textView resignFirstResponder];
}

-(void) saveTrips: (UIButton *) sender {
    if (![Venmo sharedInstance].isSessionValid) {
        ConnectWithVenmoViewController *vc = [ConnectWithVenmoViewController new];
        [self presentViewController:vc animated:YES completion:nil];
    } else  {
        if ((![TripManager sharedManager].car && [TripManager sharedManager].passengers.count == 0) || ([_descriptionField.text isEqualToString:@"Add a description..."] && _descriptionField.text.length > 0)) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Wait" message:@"Please write a description." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [self chargePassengers];
            [_indicator startAnimating];
            [_indicator setHidden:NO];
            [self.view addSubview:_indicator];
        }
    }
}

-(void) chargePassenger: (id) passenger atIndex: (NSUInteger) index {
    __block NSUInteger i = index;
    NSString *target;
    if ([passenger isKindOfClass:[CNContact class]]){
        target = ((CNContact *)passenger).phoneNumbers.firstObject.value.stringValue;
    }
    [passengerView updatePaymentStatus:PAYMENT_PROCESSING Passenger:passenger atIndex:index error:nil];
    [[Venmo sharedInstance] sendPaymentTo:target amount:[self costOfPayment] * 100 note:_descriptionField.text audience:VENTransactionAudienceFriends completionHandler:^(VENTransaction *transaction, BOOL success, NSError *error) {
        if (success) {
            [passengerView updatePaymentStatus:PAYMENT_FINISHING Passenger:passenger atIndex:i error: nil];
        } else {
            [passengerView updatePaymentStatus:PAYMENT_FAILED Passenger:passenger atIndex:i error:error];
            if (error) {
                [_errors setObject:error forKey:[NSNumber numberWithInteger:index]];
            }
        }
    }];
    
}

-(void) chargePassengers{
    float cost = [self costOfPayment] * 100;
    if (cost < 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"The cost of your trip was too small." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [_saveButton removeTarget:self action:@selector(saveTrips:) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton setTitle:@"DONE" forState:UIControlStateNormal];
    id passenger = [TripManager sharedManager].car;
    [self chargePassenger:passenger atIndex:0];
}

-(void) dismiss {
    [[TripManager sharedManager] setStatus:FINISHED];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)passengerView:(PassengerView *)view didSelectCellAtIndexPath:(NSIndexPath *)index {
    NSError *error = [_errors objectForKey:[NSNumber numberWithInteger:index.row]];
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                                                  id passenger = [TripManager sharedManager].car;
                                                                  [self chargePassenger:passenger atIndex:index.row];
                                                              }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                                             }];
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(float) costOfPayment {
    float cost;
    cost = [TripManager sharedManager].distanceWhenStopped/1609.344 * [[[TripManager sharedManager] gasPrice] doubleValue] / [[[TripManager sharedManager] mpg] doubleValue];
    return cost;
}

-(void) cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 0) {
        [[TripManager sharedManager] setStatus:FINISHED];
        [[TripManager sharedManager] setStatus:PENDING];
        _descriptionField.text = @"Add a description...";
        _descriptionField.textColor = [UIColor whiteColor];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
