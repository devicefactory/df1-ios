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
    
    
    return self;
}

-(void)viewDidLoad {
    NSUInteger index = [_dataArray indexOfObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_use_case"] ];
    [_picker reloadAllComponents];
    [_picker selectRow:index inComponent:0 animated:YES];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_dataArray count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_dataArray objectAtIndex: row];
}

// Do something with the selected row.
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [_dataArray objectAtIndex: row]);
    
    NSDictionary *userInfoDict = @{@"useCase": [_dataArray objectAtIndex: row]};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"useCaseSelected" object:nil userInfo:userInfoDict];
    
    //if(![[NSUserDefaults standardUserDefaults] objectForKey:[_dataArray objectAtIndex: row]]) {
    //[[NSUserDefaults standardUserDefaults] setObject:[_dataArray objectAtIndex: row] forKey:<#(nonnull NSString *)#>]
    //}
    
}

@end
