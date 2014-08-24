//
//  BeaconEngine.m
//  Sccavngr
//
//  Created by Kluyt, Onno on 8/23/14.
//  Copyright (c) 2014 Kluyt, Onno. All rights reserved.
//

#import "BeaconEngine.h"

@implementation BeaconEngine

#pragma mark - ESTBeaconManager delegate


- (void)setup {
    /*
     * BeaconManager setup.
     */
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjects:@[@"57286", @"40884", @"No", @"Unknown", @"-1.00"] forKeys:@[@"major", @"minor", @"found", @"proximity", @"distance"]];
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjects:@[@"19735", @"9339", @"No", @"Unknown", @"-1.00"] forKeys:@[@"major", @"minor", @"found", @"proximity", @"distance"]];
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjects:@[@"16243", @"46353", @"No", @"Unknown", @"-1.00"] forKeys:@[@"major", @"minor", @"found", @"proximity", @"distance"]];
    NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObjects:@[@"57841", @"26897", @"No", @"Unknown", @"-1.00"] forKeys:@[@"major", @"minor", @"found", @"proximity", @"distance"]];
    NSMutableDictionary *dict5 = [NSMutableDictionary dictionaryWithObjects:@[@"19577", @"44598", @"No", @"Unknown", @"-1.00"] forKeys:@[@"major", @"minor", @"found", @"proximity", @"distance"]];
    NSMutableDictionary *dict6 = [NSMutableDictionary dictionaryWithObjects:@[@"35083", @"31984", @"No", @"Unknown", @"-1.00"] forKeys:@[@"major", @"minor", @"found", @"proximity", @"distance"]];
    
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
    
}

- (void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    
    if (!_foundAll) {
        for (ESTBeacon *b in beacons) {
            [self isOneOfOurs:b withOrder:_order];
        }
    }
    if (_foundAll) {
        [self.beaconManager stopRangingBeaconsInRegion:self.beaconRegion];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TADA TADA!!" message:@"Found them all!!!" delegate:nil cancelButtonTitle:@"Yay!" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)isOneOfOurs:(ESTBeacon *)beacon withOrder:(int)order {
    NSString *major = [beacon.major stringValue];
    NSString *minor = [beacon.minor stringValue];
    int beaconNumber = _order;
    
    if (_order < [_ourBeacons count]) {
        NSMutableDictionary *dict = [_ourBeacons objectAtIndex:order];
        if ([major isEqualToString:[dict objectForKey:@"major"]] && [minor isEqualToString:[dict objectForKey:@"minor"]] && [[dict objectForKey:@"found"] isEqualToString:@"No"]) {
            [dict setValue:[self textForProximity:beacon.proximity] forKey:@"proximity"];
            [dict setValue:[beacon.distance stringValue] forKey:@"distance"];
            if (beacon.proximity == CLProximityImmediate && [beacon.distance floatValue] <= 0.10) {
                [dict setValue:@"Yes" forKey:@"found"];
                _order++;
                if (order == 5) {
                    _foundAll = YES;
                }
            }
            if ([[dict objectForKey:@"found"] isEqualToString:@"Yes"]) {
                [_delegate playerDistanceToBeacon:beaconNumber withDistance:PlayerHasArrived];
            }else{
                [_delegate playerDistanceToBeacon:beaconNumber withDistance:[self distanceIndicator:beacon.proximity]];
            }
        }
    }
}

#pragma mark -
- (PlayerHotAndColdDistance)distanceIndicator:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            return PlayerIsColdColdColdCold;
        case CLProximityFar:
            return PlayerIsCold;
        case CLProximityNear:
            return PlayerIsHotHotHot;
        case CLProximityImmediate:
            return PlayerIsHotHotHotHot;
    }
    return PlayerIsNeutral;
}

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

- (void)doItAgain {
    _order = 0;
    _beacons = [[NSMutableArray alloc] init];
    _foundAll = NO;
    [self.beaconManager startRangingBeaconsInRegion:self.beaconRegion];
}


@end
