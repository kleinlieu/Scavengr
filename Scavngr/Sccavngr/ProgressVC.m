//
//  ProgressVCViewController.m
//  Scavngr
//
//  Created by Warner, Byron on 8/23/14.
//  Copyright (c) 2014 Warner, Byron. All rights reserved.
//

#import "ProgressVC.h"
#import "ProgressCell.h"
#import "ProgressHeaderView.h"
#import "ProgressUpdate.h"

#import "HotAndColdViewController.h"

@interface ProgressVC ()
{
    NSArray *testValues;
    NSTimer *timer;
}
@property (atomic) NSArray *sortedNames;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipe;
@end


                               
static NSString *CellIdentifier = @"ProgressCell";

@implementation ProgressVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _updates = [NSMutableDictionary new];
        _sortedNames = [NSArray new];
        testValues = @[
                                       @"Byron", @"1", @"Klein", @"1", @"Onno", @"1", @"Richard", @"1",
                                       @"Byron", @"2", @"Klein", @"1", @"Onno", @"2", @"Richard", @"2",
                                       @"Byron", @"3", @"Klein", @"2", @"Onno", @"3", @"Richard", @"2",
                                       @"Byron", @"4", @"Klein", @"2", @"Onno", @"4", @"Richard", @"2",
                                       @"Byron", @"5", @"Klein", @"3", @"Onno", @"4", @"Richard", @"2"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProgressHeaderView" owner:self options:nil];
    _progressHeader  = [nib objectAtIndex:0];
//    [[self tableView] registerClass:[ProgressCell class] forCellReuseIdentifier:CellIdentifier];  *
    UIView *newBackgroundView = [UIView new];
    newBackgroundView.backgroundColor = _progressHeader.backgroundColor = [UIColor grayColor];
    self.tableView.backgroundView = newBackgroundView;
    
    _swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwiped:)];
    _swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    _swipe.numberOfTouchesRequired = 2;
    [self.tableView addGestureRecognizer:_swipe];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(itsTime:) userInfo:nil repeats:YES];
}

- (void) itsTime: (NSTimer *) timer {
    static NSUInteger count  = 0;
    
    float d = [[testValues objectAtIndex:count+1] floatValue] / 5.0f;
    [self updateStatus:[testValues objectAtIndex:count]
              distance:d];
    count =  (count + 2) % [testValues count];
    
}

- (void) userSwiped:(id)sender {
    [_delegate didFinish:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateStatus:(NSString *)name distance:(float)distance {
    ProgressUpdate *pu  = [ProgressUpdate new];
    pu.playerName = name;
    pu.distance = distance;
    [_updates setObject:pu forKey:pu.playerName];
    _sortedNames = [[_updates allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_sortedNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ProgressCell *cell =  (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProgressCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSString *key = [_sortedNames objectAtIndex:indexPath.row];
    ProgressUpdate *pu = [_updates objectForKey:key];
    cell.name.text = pu.playerName;
    cell.progress.progress = pu.distance;
    cell.backgroundView = [UIView new];
    cell.backgroundView.backgroundColor = [UIColor clearColor];

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 61.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.progressHeader;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
