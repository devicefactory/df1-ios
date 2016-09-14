//
//  DF1NewFeatureCell.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/20/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import "DF1NewFeatureCell.h"

@implementation DF1NewFeatureCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    
    
    self.addUseCaseBtn = [[UIButton alloc] init];
    [self.addUseCaseBtn addTarget:self action:@selector(newUseCasePressed) forControlEvents:UIControlEventTouchDown];
    UIImage *btnImage = [UIImage imageNamed:@"new_use_case_btn.png"];
    [_addUseCaseBtn setImage:btnImage forState:UIControlStateNormal];
    _addUseCaseBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.doneBtn = [[UIButton alloc] init];
    [self.doneBtn addTarget:self action:@selector(doneBtnPressed) forControlEvents:UIControlEventTouchDown];
    [self.doneBtn setEnabled:YES];
    [self.doneBtn setTitle:@"done" forState:UIControlStateNormal];
    self.doneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.doneBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.doneBtn setTitleColor:[UIColor DFRed] forState:UIControlStateNormal];
    self.doneBtn.hidden = YES;
    
    
    _useCaseTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 12, 160, 25)];
    _useCaseTextField.delegate = self;
    _useCaseTextField.hidden = YES;
    
    
    
    [self.contentView addSubview:self.addUseCaseBtn];
    [self.contentView addSubview:self.doneBtn];
    [self.contentView addSubview:self.useCaseTextField];
    
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;
    
    
    self.doneBtn.frame = CGRectMake(0, 0, width-20, 50);
    self.addUseCaseBtn.frame = CGRectMake(20, 12, 160, 25);
    
}

//the done button should say cancel if there is no text in the field.
-(void) doneBtnPressed {
    //add the text field to the array as a new use case and initialize to all on.
    NSLog(@"Da buttn werks");
    _useCaseTextField.hidden = YES;
    _addUseCaseBtn.hidden = NO;
    _doneBtn.hidden = YES;
    if(_useCaseTextField.text) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *useCases = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"use_cases"]];
        [useCases addObject:@{@"name" : _useCaseTextField.text,
                             @"DF1CfgBatteryLevel" : @1,
                             @"DF1CfgCSVDataRecorder" : @1,
                             @"DF1CfgDistance" : @1,
                             @"DF1CfgFreefall" : @1,
                             @"DF1CfgMagnitudeValues" : @1,
                             @"DF1CfgTap" : @1,
                             @"DF1CfgFlip" : @1,
                             @"DF1CfgXYZPlotter" : @1,
                              }];
        [defaults setObject:useCases forKey:@"use_cases"];
        [defaults setValue:_useCaseTextField.text forKey:@"active_use_case"];
        [defaults synchronize];
        
    }
    
    _useCaseTextField.text = @"";
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"showDoneBtn" object:nil];
    
    
}

-(void) newUseCasePressed {
    NSLog(@"Da otter buttn werks");
    _useCaseTextField.hidden = NO;
    _addUseCaseBtn.hidden = YES;
    _doneBtn.hidden = NO;
    //ADD NOTIFICATION TO HIDE MAIN DONE BTN in title cell
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"hideDoneBtn" object:nil];
    
    [_useCaseTextField becomeFirstResponder];

}


@end
