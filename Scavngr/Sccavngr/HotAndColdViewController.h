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
@protocol PlayerDistanceDelegate <NSObject>

- (void)playerDistanceToBeacon:(PlayerHotAndColdDistance)distance;

@end

@protocol DialogFinished <NSObject>
- (void)didFinish:(UIViewController *) viewController;

@end


@interface HotAndColdViewController : UIViewController<DialogFinished>

@property id<PlayerDistanceDelegate> delegate;
@property (strong, nonatomic) ViewController *onnoViewController;

- (void)startGame;


@end
