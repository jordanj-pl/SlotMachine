//
//  SITLSlotSpinner.m
//  SlotMachine
//
//  Created by Jordan Jasinski on 08.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import "SITLSlotSpinner.h"

#import <math.h>

@interface SITLSlotSpinner ()

@property (nonatomic, assign) BOOL spinning;

@property (nonatomic, strong) NSArray *items;

@property (nonatomic, assign) CGFloat verticalCenter;
@property (nonatomic, assign) CGFloat centeredPosition;
@property (nonatomic, assign) CGFloat horizontalCenter;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation SITLSlotSpinner

-(instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    if(self) {
        _items = items;
        
        if([_items count] < 3) {
            @throw [NSException exceptionWithName:@"Not enough elements" reason:@"At least 3 elements should be given in order for the component to work properly." userInfo:nil];
        }

        self.clipsToBounds = YES;
        
        for(UIImage *item in _items) {
            UIImageView *itemView = [[UIImageView alloc] initWithImage:item];
            [itemView setFrame:CGRectMake(0, 0, 50.0f, 50.0f)];
            itemView.contentMode = UIViewContentModeScaleAspectFit;
//            itemView.layer.borderWidth = 2.0f;
//            itemView.layer.borderColor = [[UIColor redColor] CGColor];
            [self addSubview:itemView];
        }
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.verticalCenter = frame.size.height / 2.0f;
    self.horizontalCenter = frame.size.width / 2.0f;
    
    int ii = 0;
    for (UIImageView *itemView in self.subviews) {
        [itemView setFrame:CGRectMake((self.frame.size.width-itemView.frame.size.width)/2.0f, itemView.frame.size.height*ii, itemView.frame.size.width, itemView.frame.size.height)];
        ii++;
    }
    
    if(self.items) {
        [self moveToInitialPosition];
    }

}

-(void)moveToInitialPosition {
    UIImageView *centeredItemView = self.subviews[1];

    self.itemSize = centeredItemView.frame.size;
    self.centeredPosition = self.verticalCenter-self.itemSize.height/2.0f;

    centeredItemView.frame = CGRectMake(centeredItemView.frame.origin.x, self.centeredPosition, self.itemSize.width, self.itemSize.height);
    centeredItemView.alpha = 1.0f;
    
    UIImageView *firstItemView = self.subviews[0];
    firstItemView.frame = CGRectMake(firstItemView.frame.origin.x, self.centeredPosition-firstItemView.frame.size.height, self.itemSize.width, self.itemSize.height);
    firstItemView.alpha = 0.5f;
    
    for (int i = 2; i < [self.items count]; i++) {
        UIImageView *itemView = self.subviews[i];
        itemView.frame = CGRectMake(itemView.frame.origin.x, self.centeredPosition+self.itemSize.height + self.itemSize.height*(i-2), self.itemSize.width, self.itemSize.height);
        itemView.alpha = 0.5f;
    }
}

-(void)animateElement:(UIImageView*)element withSpecificVelocity:(NSTimeInterval)specificVelocity {
    
    NSUInteger elementIndex = [self.subviews indexOfObject:element];
    NSUInteger previousElementIndex = 0;
    if(elementIndex == 0) {
        previousElementIndex = [self.subviews count]-1;
    } else {
        previousElementIndex = elementIndex-1;
    }
    
    UIImageView *previousItem = self.subviews[previousElementIndex];
    CGFloat previousItemPosition = ((CALayer *)previousItem.layer.presentationLayer).frame.origin.y;
    CGFloat initialPosition = previousItemPosition+self.itemSize.height;//[self nearestStopPosition:previousItemPosition]+self.itemSize.height;
    
    NSLog(@"item: %lu (%f) | previous item: %lu (%f) | INITIAL: %f", elementIndex, element.frame.origin.y, previousElementIndex, previousItemPosition, initialPosition);
/*
    if (initialPosition < self.frame.size.height) {
        int positionError = self.frame.size.height - initialPosition;
        int positionErrorM = ceilf(positionError/self.itemSize.height);
        initialPosition += positionErrorM*self.itemSize.height;
    }
*/
    element.frame = CGRectMake(element.frame.origin.x, initialPosition, self.itemSize.width, self.itemSize.height);

    CGFloat distanceToTravel = element.frame.origin.y + element.frame.size.height;
    NSLog(@"DISTANCE %f + %f", element.frame.origin.y, element.frame.size.height);
    NSTimeInterval duration = distanceToTravel*specificVelocity;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        element.frame = CGRectMake(element.frame.origin.x, 0.0f-element.frame.size.height, element.frame.size.width, element.frame.size.height);
    } completion:^(BOOL finished) {
        if(finished && self.spinning) {
            [self animateElement:element withSpecificVelocity:specificVelocity];
        }
    }];
    
/*
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState|UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
    } completion:^(BOOL finished) {
        if(finished && self.spinning) {
            [self animateElement:element withSpecificVelocity:specificVelocity];
        }
    }];
*/
}

-(int)nearestStopPosition:(CGFloat)currentPosition {
    
//    CGFloat centeredPosition = self.verticalCenter-self.itemSize.height/2.0f;
    int distanceFromCenteeredItem = roundf(currentPosition)-self.centeredPosition;
    CGFloat positionShift = fmodf(distanceFromCenteeredItem, self.itemSize.height);
    int stopPosition = roundf(currentPosition);
    
    if(positionShift < self.itemSize.height/2) {
        stopPosition -= positionShift;
    } else {
        stopPosition += (self.itemSize.height - positionShift);
    }
    
//    NSLog(@"nearest stop position to: %f (%d [%f] | %f) is %d", currentPosition, distanceFromCenteeredItem, positionShift, centeredPosition, stopPosition);
    
    return stopPosition;
}

#pragma mark - widget interactions

-(void)startWithVelocity:(NSTimeInterval)velocity {
    NSLog(@"::>> startWithVelocity: %f", velocity);
    
    if(self.spinning) {
        return;
    }
    
    self.spinning = YES;
    
    NSTimeInterval specificVelocity = velocity/self.frame.size.height;
    
    NSLog(@"specific v: %f", specificVelocity);
    
    for (UIImageView *itemView in self.subviews) {
        CGFloat distanceToTravel = fabs(0.0f-itemView.frame.size.height - itemView.frame.origin.y);
        NSTimeInterval duration = distanceToTravel*specificVelocity;
        
        NSLog(@"distance %f duration %f", distanceToTravel, duration);

        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            itemView.frame = CGRectMake(itemView.frame.origin.x, 0.0f-itemView.frame.size.height, itemView.frame.size.width, itemView.frame.size.height);
            itemView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if(finished && self.spinning) {
                [self animateElement:itemView withSpecificVelocity:specificVelocity];
            }
        }];
        
    }

}

-(void)stopWithCompletionBlock:(void (^)(int))completionBlock {
    self.spinning = NO;
    
    __block int completedNumber = 0;
    for (UIImageView *imgView in self.subviews) {

        [UIView animateWithDuration:2.0
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             CGFloat endPosition = [self nearestStopPosition:((CALayer *)imgView.layer.presentationLayer).frame.origin.y];
                             imgView.frame = CGRectMake(imgView.frame.origin.x, endPosition, imgView.frame.size.width, imgView.frame.size.height);
                             
                             if(endPosition == self.centeredPosition) {
                                 imgView.alpha = 1.0f;
                             } else {
                                 imgView.alpha = 0.5f;
                             }
                             
                         } completion:^(BOOL finished){
                             completedNumber++;
                             
                             if(completedNumber == [self.subviews count]) {
                                 int currentItem = [self currentItem];
                                 completionBlock(currentItem);                                 
                             }
                         }
         ];
    }
}

-(int)currentItem {
    NSUInteger numberOfItems = [self.subviews count];
    
    for (int i = 0; i < numberOfItems; i++) {
        UIImageView *item = self.subviews[i];
        CGFloat startPoint = item.frame.origin.y;
        CGFloat endPoint = item.frame.origin.y + item.frame.size.height;
        if(self.verticalCenter >= startPoint && self.verticalCenter <= endPoint) {
            return i;
        }
    }
    
    return -1;
}

-(BOOL)isSpinning {
    return self.spinning;
}

@end
