//
//  Constants.h
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#ifndef Pump_Constants_h
#define Pump_Constants_h

static NSString *const VENMO_APP_ID = @"2906";
static NSString *const VENMO_APP_SECRET = @"gWhWmzBcrm4gJMzHNxC9JsEcC2dgUeRB";
static NSString *const VENMO_APP_NAME = @"Pump";
static NSString *const APNS_TOKEN_KEY = @"APNS Token";
static NSString *const PUMP_USER_ID_KEY = @"USER ID";


typedef NS_ENUM(NSUInteger, TripStatusType) {
    PENDING,
    RUNNING,
    PAUSED,
    FINISHED,
};

typedef NS_ENUM(NSUInteger, GasType) {
    GAS_TYPE_REGULAR,
    GAS_TYPE_MIDGRADE,
    GAS_TYPE_PREMIUM,
    GAS_TYPE_DIESEL,
};

typedef NS_ENUM(NSUInteger, PaymentStatus) {
    PAYMENT_PENDING,
    PAYMENT_PROCESSING,
    PAYMENT_FINISHING,
    PAYMENT_SUCCESS,
    PAYMENT_FAILED,
};

#endif
