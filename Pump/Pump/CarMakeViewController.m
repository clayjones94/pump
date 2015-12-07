//
//  CarMakeViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "CarMakeViewController.h"
#import "CarModelViewController.h"
#import "Utils.h"
#import "Database.h"

#define TEXT_FIELD_WIDTH 180

@interface CarMakeViewController ()
@end

@implementation CarMakeViewController {
    UIPickerView *picker;
    NSMutableArray *_makes;
    NSMutableString *_currentString;
}

@synthesize year = _year;

- (void)loadView {
    [super loadView];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

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
    [titleLabel setAttributedText:[Utils defaultString:@"Select a make:" size:24 color:[UIColor whiteColor]]];
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
    [selectYearButton addTarget:self action:@selector(selectMake) forControlEvents:UIControlEventTouchUpInside];
    [selectYearButton setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:selectYearButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"SELECT" size:14 color:[Utils defaultColor]];
    [selectYearButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) selectMake {
    NSString *make = [_makes objectAtIndex:[picker selectedRowInComponent:0]];
    CarModelViewController *vc = [CarModelViewController new];
    [vc setYear:_year];
    [vc setMake:make];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _makes.count;
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [Utils defaultString:[_makes objectAtIndex:row] size:16 color:[UIColor whiteColor]];
}

-(void)setYear:(NSString *)year {
    _year = year;
    [Database getCarMakesFromYear: year withBlock:^(NSData *data, NSError *error) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        
        [parser setDelegate:self];
        [parser parse];
    }];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"menuItems"]) {
        _makes = [NSMutableArray new];
    }
    if ([elementName isEqualToString:@"text"]) {
        _currentString = [NSMutableString new];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [_currentString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"text"]) {
        [_makes addObject:_currentString];
        _currentString = [NSMutableString new];
    }
    if ([elementName isEqualToString:@"menuItems"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [picker reloadAllComponents];
        });
    }
}

@end
