//
//  FirmataCell.m
//  iosFirmata
//
//  Created by Jacob on 11/25/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import "FirmataCell.h"

@implementation FirmataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setButton:(UIButton*)button
{
    _modeButton = button;
    [super.contentView addSubview:_modeButton];
}

- (void)setButtonTitle:(NSString*)title
{
    [_modeButton setTitle:title forState:UIControlStateNormal];
}

- (void) prepareForReuse{
    [[super detailTextLabel] setText:nil];

}

@end
