//
//  SimpleTableCell.m
//  DubaiPost
//
//  Created by online on 5/9/17.
//  Copyright © 2017 com.twentyfourseven.emirates247. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell
{
    BOOL noImage;
    IBOutlet NSLayoutConstraint *constraintImageRight;
    IBOutlet NSLayoutConstraint *constraintImageBottom;
}

- (void)prepareForReuse
{
    _image.image = nil;
    _lblTitle.text = @"";
    _lblSummary.text = @"";
    _lblDate.text = @"";
    noImage = NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // we need to deactivate constraints (i.e. remove image) here to preserve cell layout on rotation
    [self updateImageConstraints];
}

- (void)setNoImage:(BOOL)value {
    noImage = value;
    [self updateImageConstraints];
}

- (void)updateImageConstraints {
    // ensure constraints has been loaded first
    if (!constraintImageRight || !constraintImageBottom)
        return;
    
    if (noImage) {
        [NSLayoutConstraint deactivateConstraints:@[constraintImageRight, constraintImageBottom]];
    } else {
        [NSLayoutConstraint activateConstraints:@[constraintImageRight, constraintImageBottom]];
    }
    _image.hidden = noImage;
}


@end
