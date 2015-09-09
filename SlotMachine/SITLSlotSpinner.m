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
        [self moveToInitialPositionWithItemCentered:arc4random_uniform((int)[self.subviews count]-1)];
    }

}

-(void)moveToInitialPositionWithItemCentered:(int)itemCentered {
    UIImageView *centeredItemView = self.subviews[itemCentered];

    self.itemSize = centeredItemView.frame.size;
    self.centeredPosition = self.verticalCenter-self.itemSize.height/2.0f;

    centeredItemView.frame = CGRectMake(centeredItemView.frame.origin.x, self.centeredPosition, self.itemSize.width, self.itemSize.height);
    centeredItemView.alpha = 1.0f;
    
    int firstItemIndex = itemCentered-1;
    if(firstItemIndex < 0) {
        firstItemIndex = (int)[self.subviews count]-1;
    }
    UIImageView *firstItemView = self.subviews[firstItemIndex];
    firstItemView.frame = CGRectMake(firstItemView.frame.origin.x, self.centeredPosition-self.itemSize.height, self.itemSize.width, self.itemSize.height);
    firstItemView.alpha = 0.5f;

    int lastIndex = (int)[self.subviews count]-1;
    int restItemsOffset = 2;
    int beginIterationIndex = itemCentered+1;
    if(itemCentered == 0) {
        lastIndex = (int)[self.subviews count]-2;
        restItemsOffset = 1;
    } else if(itemCentered == [self.subviews count]-1) {
        beginIterationIndex = 0;
        lastIndex = (int)[self.subviews count]-3;
        restItemsOffset = 0;
    }

    for (int i = beginIterationIndex; i <= lastIndex; i++) {
        UIImageView *itemView = self.subviews[i];
        itemView.frame = CGRectMake(itemView.frame.origin.x, self.centeredPosition+self.itemSize.height + self.itemSize.height*(i-restItemsOffset), self.itemSize.width, self.itemSize.height);
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
    CGFloat initialPosition = previousItemPosition+self.itemSize.height;
    
    element.frame = CGRectMake(element.frame.origin.x, initialPosition, self.itemSize.width, self.itemSize.height);

    CGFloat distanceToTravel = element.frame.origin.y + element.frame.size.height;
    NSTimeInterval duration = distanceToTravel*specificVelocity;

    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        element.frame = CGRectMake(element.frame.origin.x, 0.0f-self.itemSize.height, element.frame.size.width, element.frame.size.height);
    } completion:^(BOOL finished) {
        if(finished && self.spinning) {
            [self animateElement:element withSpecificVelocity:specificVelocity];
        }
    }];

    //TODO add keyframes to animate fading while spinning
/*
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            element.frame = CGRectMake(element.frame.origin.x, self.centeredPosition, element.frame.size.width, element.frame.size.height);
            element.alpha = 1.0f;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            element.frame = CGRectMake(element.frame.origin.x, 0.0f-self.itemSize.height, element.frame.size.width, element.frame.size.height);
            element.alpha = 0.5f;
        }];
        
    } completion:^(BOOL finished) {
        if(finished && self.spinning) {
            [self animateElement:element withSpecificVelocity:specificVelocity];
        }
    }];
*/
}

-(int)nearestStopPosition:(CGFloat)currentPosition {

    int distanceFromCenteeredItem = roundf(currentPosition)-self.centeredPosition;
    CGFloat positionShift = fmodf(distanceFromCenteeredItem, self.itemSize.height);
    int stopPosition = roundf(currentPosition);
    
    if(positionShift < self.itemSize.height/2) {
        stopPosition -= positionShift;
    } else {
        stopPosition += (self.itemSize.height - positionShift);
    }
    
    return stopPosition;
}

#pragma mark - widget interactions

-(void)startWithVelocity:(NSTimeInterval)velocity {

    if(self.spinning) {
        return;
    }
    
    self.spinning = YES;
    
    NSTimeInterval specificVelocity = velocity/self.frame.size.height;

    for (UIImageView *itemView in self.subviews) {
        CGFloat distanceToTravel = fabs(0.0f-itemView.frame.size.height - itemView.frame.origin.y);
        NSTimeInterval duration = distanceToTravel*specificVelocity;

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

    int currentItem = [self currentDynamicItem];

    [UIView animateWithDuration:2.0
                          delay:0.0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self moveToInitialPositionWithItemCentered:currentItem];
                     } completion:^(BOOL finished){
                         completionBlock(currentItem);
                     }
     ];
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

-(int)currentDynamicItem {
    NSUInteger numberOfItems = [self.subviews count];
    
    for (int i = 0; i < numberOfItems; i++) {
        UIImageView *item = self.subviews[i];
        CGFloat startPoint = ((CALayer *)item.layer.presentationLayer).frame.origin.y;
        CGFloat endPoint = ((CALayer *)item.layer.presentationLayer).frame.origin.y + item.frame.size.height;
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
