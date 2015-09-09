//
//  SITLSlotsView.m
//  SlotMachine
//
//  Created by Jordan Jasinski on 08.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import "SITLSlotsView.h"

#import "SITLSlotSpinner.h"

@interface SITLSlotsView ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *strips;
@property (nonatomic, strong) NSTimer *stopTimer;

@property (nonatomic, strong) NSMutableDictionary *currentResultDictionary;

@property (nonatomic, strong) SITLSlotsSpinningCompletionBlock completionBlock;

//positions and dimentions
@property (nonatomic, assign) CGFloat columnWidth;

@end

@implementation SITLSlotsView

#pragma mark - initializers

-(instancetype)initWithItems:(NSArray *)items {
    self = [super init];
    if(self) {
        _items = items;
        [self prepareComponent];
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        [self prepareComponent];
    }
    return self;

}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self prepareComponent];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self prepareComponent];
    }
    return self;
}

-(void)prepareComponent {
    self.clipsToBounds = YES;
    
    _items = [NSArray arrayWithObjects:[UIImage imageNamed:@"fruittype-avocado"], [UIImage imageNamed:@"fruittype-burrito"], [UIImage imageNamed:@"fruittype-skeleton"], nil];
    _currentResultDictionary = [NSMutableDictionary dictionary];
    
    if(_numberOfStrips == 0) {
        _numberOfStrips = 3;
    }
    
    NSMutableArray *strips = [NSMutableArray array];
    for (int i = 0; i < _numberOfStrips; i++) {
        SITLSlotSpinner *strip = [[SITLSlotSpinner alloc] initWithItems:_items andSelectedIndex:arc4random_uniform((int)[self.items count]-1)];
        
        [self addSubview:strip];
        [strips addObject:strip];
    }
    _strips = [NSArray arrayWithArray:strips];
    
    [self moveToInitialPosition];
}

#pragma mark - user interaction methods

-(void)startAndWaitForStopWithCompletionBlock:(SITLSlotsSpinningCompletionBlock)completionBlock {
    if([self isSpinning]) {
        return;
    }
    
    self.completionBlock = completionBlock;

    [self.currentResultDictionary removeAllObjects];

    for (SITLSlotSpinner *strip in self.strips) {
        [strip startWithVelocity:( arc4random() % 100 / 200.0 ) + 0.2];
    }
}

-(void)startAndStopAfter:(NSTimeInterval)timeInterval withCompletionBlock:(SITLSlotsSpinningCompletionBlock)completionBlock {
    
    if(self.stopTimer) {
        [self.stopTimer invalidate];
        self.stopTimer = nil;
    }
    
    self.stopTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(stop) userInfo:nil repeats:NO];
    
    [self startAndWaitForStopWithCompletionBlock:completionBlock];
}

-(void)stop {
    if(self.stopTimer) {
        [self.stopTimer invalidate];
        self.stopTimer = nil;
    }

    int subviewIndex = 0;
    for (SITLSlotSpinner *strip in self.strips) {
        [strip stopWithCompletionBlock:^(int result) {
            [self.currentResultDictionary setObject:[NSNumber numberWithInt:result] forKey:[NSNumber numberWithInt:subviewIndex]];
            
            if([self.currentResultDictionary count] == [self.strips count]) {
                if(self.completionBlock) {
                    
                    self.completionBlock([self currentResultWon], [self currentResult]);
                }
            }
        }];
        subviewIndex++;
    }
}

-(BOOL)isSpinning {
    
    for (SITLSlotSpinner *spinner in self.strips) {
        if(spinner.isSpinning) {
            return YES;
        }
    }
    
    return NO;
}

-(NSDictionary*)currentResult {
    return [NSDictionary dictionaryWithDictionary:self.currentResultDictionary];
}

-(BOOL)currentResultWon {
    __block BOOL result = NO;
    __block NSNumber *firstValue;
    [self.currentResultDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSNumber *value, BOOL *stop) {
        if(!firstValue) {
            firstValue = value;
        } else {
            if (![firstValue isEqualToNumber:value]) {
                result = NO;
                *stop = YES;
            } else {
                result = YES;
            }
        }
    }];
    return result;
}

-(NSArray*)items {
    return _items;
}

#pragma mark - prepare views

-(void)setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, 320.0f, 120.0f)];

    CGSize radii = CGSizeMake(15.0f, 15.0f);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:radii];
    
    CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
    [cornerMaskLayer setPath:path.CGPath];
    self.layer.mask = cornerMaskLayer;
    
    CAShapeLayer *strokeLayer = [CAShapeLayer layer];
    strokeLayer.path = path.CGPath;
    strokeLayer.fillColor = [UIColor clearColor].CGColor;
    strokeLayer.strokeColor = [UIColor blueColor].CGColor;
    strokeLayer.lineWidth = 5;
    
    [self.layer addSublayer:strokeLayer];
    
}

#pragma mark - animations and positioning

-(void)moveToInitialPosition {
    self.columnWidth = self.frame.size.width / self.numberOfStrips;

    int i = 0;
    for (SITLSlotSpinner *strip in self.strips) {
        [strip setFrame:CGRectMake(self.columnWidth * i, 3.0f, self.columnWidth, self.frame.size.height-6.0f)];

        i++;
    }
}

@end
