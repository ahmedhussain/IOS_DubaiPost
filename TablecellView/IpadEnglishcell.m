//
//  IpadEnglishcell.m
//  MangoMoloSDK-ios
//
//  Created by online on 5/21/17.
//  Copyright © 2017 Dotcom. All rights reserved.
//

#import "IpadEnglishcell.h"

@implementation IpadEnglishcell
{ BOOL noImage;
    IBOutlet NSLayoutConstraint *constraintImageRight;
    IBOutlet NSLayoutConstraint *constraintImageBottom;
}

- (void)prepareForReuse
{
    _imgheader.image = nil;
    _lbltitle.text = @"";
    
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
    _imgheader.hidden = noImage;
}

@end

