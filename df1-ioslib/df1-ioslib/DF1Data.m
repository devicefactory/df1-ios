//
//  DF1Data.m
//  df1-ioslib
//
//  Created by JB Kim on 4/28/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//
#import "DF1Data.h"

@implementation DF1DataXyz
{
    NSUInteger size;
}

-(id) initWithSize:(NSUInteger) n
{
    self = [self init];
    if(self) {
        size = n;
        self.ts = [[NSMutableArray alloc] initWithCapacity:n];
        self.xv = [[NSMutableArray alloc] initWithCapacity:n];
        self.yv = [[NSMutableArray alloc] initWithCapacity:n];
        self.zv = [[NSMutableArray alloc] initWithCapacity:n];
    }
    return self;
} 

-(NSUInteger) insertX:(double) x Y:(double) y Z:(double) z
{
    return size;
}

@end


@implementation DF1Data

-(id) initWithSize:(NSUInteger) n
{
    self = [self init];
    self.xyz = [[DF1DataXyz alloc] initWithSize:n];
    return self;
} 

@end
