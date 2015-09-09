//
//  ViewController.m
//  SlotMachine
//
//  Created by Jordan Jasinski on 08.09.2015.
//  Copyright (c) 2015 Jordan Jasinski. All rights reserved.
//

#import "ViewController.h"

#import "SITLSlotsView.h"

#import "SITLResultsTableViewCell.h"
#import "SITLClaimPrizeViewController.h"

@interface ViewController ()<UITableViewDataSource>

@property (nonatomic, weak) IBOutlet SITLSlotsView *slotsView;
@property (nonatomic, weak) IBOutlet UITableView *resultsTable;

@property (nonatomic, strong) NSMutableArray *results;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.results = [NSMutableArray array];
    
    [self.resultsTable registerNib:[UINib nibWithNibName:@"ResultsTableCellView" bundle:nil] forCellReuseIdentifier:@"ResultsTableViewCell"];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"wonSegue"]) {
        SITLClaimPrizeViewController *dvc = segue.destinationViewController;
        
        NSDictionary *currentResult = [self.slotsView currentResult];
        int prizeIndex = [[currentResult objectForKey:[NSNumber numberWithInt:0]] intValue];
        dvc.prizeImage = self.slotsView.items[prizeIndex];
    }
}

-(IBAction)startSpinning:(id)sender {

    UIButton *btn = sender;
    
    btn.enabled = NO;
    [self.slotsView startAndStopAfter:5 withCompletionBlock:^(BOOL won, NSDictionary *result) {
        [self.results insertObject:result atIndex:0];
        [self.resultsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
 
        if(won) {
            [self performSegueWithIdentifier:@"wonSegue" sender:self];
        }
        
        btn.enabled = YES;
    }];
}

#pragma mark - UITableViewDataSource implementation

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.results count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SITLResultsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultsTableViewCell" forIndexPath:indexPath];
    
    NSDictionary *resultSet = [self.results objectAtIndex:indexPath.row];
    
    int firstItemIndex = [[resultSet objectForKey:[NSNumber numberWithInt:0]] intValue];
    if(firstItemIndex >= 0) {
        cell.firstItemImage.image = self.slotsView.items[firstItemIndex];
    }
    
    int secondItemIndex = [[resultSet objectForKey:[NSNumber numberWithInt:1]] intValue];
    if(secondItemIndex >= 0) {
        cell.secondItemImage.image = self.slotsView.items[secondItemIndex];
    }

    int thirdItemIndex = [[resultSet objectForKey:[NSNumber numberWithInt:2]] intValue];
    if(thirdItemIndex >= 0) {
        cell.thirdItemImage.image = self.slotsView.items[thirdItemIndex];
    }
    
    return cell;
}

@end
