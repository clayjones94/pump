//
//  DirectionsManager.h
//  en
//
//  Created by Clay Jones on 10/27/15.
//  Copyright © 2015 Clay Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@class DirectionsManager;

@protocol DirectionsManagerDelegate <NSObject>
@optional
- (void) manager: (DirectionsManager *)manager didUpdatePath: (GMSPath *)path;
-(void) managerDidChangeSteps:(DirectionsManager *)manager;
-(void) managerDidStartDirecting:(DirectionsManager *)manager;
-(void) managerDidEndDirecting:(DirectionsManager *)manager;
@end

@interface DirectionsManager : NSObject

@property (nonatomic, readonly) GMSPath *path;
@property (nonatomic, readonly) NSUInteger currentStep;
@property (nonatomic) BOOL isDirecting;

+ (DirectionsManager *)sharedManager;
@property id <DirectionsManagerDelegate> delegate;
-(void) startDirecting;
-(void) endDirecting;
-(void) startDirectionsToLocationDescription: (NSString *) destDescription withBlock: (void (^)(NSError *error))block;
-(void) updateLocationWithBlock: (void (^)(CLLocationDistance stepDistance, CLLocationDistance totalDistance, NSTimeInterval totalTime))block;
-(NSAttributedString *) currentInstruction;
-(CLLocationDirection) currentDirection;
-(NSAttributedString *) nextInstruction;
-(UIImage *)currentManeuver;
-(UIImage *)nextManeuver;
-(void) nextStep;

@end
