//
//  ProcessCellTableViewCell.h
//  Scavngr
//
//  Created by Warner, Byron on 8/23/14.
//  Copyright (c) 2014 Warner, Byron. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;


@end
