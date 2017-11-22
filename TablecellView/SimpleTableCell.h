//
//  SimpleTableCell.h
//  DubaiPost
//
//  Created by online on 5/9/17.
//  Copyright © 2017 com.twentyfourseven.emirates247. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;

// "HeaderCell" specific
@property (strong, nonatomic) IBOutlet UIView *gradientView;
@property (strong, nonatomic) IBOutlet UILabel *lblHeadTitle;

// "Cell" specific
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblSummary;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;

- (void)setNoImage:(BOOL)noImage;
@end
