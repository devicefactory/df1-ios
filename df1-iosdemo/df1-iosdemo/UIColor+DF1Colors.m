//
//  UIColor+DF1Colors.m
//  df1-iosdemo
//
//  Created by Nicholas Breeser on 4/6/15.
//  Copyright (c) 2015 JB Kim. All rights reserved.
//

#import "UIColor+DF1Colors.h"

@implementation UIColor (DF1Colors)
+(UIColor *)DFGreen {
    return [UIColor colorWithRed:55.0f/255.0f green:170.0f/255.0f blue:88.0f/255.0f alpha:1.0];
}

+(UIColor *)DFYellow {
    return [UIColor colorWithRed:253.0f/255.0f green:171.0f/255.0f blue:106.0f/255.0f alpha:1.0];
}

+(UIColor *)DFRed {
    return [UIColor colorWithRed:211.0f/255.0f green:40.0f/255.0f blue:100.0f/255.0f alpha:1.0];
}

+(UIColor *)DFBlue {
    return [UIColor colorWithRed:35.0f/255.0f green:154.0f/255.0f blue:227.0f/255.0f alpha:1.0];
}

+(UIColor *)DFBlack {
    return [UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1];
}

+(UIColor *)DFBarColor {
    return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1];
}

+(UIColor *)DFGray {
    return [UIColor colorWithRed:55.0f/255.0f green:56.0f/255.0f blue:57.0f/255.0f alpha:1];
}

@end
