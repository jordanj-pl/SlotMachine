//
//  SITLSlotSpinner.h
//  SlotMachine
//
//  Created by Jordan Jasinski on 08.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SITLSlotSpinner : UIView

-(instancetype)initWithItems:(NSArray*)items andSelectedIndex:(int)selectedIndex;

//velocity is number of seconds which takes movmenent through the entire length is strip
-(void)startWithVelocity:(NSTimeInterval)velocity;
-(void)stopWithCompletionBlock:(void(^)(int result))completionBlock;
-(int)currentItem;
-(BOOL)isSpinning;

@end
