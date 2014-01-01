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

- (void) prepareForReuse
{
    _modeButton=nil;
    _name.text=@"";
    _value.text=@"";
}

@end
