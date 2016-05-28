//
//  DF1FeatureTitleCell.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/17/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import "DF1FeatureTitleCell.h"

@implementation DF1FeatureTitleCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(!self) return self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUseCase:) name:@"useCaseSelected" object:nil];
    
    
    self.featureTitle = [[UILabel alloc] init];
    self.featureTitle.textAlignment = NSTextAlignmentLeft;
    self.featureTitle.font = [UIFont systemFontOfSize:16];
    self.featureTitle.textColor = [UIColor DFBlack];
    self.featureTitle.backgroundColor = [UIColor clearColor];
    self.featureTitle.tag = 4;
    self.featureTitle.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"active_use_case"];;

    self.changeFeatureSetBtn = [[UIButton alloc] init];
    [self.changeFeatureSetBtn addTarget:self action:@selector(changeButtonSelected) forControlEvents:UIControlEventTouchDown];
    [self.changeFeatureSetBtn setEnabled:YES];
    [self.changeFeatureSetBtn setTitle:@"change" forState:UIControlStateNormal];
    //self.changeFeatureSetBtn.tintColor = [UIColor DFRed];
    self.changeFeatureSetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.changeFeatureSetBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.changeFeatureSetBtn setTitleColor:[UIColor DFRed] forState:UIControlStateNormal];
    
    [self.contentView addSubview:self.featureTitle];
    [self.contentView addSubview:self.changeFeatureSetBtn];

    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGFloat width = self.contentView.bounds.size.width;

    
    self.changeFeatureSetBtn.frame = CGRectMake(0, 0, width-20, 50);
    self.featureTitle.frame = CGRectMake(30, 10, width, 30);
    
}

-(void) changeButtonSelected {
    NSLog(@"Da buttn werks");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"toggleUseCasePicker" object:nil];
    if([_changeFeatureSetBtn.titleLabel.text isEqualToString:@"change"]) {
        [self.changeFeatureSetBtn setTitle:@"done" forState:UIControlStateNormal];
    }
    else {
        [self.changeFeatureSetBtn setTitle:@"change" forState:UIControlStateNormal];
    }
    
}

-(void) updateUseCase:(NSNotification *)notification {
    
    if ([notification.name isEqualToString:@"useCaseSelected"])
    {
        NSDictionary *userInfo = notification.userInfo;
        _featureTitle.text = [userInfo objectForKey:@"useCase"];
    }
    NSLog(@"itTwerked!!!");
}

@end
