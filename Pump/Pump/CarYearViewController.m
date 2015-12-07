//
//  CarYearViewController.m
//  Pump
//
//  Created by Clay Jones on 10/22/15.
//  Copyright (c) 2015 Clay Jones. All rights reserved.
//

#import "CarYearViewController.h"
#import "CarMakeViewController.h"
#import "Utils.h"
#import "Database.h"

#define TEXT_FIELD_WIDTH 180

@interface CarYearViewController ()
@end

@implementation CarYearViewController {
    UIPickerView *picker;
    NSMutableArray *_years;
    NSMutableString *_currentString;
}

- (void)loadView {
    [super loadView];
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask=(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[Utils defaultColor]];
    [Utils addDefaultGradientToView:self.view];
    
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
    
    UIImageView *carImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_car"]];
    [carImage setFrame:CGRectMake(width/2 - carImage.frame.size.width/2, height * .25 - carImage.frame.size.height/2, carImage.frame.size.width, carImage.frame.size.height)];
    [self.view addSubview:carImage];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setAttributedText:[Utils defaultString:@"Select a year:" size:24 color:[UIColor whiteColor]]];
    [titleLabel sizeToFit];
    [titleLabel setFrame:CGRectMake(width/2 - titleLabel.frame.size.width/2, height * .45 - titleLabel.frame.size.height/2, titleLabel.frame.size.width, titleLabel.frame.size.height)];
    [self.view addSubview:titleLabel];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height * .95 -30) - height/2, width, height/2)];
    picker.delegate = self;
    picker.dataSource = self;
    [self.view addSubview:picker];
    [self setYears];
    
    UIButton *selectYearButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [selectYearButton.layer setCornerRadius:10];
    [selectYearButton setFrame:CGRectMake(self.view.frame.size.width * .1 , self.view.frame.size.height * .95 -15, width * .8, 30)];
    [selectYearButton addTarget:self action:@selector(selectYear) forControlEvents:UIControlEventTouchUpInside];
    [selectYearButton setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:selectYearButton];
    
    NSAttributedString *titleString = [Utils defaultString:@"SELECT" size:14 color:[Utils defaultColor]];
    [selectYearButton setAttributedTitle: titleString forState:UIControlStateNormal];
}

-(void) selectYear {
    NSString *year = [_years objectAtIndex:[picker selectedRowInComponent:0]];
    CarMakeViewController *vc = [CarMakeViewController new];
    [vc setYear:year];
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _years.count;
}

-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [Utils defaultString:[_years objectAtIndex:row] size:16 color:[UIColor whiteColor]];
}

-(void) setYears {
    [Database getCarYearswithBlock:^(NSData *data, NSError *error) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        
        [parser setDelegate:self];
        [parser parse];
    }];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"menuItems"]) {
        _years = [NSMutableArray new];
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
        [_years addObject:_currentString];
        _currentString = [NSMutableString new];
    }
    if ([elementName isEqualToString:@"menuItems"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [picker reloadAllComponents];
        });
    }
}

//-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
