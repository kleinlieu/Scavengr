//
//  ViewController.h
//  Savengr UI
//
//  Created by Lieu, Klein on 8/23/14.
//  Copyright (c) 2014 Constant Contact. All rights reserved.
//

#import <UIKit/UIKit.h>

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
    PlayerIsColdColdColdCold
};

@protocol PlayerDistanceDelegate <NSObject>

- (void)playerDistanceToBeacon:(PlayerHotAndColdDistance)distance;

@end

@interface HotAndColdViewController : HotAndColdUIViewController

@property id<PlayerDistanceDelegate> delegate;

- (void)startGame;

@end
