//
//  BeaconEngine.h
//  Sccavngr
//
//  Created by Kluyt, Onno on 8/23/14.
//  Copyright (c) 2014 Kluyt, Onno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESTBeaconManager.h"

typedef NS_ENUM(NSInteger, PlayerHotAndColdDistance) {
    PlayerHasArrived = 0,
    PlayerIsHotHotHotHot,
    PlayerIsHotHotHot,
    PlayerIsHotHot,
    PlayerIsHot,
    PlayerIsNeutral,
    PlayerIsCold,
    PlayerIsColdCold,
    PlayerIsColdColdCold,
    PlayerIsColdColdColdCold,
    PlayerIsUnKnown
};


@protocol PlayerDistanceDelegate <NSObject>

- (void)playerDistanceToBeacon:(int)number withDistance:(PlayerHotAndColdDistance)distance;

@end

@interface BeaconEngine : NSObject <ESTBeaconManagerDelegate>

@property id<PlayerDistanceDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *beacons;
@property int order;
@property BOOL foundAll;
@property (nonatomic, strong) ESTBeacon         *beacon;
@property (nonatomic, strong) ESTBeaconManager  *beaconManager;
@property (nonatomic, strong) ESTBeaconRegion   *beaconRegion;

@property (nonatomic, strong) NSArray *ourBeacons;

- (void)setup;
- (void)doItAgain;

@end
