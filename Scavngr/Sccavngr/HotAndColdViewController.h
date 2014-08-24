//
//  ViewController.h
//  Savengr UI
//
//  Created by Lieu, Klein on 8/23/14.
//  Copyright (c) 2014 Constant Contact. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BeaconEngine.h"

@protocol DialogFinished <NSObject>
- (void)didFinish:(UIViewController *) viewController;

@end

@interface HotAndColdViewController : UIViewController<DialogFinished, PlayerDistanceDelegate>

@property id<PlayerDistanceDelegate> delegate;
@property (strong, nonatomic) BeaconEngine *beaconEngine;

//@property (strong, nonatomic) ViewController *onnoViewController;

- (void)startGame;


@end
