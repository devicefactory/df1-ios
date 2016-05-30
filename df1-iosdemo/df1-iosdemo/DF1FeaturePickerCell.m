//
//  DF1FeaturePicker.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/17/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import "DF1FeaturePickerCell.h"

@implementation DF1FeaturePickerCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    
    _dataArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *useCases = [[NSMutableArray alloc] initWithArray:[defaults valueForKey:@"use_cases"]];
    for (NSDictionary *dict in useCases) {
        [_dataArray addObject:[dict valueForKey:@"name"]];
    }
    
    
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 150.0f)];
    _picker.delegate = self;
    _picker.dataSource = self;
    _picker.tag = 3;
    [self addSubview:_picker];
    
    NSUInteger index = [_dataArray indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_use_case"] ];
    [_picker reloadAllComponents];
    [_picker selectRow:index inComponent:0 animated:YES];
    
    _deleteCaseBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40, 150/2-10, 20, 20)];
    
    [self.deleteCaseBtn addTarget:self action:@selector(deleteBtnPressed) forControlEvents:UIControlEventTouchDown];
    UIImage *btnImage = [UIImage imageNamed:@"deleteCaseBtn.png"];
    [_deleteCaseBtn setImage:btnImage forState:UIControlStateNormal];
    _deleteCaseBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self insertSubview:_deleteCaseBtn aboveSubview:_picker];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(useCaseAdded) name:@"showDoneBtn" object:nil];
    

    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_dataArray count];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [_dataArray objectAtIndex: row]);
    
    NSDictionary *userInfoDict = @{@"useCase": [_dataArray objectAtIndex: row]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"useCaseSelected" object:nil userInfo:userInfoDict];
    
    NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
    [data setObject:[_dataArray objectAtIndex: row] forKey:@"active_use_case"];
    [data synchronize];
    
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *pickerSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 37)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 300, 37)];
    [pickerSubview addSubview:label];
    label.text = [_dataArray objectAtIndex: row];
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    return pickerSubview;
}

-(void) deleteBtnPressed {
    
    if(_dataArray.count>1) {
        //NSUInteger index = [_dataArray indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_use_case"]];
        long index = [_picker selectedRowInComponent:0];
        NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
        NSString *active_case_name = [_dataArray objectAtIndex:index];
        NSDictionary *userInfoDict;
            if(index != 0) {
                [data setObject:[_dataArray objectAtIndex:index-1] forKey:@"active_use_case"];
                 userInfoDict = @{@"useCase": [_dataArray objectAtIndex: index-1]};
            }
            else {
                [data setObject:[_dataArray objectAtIndex:index+1] forKey:@"active_use_case"];
                 userInfoDict = @{@"useCase": [_dataArray objectAtIndex: index+1]};
            }
        
        //iterate through use cases to find active one and delete it, resave use cases to defualts
        NSMutableArray *use_cases = [[NSMutableArray alloc]initWithArray:[data objectForKey:@"use_cases"]];
    
        for (int i=0; i<use_cases.count; i++) {
            NSDictionary *dict = [use_cases objectAtIndex:i];
            if([[dict valueForKey:@"name"] isEqualToString:active_case_name]) {
                [use_cases removeObjectAtIndex:i];
                break;
            }
        }
    
        [data setObject:use_cases forKey:@"use_cases"];
        [data synchronize];
    
    
       
        [[NSNotificationCenter defaultCenter] postNotificationName:@"useCaseSelected" object:nil userInfo:userInfoDict];
        [_dataArray removeObjectAtIndex:index];
        [_picker reloadAllComponents];
    }
    
}

-(void)useCaseAdded {
    NSString *newCaseName = [[NSUserDefaults standardUserDefaults] objectForKey:@"active_use_case"];
    [_dataArray addObject:newCaseName];
    
    NSUInteger index = [_dataArray indexOfObject:newCaseName];
    [_picker reloadAllComponents];
    [_picker selectRow:index inComponent:0 animated:YES];
    
    NSDictionary *userInfoDict = @{@"useCase": newCaseName};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"useCaseSelected" object:nil userInfo:userInfoDict];
    [_picker reloadAllComponents];
    
}

@end
