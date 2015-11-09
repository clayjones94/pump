//
//  PlacesTableViewCell.h
//  en
//
//  Created by Clay Jones on 10/27/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface PlacesTableViewCell : UITableViewCell
@property (nonatomic) GMSAutocompletePrediction *place;
@end
