//
//  ProcessCellTableViewCell.m
//  Scavngr
//
//  Created by Warner, Byron on 8/23/14.
//  Copyright (c) 2014 Warner, Byron. All rights reserved.
//

#import "ProgressCell.h"

@implementation ProgressCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
  }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
