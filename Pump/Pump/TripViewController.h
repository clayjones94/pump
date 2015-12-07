//
//  TripViewController.h
//  Pump
//
//  Created by Clay Jones on 8/26/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import "DecimalKeypad.h"
#import "PlacesSearchView.h"
#import "DirectionsManager.h"

@interface TripViewController : UIViewController <TripManagerDelegate, GMSMapViewDelegate, UIAlertViewDelegate, DecimalKeypadDelegate, PlacesSearchViewDelegate>
@end
