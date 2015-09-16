//
//  Friend.h
//  
//
//  Created by Clay Jones on 9/7/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * display_name;
@property (nonatomic, retain) NSString * venmo_id;

@end
