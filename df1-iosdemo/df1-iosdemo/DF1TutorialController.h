//
//  DF1TutorialController.h
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 5/31/15.
//  Copyright (c) 2015 JB Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFTTTJazzHands.h"
#import "UIColor+DF1Colors.h"

@interface DF1TutorialController  : IFTTTAnimatedScrollViewController <IFTTTAnimatedScrollViewControllerDelegate>
@property (nonatomic, strong) IFTTTAnimator *animator;
@end
