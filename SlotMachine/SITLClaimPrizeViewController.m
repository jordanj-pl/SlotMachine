//
//  SITLClaimPrizeViewController.m
//  SlotMachine
//
//  Created by Jordan Jasinski on 09.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import "SITLClaimPrizeViewController.h"

@interface SITLClaimPrizeViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *prizeImageView;

@end

@implementation SITLClaimPrizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.prizeImageView.image = self.prizeImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
