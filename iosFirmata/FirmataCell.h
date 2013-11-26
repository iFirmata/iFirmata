//
//  FirmataCell.h
//  iosFirmata
//
//  Created by Jacob on 11/25/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirmataCell : UITableViewCell

@property (strong, nonatomic) UIButton* modeButton;
@property (strong, nonatomic) UILabel* value;

- (void)setButton:(UIButton*)button;
- (void)setButtonTitle:(NSString*)title;

@end
