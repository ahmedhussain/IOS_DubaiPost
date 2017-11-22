//
//  ViewController.h
//  MangoMoloSDK-ios
//
//  Created by Curiologix on 08/05/2017.
//  Copyright © 2017 Dotcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MangoMoloPlayer.h"



@interface ViewController : UIViewController
{
    
    NSString *query;
    NSMutableArray *parsedItems;
    NSString *pageToken;
    NSDateFormatter *formatter;
    
    
    NSDictionary *jsonDict;
    
    
    UIButton *LanguageBtn;
    NSString *AutoPlay;
    
    ///ResizingTable
    
    CGRect frames,screenSize;
    CGFloat Screenwidth,ScreenHeight;
    
    
    
    //IPAD
    UILabel *articleTitle;
   // UILabel *articleDate;
  //  UILabel *articleduration;
    UILabel *articleAuthor;
    UIWebView *articleStory;
    
    
    
    
    
}

@property (nonatomic, retain) MangoMoloPlayer *player;


@property (nonatomic, strong) UITableView *contenttableView;


@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (strong, nonatomic) UIView *loadingView;

@end
