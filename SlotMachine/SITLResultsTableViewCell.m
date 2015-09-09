//
//  SITLResultsTableViewCell.m
//  SlotMachine
//
//  Created by Jordan Jasinski on 08.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import "SITLResultsTableViewCell.h"

@implementation SITLResultsTableViewCell

-(void)prepareForReuse {
    self.firstItemImage.image = nil;
    self.secondItemImage.image = nil;
    self.thirdItemImage.image = nil;
}

@end
