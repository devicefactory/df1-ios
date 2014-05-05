//
//  DF1Data.h
//  df1-ioslib
//
//  Created by JB Kim on 4/28/14.
//  Copyright (c) 2014 JB Kim. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "DF1LibDefs.h"
#import "DF1LibUtil.h"

@interface DF1DataXyz : NSObject
// vectors
@property (strong,nonatomic) NSMutableArray *ts;
@property (strong,nonatomic) NSMutableArray *xv;
@property (strong,nonatomic) NSMutableArray *yv;
@property (strong,nonatomic) NSMutableArray *zv;

-(id) initWithSize:(NSUInteger) n;
-(NSUInteger) insertX:(double) x Y:(double) y Z:(double) z;
@end


@interface DF1Data : NSObject

@property (strong,nonatomic) DF1DataXyz* xyz;

-(id) initWithSize:(NSUInteger) n;
@end
