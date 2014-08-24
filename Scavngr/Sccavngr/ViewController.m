//
//  ViewController.m
//  Sccavngr
//
//  Created by Kluyt, Onno on 8/23/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *beacons;
@property int order;
@property BOOL foundAll;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    /*
     * BeaconManager setup.
     */
    NSDictionary *dict1 = [NSDictionary dictionaryWithObjects:@[@"57286", @"40884"] forKeys:@[@"major", @"minor"]];
    NSDictionary *dict2 = [NSDictionary dictionaryWithObjects:@[@"19735", @"9339"] forKeys:@[@"major", @"minor"]];
    NSDictionary *dict3 = [NSDictionary dictionaryWithObjects:@[@"16243", @"46353"] forKeys:@[@"major", @"minor"]];
    NSDictionary *dict4 = [NSDictionary dictionaryWithObjects:@[@"57841", @"26897"] forKeys:@[@"major", @"minor"]];
    NSDictionary *dict5 = [NSDictionary dictionaryWithObjects:@[@"19577", @"44598"] forKeys:@[@"major", @"minor"]];
    NSDictionary *dict6 = [NSDictionary dictionaryWithObjects:@[@"35083", @"31984"] forKeys:@[@"major", @"minor"]];
    
    self.ourBeacons = @[dict1, dict2, dict3, dict4, dict5, dict6];
    _foundAll = NO;
    _order = 0;
    
    self.beacons = [[NSMutableArray alloc] init];
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
    self.beaconRegion = [[ESTBeaconRegion alloc] initWithProximityUUID:self.beacon.proximityUUID
                                                                 major:[self.beacon.major unsignedIntValue]
                                                                 minor:[self.beacon.minor unsignedIntValue]
                                                            identifier:@"RegionIdentifier"];
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"beacon"];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TO DO: do something, anything!
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_beacons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *beacon = [_beacons objectAtIndex:indexPath.row];
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"beacon" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"beacon"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@", [[beacon objectForKey:@"major"] stringValue], [[beacon objectForKey:@"minor"] stringValue]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f", [[beacon objectForKey:@"distance"] floatValue]];
    return cell;
}


#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    if (beacons.count > 0)
    {
        
        //        self.zoneLabel.text     = [self textForProximity:firstBeacon.proximity];
        //        self.imageView.image    = [self imageForProximity:firstBeacon.proximity];
    }
    
    if (!_foundAll) {
        for (ESTBeacon *b in beacons) {
            if ([self isOneOfOurs:b withOrder:_order]) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[b.major, b.minor, b.distance] forKeys:@[@"major", @"minor", @"distance"]];
                [_beacons addObject:dict];
            }
        }
    }
    [_tableView reloadData];
    if (_foundAll) {
        [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TADATADA!!" message:@"Found them all!!!" delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil];
        [alert show];
    }

}

- (BOOL)isOneOfOurs:(ESTBeacon *)beacon withOrder:(int)order {
    NSString *major = [beacon.major stringValue];
    NSString *minor = [beacon.minor stringValue];
    
    if (_order < [_ourBeacons count]) {
    NSDictionary *dict = [_ourBeacons objectAtIndex:order];
        if ([major isEqualToString:[dict objectForKey:@"major"]] && [minor isEqualToString:[dict objectForKey:@"minor"]]) {
            if (beacon.proximity == CLProximityImmediate) {
                _order++;
                if (order == 5) {
                    _foundAll = YES;
                }
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark -

- (NSString *)textForProximity:(CLProximity)proximity
{
    switch (proximity) {
        case CLProximityFar:
            return @"Far";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        default:
            return @"Unknown";
            break;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
