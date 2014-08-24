//
//  ProgressVCViewController.h
//  Scavngr
//
//  Created by Warner, Byron on 8/23/14.
//  Copyright (c) 2014 Warner, Byron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressHeaderView.h"

@interface ProgressVC : UITableViewController

@property (strong) ProgressHeaderView IBOutlet *progressHeader;
@property (strong) NSMutableDictionary *updates;


@end
