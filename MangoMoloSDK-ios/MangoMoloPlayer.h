//
//  ViewController.h
//  AVPlayerDemo
//
//  Created by Curiologix on 07/03/2017.
//  Copyright © 2017 AliRaza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@import GoogleInteractiveMediaAds;

@interface MangoMoloPlayer : UIView <IMAAdsLoaderDelegate, IMAAdsManagerDelegate, IMAContentPlayhead>
{
    id playbackObserver;
}
// class properties
@property(nonatomic, retain) UIViewController *superVC;
@property(nonatomic, weak) IBOutlet UIView *videoParentView;
@property (retain, nonatomic) IBOutlet UIView *videoControls;@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *videoParentFixedHeight;

@property (retain, nonatomic) IBOutlet UIView *videoPlayerView;
@property (retain, nonatomic) IBOutlet UIButton *btn_play;
@property (retain, nonatomic) IBOutlet UIButton *btn_fullScreen;
@property (retain, nonatomic) IBOutlet UILabel *lbl_currentTime;
@property (retain, nonatomic) IBOutlet UILabel *lbl_remainTime;
@property (retain, nonatomic) IBOutlet UISlider *progressBar;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, assign) BOOL isFindLocalVideoPath;
@property (nonatomic, assign) BOOL isNormalVideoPlaying;

// this is y value of player constrant
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *playerYConstraint;

// this is fixed height of player constrant
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *playerBottomConstraint;

@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *videoPlayerLayer;

#pragma mark local ads player Setup
@property(nonatomic, strong) AVPlayer *adPlayer;
@property(nonatomic, strong) AVPlayerLayer *adPlayerLayer;
@property (nonatomic, strong) NSTimer *updatePlayBackTimer;
@property (nonatomic, strong) NSTimer *updateAnalyticsTimer;
@property (nonatomic, strong) UITapGestureRecognizer *playerGesture;

@property (nonatomic, assign) int currentPlayingVideoTime;

@property(nonatomic, weak) IBOutlet UIView *adsVideoView;
@property(nonatomic, weak) IBOutlet UIView *adsControlsView;
@property (weak, nonatomic) IBOutlet UILabel *lbl_adsCount;
@property (weak, nonatomic) IBOutlet UIButton *btn_skip;

#pragma mark IMAAds Setup
// SDK
/// Entry point for the SDK. Used to make ad requests.
@property(nonatomic, strong) IMAAdsLoader *adsLoader;
// Container which lets the SDK know where to render ads.
@property(nonatomic, strong) IMAAdDisplayContainer *adDisplayContainer;
// Rendering settings for ads.
@property(nonatomic, strong) IMAAdsRenderingSettings *adsRenderingSettings;
/// Main point of interaction with the SDK. Created by the SDK as the result of an ad request.
@property(nonatomic, strong) IMAAdsManager *adsManager;

@property (nonatomic, retain) NSMutableArray *preAdList;
@property (nonatomic, retain) NSMutableArray *midAdList;
@property (nonatomic, retain) NSMutableArray *postAdList;

#pragma mark Sharing
@property (nonatomic, weak) IBOutlet UIButton *sharing;
@property (nonatomic, retain) NSArray *sharingContent;

#pragma mark MangoMolo instance methods
-(BOOL)checkGeoBlockingWithCountryCode:(NSString *)countryCode geoStatus:(NSString *)geoStatus geoCountry:(NSString *)geoCountry;
-(void)setupPlayerWithStreamingPath:(NSString *) videoPath;
-(void)setupPreAds:(NSMutableArray *)preAds midAds:(NSMutableArray *)midAds postAds:(NSMutableArray *)postAds;
-(void)setupAnalytics:(NSString *)userID channelID:(NSString *)channelID videoID:(NSString *)videoID sessionID:(NSString *)sessionID device:(NSString *)device withAnalyticsPath:(NSString *)strPath;
- (void)setupObserveNotifications;
@end

