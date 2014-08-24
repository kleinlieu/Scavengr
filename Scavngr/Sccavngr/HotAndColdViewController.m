//
//  ViewController.m
//  Savengr UI
//
//  Created by Lieu, Klein on 8/23/14.
//  Copyright (c) 2014 Constant Contact. All rights reserved.
//

#import "HotAndColdViewController.h"
#import "SessionContainer.h"
#import "ProgressVC.h"
#import <HexColors/HexColor.h>

static NSString *kDefaultBackgroundColor = @"fff9c8";
static NSString *kThreeSecondBackgroundColor = @"ff4867";
static NSString *kTwoSecondBackgroundColor = @"ffa68f";
static NSString *kOneSecondBackgroundColor = @"83B8EB";
static NSString *kGoBackgroundColor = @"1187B2";
static NSString *kCountdownTextColor = @"ffffff";
static NSString *kPlayerHasArrived = @"45F269";
static NSString *kPlayerIsHotHotHotHot = @"B22139";
static NSString *kPlayerIsHotHotHot = @"FF4867";
static NSString *kPlayerIsHotHot = @"FF617C";
static NSString *kPlayerIsHot = @"FF97A2";
static NSString *kPlayerIsNeutral = @"f8b6bd";
static NSString *kPlayerIsCold = @"fbced3";
static NSString *kPlayerIsColdCold = @"fce1e4";
static NSString *kPlayerIsColdColdCold = @"faeff0";
static NSString *kPlayerIsColdColdColdCold = @"FFF8F8";

static NSString *kStartWord = @"Go!";
static int kStartTime = 3;

@interface HotAndColdViewController () <SessionContainerDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *countdownLabel;
@property (strong, nonatomic) UILabel *distanceDebug;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (strong, nonatomic) NSArray *countdownColors;
@property int countdownValue;
@property (retain, nonatomic) SessionContainer *sessionContainer;
@property (retain, nonatomic) NSMutableArray *transcripts;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipe;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) NSMutableArray *sampling;
@end

@implementation HotAndColdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Start view with default background color and loading indicator
    self.view.backgroundColor = [UIColor colorWithHexString:kDefaultBackgroundColor];
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingIndicator.frame = self.view.frame;
    [_loadingIndicator startAnimating];
    [self.view addSubview:_loadingIndicator];

    // Default value
    _countdownValue = kStartTime;

    // First item is text color, second item is background color
    // The first item is the "GO" screen!
    _countdownColors = @[ @[ kCountdownTextColor, kGoBackgroundColor],
                          @[ kCountdownTextColor, kOneSecondBackgroundColor],
                          @[ kCountdownTextColor, kTwoSecondBackgroundColor],
                          @[ kCountdownTextColor, kThreeSecondBackgroundColor],];

    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapped:)];
    [self.view addGestureRecognizer:_tap];
    _swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(userSwiped:)];
    _swipe.direction = UISwipeGestureRecognizerDirectionRight;
    _swipe.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:_swipe];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userLongPress:)];
    [self.view addGestureRecognizer:_longPress];


    _beaconEngine = [[BeaconEngine alloc] init];
    _beaconEngine.delegate = self;
    
    [self createSession];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowLoseMessage:) name:@"SomeoneWon" object:nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    sleep(2.0);
    [self startGame];
}


- (void)userTapped:(id)sender
{
    NSLog(@"User Tapped!");

    // Send the message
    [self.sessionContainer sendMessage:@"hahahha"];

}



- (void) userLongPress:(id)sender {
    ProgressVC *progressVC = [[ProgressVC alloc] initWithNibName:nil bundle:nil];
    progressVC.delegate = self;
    [self presentViewController:progressVC animated:YES completion:nil];
}	

-  (void)userSwiped:(id)sender {
    ProgressVC *progressVC = [[ProgressVC alloc] initWithNibName:nil bundle:nil];
    progressVC.delegate = self;
    [self presentViewController:progressVC animated:YES completion:^{
        
    }];
}

- (void)didFinish:(UIViewController *) viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startGame
{
    _countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(updateCountdownLabel:)
                                           userInfo:nil
                                            repeats:YES ];
}

- (void)updateCountdownLabel:(id)sender
{
    NSString *currentBackgroundColor = _countdownColors[_countdownValue][1];
    NSString *currentTextColor = _countdownColors[_countdownValue][0];

    if (_countdownValue == kStartTime) {
        [_loadingIndicator stopAnimating];
        _countdownLabel = [[UILabel alloc] initWithFrame:self.view.frame];
        _countdownLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:48.0f];
        _countdownLabel.textAlignment = NSTextAlignmentCenter;
        _countdownLabel.text = [NSString stringWithFormat:@"%d", _countdownValue];
        --_countdownValue;
        [self.view addSubview:_countdownLabel];
    } else if (_countdownValue == 0) {
        [_countdownTimer invalidate];
        _countdownTimer = nil;
        _countdownLabel.text = kStartWord;
        [self startHotAndColdView];
    } else {
        _countdownLabel.text = [NSString stringWithFormat:@"%d", _countdownValue];
        --_countdownValue;
    }

    self.view.backgroundColor = [UIColor colorWithHexString:currentBackgroundColor];
    _countdownLabel.textColor = [UIColor colorWithHexString:currentTextColor];
}

- (void)startHotAndColdView
{
    [_loadingIndicator startAnimating];
    [_beaconEngine setup];

    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _countdownLabel.alpha = 0;
                     } completion:nil];

}

- (void)playerDistanceToBeacon:(int)number withDistance:(PlayerHotAndColdDistance)distance {
    NSString *currentBackgroundColor;

    if ([_loadingIndicator isAnimating])
        [_loadingIndicator stopAnimating];
    _countdownLabel.text = [NSString stringWithFormat:@"Beacon %d", number++];

    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _countdownLabel.alpha = 1;
                     } completion:nil];

    NSLog(@"View Controller's Distance: %d", (int)distance);

    switch (distance) {
        case PlayerIsCold:
            currentBackgroundColor = kPlayerIsCold;
            break;
        case PlayerIsColdCold:
            currentBackgroundColor = kPlayerIsColdCold;
            break;
        case PlayerIsColdColdCold:
            currentBackgroundColor = kPlayerIsColdColdCold;
            break;
        case PlayerIsColdColdColdCold:
            currentBackgroundColor = kPlayerIsColdColdColdCold;
            break;
        case PlayerIsHot:
            currentBackgroundColor = kPlayerIsHot;
            break;
        case PlayerIsHotHot:
            currentBackgroundColor = kPlayerIsHotHot;
            break;
        case PlayerIsHotHotHot:
            currentBackgroundColor = kPlayerIsHotHotHot;
            break;
        case PlayerIsHotHotHotHot:
            currentBackgroundColor = kPlayerIsHotHotHotHot;
            break;
        case PlayerHasArrived:
            currentBackgroundColor = kPlayerIsNeutral;
        default:
            break;
    }

    NSLog(@"Current background color: %@", currentBackgroundColor);

    if (currentBackgroundColor) {
        [UIView animateWithDuration:0.5 animations:^{
            self.view.backgroundColor = [UIColor colorWithHexString:currentBackgroundColor];
        }];
    }
}


- (void)createSession
{

    NSString *deviceString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    // Create the SessionContainer for managing session related functionality.
    self.sessionContainer = [[SessionContainer alloc] initWithDisplayName:deviceString serviceType:@"MyRoom"];
    // Set this view controller as the SessionContainer delegate so we can display incoming Transcripts and session state changes in our table view.
    _sessionContainer.delegate = self;
}

- (void)receivedTranscript:(Transcript *)transcript
{
    // Add to table view data source and update on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", transcript.message);

        if ([transcript.message isEqualToString:@"hahahha"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disabled!!" message:[NSString stringWithFormat:@"%@ interrupted you!", transcript.peerID] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else if ([transcript.message isEqualToString:@"You lose"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"YOU LOSE" message:@"Better luck next time!" delegate:nil cancelButtonTitle:@"Play Again" otherButtonTitles:nil];
            [alert show];
        }
    });
}

// Helper method for inserting a sent/received message into the data source and reload the view.
// Make sure you call this on the main thread
- (void)insertTranscript:(Transcript *)transcript
{
    // Add to the data source
    [_transcripts addObject:transcript];

//    // If this is a progress transcript add it's index to the map with image name as the key
//    if (nil != transcript.progress) {
//        NSNumber *transcriptIndex = [NSNumber numberWithUnsignedLong:(_transcripts.count - 1)];
//        [_imageNameIndex setObject:transcriptIndex forKey:transcript.imageName];
//    }
//
//    // Update the table view
//    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:([self.transcripts count] - 1) inSection:0];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//
//    // Scroll to the bottom so we focus on the latest message
//    NSUInteger numberOfRows = [self.tableView numberOfRowsInSection:0];
//    if (numberOfRows) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
}

- (void)updateTranscript:(Transcript *)transcript
{
//    // Find the data source index of the progress transcript
//    NSNumber *index = [_imageNameIndex objectForKey:transcript.imageName];
//    NSUInteger idx = [index unsignedLongValue];
//    // Replace the progress transcript with the image transcript
//    [_transcripts replaceObjectAtIndex:idx withObject:transcript];
//
//    // Reload this particular table view row on the main thread
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
//        [self.tableView reloadRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ShowLoseMessage:(id)sender
{
    [self.sessionContainer sendMessage:@"You lose"];
}

@end
