//
//  ViewController.h
//  Savengr UI
//
//  Created by Lieu, Klein on 8/23/14.
//  Copyright (c) 2014 Constant Contact. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconEngine.h"

@interface HotAndColdViewController : UIViewController <PlayerDistanceDelegate>

@property (strong, nonatomic) BeaconEngine *beaconEngine;

- (void)startGame;

@end
