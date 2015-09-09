//
//  SITLSlotsView.h
//  SlotMachine
//
//  Created by Jordan Jasinski on 08.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SITLSlotsSpinningCompletionBlock)(BOOL won, NSDictionary *result);

@interface SITLSlotsView : UIView

@property (nonatomic, assign) int numberOfStrips;

//designated initializer
-(instancetype)initWithItems:(NSArray*)items;

-(void)startAndWaitForStopWithCompletionBlock:(SITLSlotsSpinningCompletionBlock)completionBlock;
-(void)startAndStopAfter:(NSTimeInterval)timeInterval withCompletionBlock:(SITLSlotsSpinningCompletionBlock)completionBlock;
-(void)stop;
-(BOOL)isSpinning;
-(NSDictionary*)currentResult;
-(BOOL)currentResultWon;
-(NSArray*)items;

@end
