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
static NSString *kPlayerHasArrived = @"ffffff";
static NSString *kPlayerIsHotHotHotHot = @"B22139";
static NSString *kPlayerIsHotHotHot = @"FF4867";
static NSString *kPlayerIsHotHot = @"FF617C";
static NSString *kPlayerIsHot = @"FFB1BA";
static NSString *kPlayerIsNeutral = @"45F269";
static NSString *kPlayerIsCold = @"B5D1EB";
static NSString *kPlayerIsColdCold = @"83B8EB";
static NSString *kPlayerIsColdColdCold = @"1187B2";
static NSString *kPlayerIsColdColdColdCold = @"1187B2";

static NSString *kStartWord = @"Go!";
static int kStartTime = 3;

@interface HotAndColdViewController () <SessionContainerDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *loadingIndicator;
@property (strong, nonatomic) UILabel *countdownLabel;
@property (strong, nonatomic) NSTimer *countdownTimer;
@property (strong, nonatomic) NSArray *countdownColors;
@property int countdownValue;
@property (retain, nonatomic) SessionContainer *sessionContainer;
@property (retain, nonatomic) NSMutableArray *transcripts;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) UISwipeGestureRecognizer *swipe;

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

    _beaconEngine = [[BeaconEngine alloc] init];
    _beaconEngine.delegate = self;
    
    [self createSession]; 
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
    [_beaconEngine setup];
}

- (void)playerDistanceToBeacon:(int)number withDistance:(PlayerHotAndColdDistance)distance {
    NSString *currentBackgroundColor;

    _countdownLabel.text = [NSString stringWithFormat:@"Beacon %d", number];
    switch (distance) {
        case PlayerIsCold:
            currentBackgroundColor = kPlayerIsCold;
            break;
        case PlayerIsColdColdColdCold:
            currentBackgroundColor = kPlayerIsColdColdColdCold;
            break;
        case PlayerIsHotHotHot:
            currentBackgroundColor = kPlayerIsHotHotHot;
            break;
        case PlayerHasArrived:
            currentBackgroundColor = kPlayerHasArrived;
        default:
            currentBackgroundColor = kPlayerIsNeutral;
            break;
    }

    [UIView animateWithDuration:1.0 animations:^{
        self.view.backgroundColor = [UIColor colorWithHexString:currentBackgroundColor];
    }];
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

@end
