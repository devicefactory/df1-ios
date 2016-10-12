//
//  DF1NewFeatureCell.h
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/20/16.
//  Copyright © 2016 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+DF1Colors.h"
//TODO: the thing todo
@interface DF1NewFeatureCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, retain) UIButton *doneBtn;
@property (nonatomic, retain) UIButton *addUseCaseBtn;
@property (nonatomic, retain) UITextField *useCaseTextField;

@end
