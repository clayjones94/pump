//
//  CarModelViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "CarModelViewController.h"
#import "Utils.h"
#import "Database.h"
#import "CustomMPGViewController.h"

#define TEXT_FIELD_WIDTH 180

@interface CarModelViewController ()

@end

@implementation CarModelViewController {
UIPickerView *picker;
NSMutableArray *_models;
NSMutableString *_currentString;
    __block NSXMLParser *modelParser;
    __block NSXMLParser *idParser;
    __block NSXMLParser *mpgParser;
    __block NSXMLParser *carParser;
    __block NSString *_carID;
    __block NSString *_gasType;
    __block NSString *_model;
    NSNumber *_mpg;
}

@synthesize year = _year;
@synthesize make = _make;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 25, 25)];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
}

-(void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    [self.view setBackgroundColor:[Utils defaultColor]];
    [Utils addDefaultGradientToView:self.view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:[Utils defaultString:@"Select a model:" size:24 color:[UIColor whiteColor]]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(width/2 - titleLabel.frame.size.width/2, height * .30 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    [self.view addSubview:titleLabel];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height * .95 -30) - height/2, width, height/2)];
    picker.delegate = self;
    picker.dataSource = self;
    [self.view addSubview:picker];
    
    UIButton *selectYearButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [selectYearButton.layer setCornerRadius:10];
    [selectYearButton setFrame:CGRectMake(self.view.frame.size.width * .1 , self.view.frame.size.height * .95 -15, width * .8, 30)];
    [selectYearButton addTarget:self action:@selector(selectModel) forControlEvents:UIControlEventTouchUpInside];
    [selectYearButton setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:selectYearButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"SELECT" size:14 color:[Utils defaultColor]];
    [selectYearButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) selectModel {
    _model = [_models objectAtIndex:[picker selectedRowInComponent:0]];
    [Database getCarFromModel:[_models objectAtIndex:[picker selectedRowInComponent:0]] make:_make andYear:_year withBlock:^(NSData *data, NSError *error){
        idParser = [[NSXMLParser alloc] initWithData:data];
        [idParser setDelegate:self];
        [idParser parse];
    }];
}

-(void) selectCarID:(NSString *)carID {
    _carID = carID;
    [Database getCarFromID:carID withBlock:^(NSData *data, NSError *error){
        if (!error) {
            carParser = [[NSXMLParser alloc] initWithData:data];
            [carParser setDelegate:self];
            [carParser parse];
        } else {
            [self.delegate couldNotFindMPGForCarModelViewController:self];
        }
    }];
}

-(void) getMPGForCar{
    [Database getMileageFromID:_carID withBlock:^(NSData *data, NSError *error) {
        if (!error) {
            mpgParser = [[NSXMLParser alloc] initWithData:data];
            [mpgParser setDelegate:self];
            [mpgParser parse];
        } else {
            [self.delegate couldNotFindMPGForCarModelViewController:self];
        }
    }];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _models.count;
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [Utils defaultString:[_models objectAtIndex:row] size:16 color:[UIColor whiteColor]];
}

-(void)setMake:(NSString *)make {
    _make = make;
    [Database getCarModelsFromMake:make andYear:_year withBlock:^(NSData *data, NSError *error){
        modelParser = [[NSXMLParser alloc] initWithData:data];
        [modelParser setDelegate:self];
        [modelParser parse];
    }];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([parser isEqual:modelParser]) {
        if ([elementName isEqualToString:@"menuItems"]) {
            _models = [NSMutableArray new];
        }
        if ([elementName isEqualToString:@"text"]) {
            _currentString = [NSMutableString new];
        }
    } else if([parser isEqual:idParser]){
        if ([elementName isEqualToString:@"value"]) {
            _currentString = [NSMutableString new];
        }
    } else if([parser isEqual:mpgParser]){
        if ([elementName isEqualToString:@"avgMpg"]) {
            _currentString = [NSMutableString new];
        }
    } else {
        if ([elementName isEqualToString:@"mpgData"]) {
            _currentString = [NSMutableString new];
        } else if ([elementName isEqualToString:@"fuelType1"]) {
            _currentString = [NSMutableString new];
        }
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_currentString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([parser isEqual:modelParser]) {
        if ([elementName isEqualToString:@"text"]) {
            [_models addObject:_currentString];
            _currentString = [NSMutableString new];
        }
        if ([elementName isEqualToString:@"menuItems"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [picker reloadAllComponents];
            });
        }
    } else if([parser isEqual:idParser]) {
        if ([elementName isEqualToString:@"value"]) {
            [self selectCarID:_currentString];
            _currentString = [NSMutableString new];
            [idParser abortParsing];
        }
    } else if([parser isEqual:mpgParser]){
        if ([elementName isEqualToString:@"avgMpg"]) {
            [self.delegate carModelViewController:self didFindMPG:[NSNumber numberWithDouble: [_currentString doubleValue]]];
        }
    } else {
        if ([elementName isEqualToString:@"mpgData"]) {
            if ([_currentString isEqualToString:@"Y"]) {
                _currentString = [NSMutableString new];
                [self getMPGForCar];
            } else {
                [self.delegate couldNotFindMPGForCarModelViewController:self];
            }
        } else if([elementName isEqualToString:@"fuelType1"]) {
            _gasType = _currentString;
            _currentString = [NSMutableString new];
        }
    }
}

@end
