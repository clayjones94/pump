//
//  SearchUserView.h
//  Pump
//
//  Created by Clay Jones on 8/29/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VENTokenField/VENTokenField.h>

@interface SearchUserView : UIView<VENTokenFieldDataSource, VENTokenFieldDelegate>

@property (nonatomic) VENTokenField *tokenField;

@end
