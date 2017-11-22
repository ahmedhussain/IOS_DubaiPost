//
//  ViewController.m
//  AVPlayerDemo
//
//  Created by Curiologix on 07/03/2017.
//  Copyright © 2017 AliRaza. All rights reserved.
//

#import "MangoMoloPlayer.h"

#define PlayerYPosition  66
#define PlayerHeight     250

@interface MangoMoloPlayer ()
{
    NSString *liveStreamingPath;
    NSString *analyticsPath;
    NSString *analyticsPostPostParameters;
}
@end

@implementation MangoMoloPlayer


#pragma mark check geo blocking for curren streaming
-(BOOL)checkGeoBlockingWithCountryCode:(NSString *)countryCode geoStatus:(NSString *)geoStatus geoCountry:(NSString *)geoCountry
{
    // check here video is allowed in your country or not based on your geo statu
    
    if ((geoStatus != (id)[NSNull null] && geoStatus.length > 0) &&(geoCountry != (id)[NSNull null] && geoCountry.length > 0))
    {
        if ([geoStatus isEqualToString:@"allowed"] && ![geoCountry containsString:countryCode])
        {
            [self videoIsNotAllowedToPlayInYourCountry];
            return false;
        } else if ([geoStatus isEqualToString:@"not_allowed"] && (countryCode != (id)[NSNull null] && [geoCountry containsString:countryCode]))
        {
            [self videoIsNotAllowedToPlayInYourCountry];
            return false;
        } else
        {
            return true;
        }
    }
    
    return true;
}

-(void)videoIsNotAllowedToPlayInYourCountry
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"هذا المحتوى غير مسموح في بلدك" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertC presentViewController:self.superVC animated:YES completion:nil];
}

- (void)setupObserveNotifications {
    // here we will setup the video player with paramter video path
    
    // here we set the notification on changing the device orientation
    UIDevice *device = [UIDevice currentDevice];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification
             object:device];
    
    self.updatePlayBackTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePlaybackProgressFromTimer:) userInfo:nil repeats:YES];
}

#pragma mark Load all local and Google intereactive media ads
-(void)setupPreAds:(NSMutableArray *)preAds midAds:(NSMutableArray *)midAds postAds:(NSMutableArray *)postAds
{
    self.preAdList = [NSMutableArray new];
    self.midAdList = [NSMutableArray new];
    self.postAdList = [NSMutableArray new];
    
    self.preAdList = preAds;
    self.midAdList = midAds;
    self.postAdList = postAds;
    
}

#pragma mark Setup Player With Streaming Path
#pragma mark Setup Player With Streaming Path
-(void)setupPlayerWithStreamingPath:(NSString *) videoPath
{
    liveStreamingPath = videoPath;
    
    [self resetAllPlayer];
    
    if (self.preAdList.count > 0)
    {
        [self setupPlayingAds:self.preAdList];
    } else
    {
        [self playerStreamingNow:videoPath];
    }
}

-(void)playerStreamingNow:(NSString *) videoPath
{
    self.isNormalVideoPlaying = true;
    
    [self.indicator startAnimating];
    
    CGRect frame = CGRectMake(0, 0, self.videoPlayerView.frame.size.width, self.videoPlayerView.frame.size.height);
    
    _playerItem = [AVPlayerItem playerItemWithURL:[[NSURL alloc] initWithString:videoPath]];
    
    self.videoPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    self.videoPlayerLayer  = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    
    // here we set the player gravity to keep aspect ratio
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.videoPlayerLayer setFrame:frame];
    
    // add player layer top of video parent view
    [self.videoPlayerView.layer addSublayer:self.videoPlayerLayer];
    
    [self.videoPlayer play];
    
    // add gesture on player
    self.playerGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHidePlayer)];
    [self.videoPlayerView addGestureRecognizer:self.playerGesture];
    
    // bring video controls and indicator to front of video parent view
    [self.videoPlayerView bringSubviewToFront:self.videoControls];
    
    [self.btn_play setImage:[UIImage imageNamed:@"paus"] forState:UIControlStateNormal];
    
    // you can uncomment below code if you are not playing live channel
    
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(self) weakself = self;
    playbackObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (weakself.videoPlayer.currentItem.asset.duration, weakself.videoPlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) weakself.videoPlayer.currentTime.value / (double) endTime.value;
            weakself.progressBar.value = normalizedTime;
        }
        
        CMTime subtract = CMTimeSubtract(weakself.videoPlayer.currentItem.asset.duration,weakself.videoPlayer.currentTime);
        
        NSString *currentTime = [weakself getStringFromCMTime:weakself.videoPlayer.currentTime];
        NSString *remaingTime = [weakself getStringFromCMTime:subtract];
        
        weakself.lbl_currentTime.text = currentTime;
        weakself.lbl_remainTime.text = remaingTime;
    }];
    
    // here setup up action of progress bard
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.progressBar addTarget:self action:@selector(proressBarChangeEnded:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // here we check the video state if video is ready to play or not
    /*[self.videoPlayer.currentItem addObserver:self
     forKeyPath:@"status"
     options:NSKeyValueObservingOptionNew
     context:nil];*/
}

#pragma mark Setup Aanalytics
-(void)setupAnalytics:(NSString *)userID channelID:(NSString *)channelID videoID:(NSString *)videoID sessionID:(NSString *)sessionID device:(NSString *)device withAnalyticsPath:(NSString *)strPath
{
    NSData* userIdData = [userID dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedUserID = [userIdData base64EncodedStringWithOptions:0];
    
    NSLog(@"Channel ID = %@",channelID);
    NSLog(@"Video ID = %@",userID);
    
    NSData* channelIdData = [channelID dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedChannelID = [channelIdData base64EncodedStringWithOptions:0];
    
    NSString *parametrs =[NSString stringWithFormat:@"userid=%@&browserOS=ios&videoid=%@&channelid=%@&sessionid=%@&domain=&device=%@",base64EncodedUserID,videoID,base64EncodedChannelID,sessionID,device, nil];
    
    analyticsPath = strPath;
    analyticsPostPostParameters = parametrs;
    
    // every after 10 seconds anaytlics update call request to update anaytlics status
    self.updateAnalyticsTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateAnalyticsRequest) userInfo:nil repeats:YES];
}

-(void)updateAnalyticsRequest
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:analyticsPath]];
    
    //create the Method "GET" or "POST"
    [urlRequest setHTTPMethod:@"POST"];
    
    //Convert the String to Data
    NSData *data1 = [analyticsPostPostParameters dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [urlRequest setHTTPBody:data1];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"The response is - %@",responseDictionary);
        }
        else
        {
            NSLog(@"Error analytics");
        }
    }];
    [dataTask resume];
}

- (void)updatePlaybackProgressFromTimer:(NSTimer *)timer {
    //[self.video setScalingMode:MPMovieScalingModeFill];
    Float64 currentSeconds = CMTimeGetSeconds(self.videoPlayer.currentItem.currentTime);
    Float64 adSeconds = CMTimeGetSeconds(self.adPlayer.currentItem.currentTime);
    Float64 duration = CMTimeGetSeconds(self.videoPlayer.currentItem.duration);
    int videotime = currentSeconds;
    int adtime = adSeconds;
    
    if (videotime > 0 || adtime > 0) {
        
        if (self.isFindLocalVideoPath) {
            if (adtime > 0) {
                if (adtime <= 5) {
                    int adTime = 5 - adtime;
                    self.lbl_adsCount.text = [NSString stringWithFormat:@"You can skip this ad in (%d seconds)",adTime];
                }
                
                if (adtime >= 5) {
                    self.lbl_adsCount.hidden = YES;
                    self.btn_skip.hidden = NO;
                }
            }
        }
        
        if (self.preAdList.count > 0)
        {
            Float64 duration = CMTimeGetSeconds(self.videoPlayer.currentItem.duration);
            if (videotime > 0 && duration > 0)
            {
                self.currentPlayingVideoTime = videotime;
                if(videotime > [[self.preAdList[0] valueForKey:@"duration"] intValue]){
                    [self.videoPlayer pause];
                    [self setupPlayingAds:self.preAdList];
                }
            }
        }
        
        if (self.midAdList.count > 0 && self.preAdList.count == 0)
        {
            Float64 duration = CMTimeGetSeconds(self.videoPlayer.currentItem.duration);
            if (videotime > 0 && duration > 0)
            {
                self.currentPlayingVideoTime = videotime;
                if(videotime > [[self.midAdList[0] valueForKey:@"duration"] intValue]){
                    [self.videoPlayer pause];
                    [self setupPlayingAds:self.midAdList];
                }
            }
        }
        
        
        if (self.postAdList.count > 0 && self.preAdList.count == 0 && self.midAdList.count == 0)
        {
            Float64 duration = CMTimeGetSeconds(self.videoPlayer.currentItem.duration);
            if (videotime > 0 && duration > 0)
            {
                self.currentPlayingVideoTime = videotime;
                if(videotime > [[self.postAdList[0] valueForKey:@"duration"] intValue]){
                    [self.videoPlayer pause];
                    [self setupPlayingAds:self.postAdList];
                }
            }
        }
        
        [self didChangeValueForKey:@"currentTime"];
    }
}

#pragma mark Setup Local Ads
- (void)playLocalAdNow:(NSString *)localAdPath
{
    self.videoPlayerView.hidden = YES;
    [self.adPlayerLayer removeFromSuperlayer];
    self.adsVideoView.hidden = NO;
    
    [self.videoPlayer pause];
    
    NSURL *url = [[NSURL alloc] initWithString:localAdPath];
    
    CGRect frame = CGRectMake(0, 0, self.adsVideoView.frame.size.width, self.adsVideoView.frame.size.height);
    self.adsVideoView.frame = frame;
    [self.adsVideoView setBackgroundColor: [UIColor blackColor]];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    
    self.adPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    self.adPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.adPlayer];
    [self.adPlayerLayer setFrame:frame];
    [self.adsVideoView.layer addSublayer:self.adPlayerLayer];
    [self.adsVideoView bringSubviewToFront:self.adsControlsView];
    [self.adPlayer play];
}

-(IBAction)playVideo:(UIButton *)button
{
    if (self.videoPlayer.rate == 1.0) {
        [self.videoPlayer pause];
        [button setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    } else {
        [self.videoPlayer play];
        [button setImage:[UIImage imageNamed:@"paus"] forState:UIControlStateNormal];
    }
}

// the observ function will call automatically when video state is ready to play
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSLog(@"observeValueForKeyPath %@", keyPath);
    if ([keyPath isEqualToString:@"status"])
    {
        if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
            [self.indicator stopAnimating];
        }
    }
}

// show and hide player controler on based on touch device screen
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [(UITouch*)[touches anyObject] locationInView:self];
    if ([self pointInside:point withEvent:event] || UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
        if (self.videoControls.hidden == false) {
            self.videoControls.hidden = YES;
        } else {
            self.videoControls.hidden = NO;
        }
    }
}

-(void)showHidePlayer
{
    if (self.videoControls.hidden == false) {
        self.videoControls.hidden = YES;
    } else {
        self.videoControls.hidden = NO;
    }
}

-(NSString*)getStringFromCMTime:(CMTime)time
{
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}

-(void)progressBarChanged:(UISlider*)sender
{
    [self.videoPlayer pause];
    NSLog(@"slider value: %f",sender.value);
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.videoPlayer.currentItem.asset.duration.value/(double)self.videoPlayer.currentItem.asset.duration.timescale, self.videoPlayer.currentTime.timescale);
    [self.videoPlayer seekToTime:seekTime];
    
}

-(void)proressBarChangeEnded:(UISlider*)sender
{
    [self.videoPlayer play];
}

-(IBAction)skipAdsVideo:(id)sender
{
    [self setupNextVideo];
}

#pragma mark Local Ads Setup
-(void)setupNextVideo
{
    self.lbl_adsCount.text = [NSString stringWithFormat:@"You can skip this ad in (5 seconds)"];
    self.lbl_adsCount.hidden = NO;
    self.btn_skip.hidden = YES;
    
    [self.adPlayer pause];
    self.adPlayer = nil;
    [self.adPlayerLayer removeFromSuperlayer];
    self.adsVideoView.hidden = YES;
    self.videoPlayerView.hidden = NO;
    
    if (self.preAdList.count > 0) {
        [self setupPlayingAds:self.preAdList];
    } else  if (self.midAdList.count > 0) {
        [self setupPlayingAds:self.midAdList];
    } else if (self.postAdList.count > 0) {
        [self setupPlayingAds:self.postAdList];
    } else {
        [self removeLocalAdsSetupFromSuperView];
        [self adsPlaingFinishedNowPlayNormalVideo];
    }
}

#pragma mar Setup ads request
-(void)setupPlayingAds:(NSMutableArray *)adsList
{
    if (adsList.count > 0)
    {
        int tag = [self checkAddType:adsList];
        
        if (![self checkVideoDuration:adsList])
        {
            [self removeLocalAdsSetupFromSuperView];
            [self adsPlaingFinishedNowPlayNormalVideo];
            return;
        }
        
        if (tag == 1)
        {
            self.isFindLocalVideoPath = true;
            [self playLocalAdNow:[NSString stringWithFormat:@"http://%@",[adsList[0] valueForKey:@"m3u8"]]];
            [adsList removeObjectAtIndex:0];
        } else if (tag == 2)
        {
            self.isFindLocalVideoPath = false;
            [self requestAdsPre:[adsList[0] valueForKey:@"google_doubleclick"]];
            [adsList removeObjectAtIndex:0];
        }
    }
}

-(void)adsPlaingFinishedNowPlayNormalVideo
{
    if (self.isNormalVideoPlaying) {
        [self.videoPlayer play];
    } else {
        [self playerStreamingNow:liveStreamingPath];
    }
}

-(BOOL)checkVideoDuration:(NSMutableArray *)adsList
{
    for (NSDictionary *dic in adsList)
    {
        if (self.currentPlayingVideoTime >= [[dic valueForKey:@"duration"] intValue])
        {
            return true;
        }
    }
    
    return false;
}

-(int)checkAddType:(NSMutableArray *)adData
{
    for (NSDictionary *dic in adData)
    {
        if ([dic valueForKey:@"ad_type"])
        {
            if ([[dic valueForKey:@"ad_type"] isEqualToString:@"local_server"])
            {
                return 1;
            } else if ([[dic valueForKey:@"ad_type"] isEqualToString:@"double_click"])
            {
                return 2;
            }
        }
    }
    
    return 0;
}

- (void)requestAdsPre:(NSString *)url {
    
    [self.videoPlayer pause];
    
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    self.adsLoader.delegate = self;
    
    self.adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.videoPlayerView companionSlots:nil];
    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request =
    [[IMAAdsRequest alloc]initWithAdTagUrl:url adDisplayContainer:self.adDisplayContainer contentPlayhead:nil userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
}

- (void)createAdsRenderingSettings {
    self.adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    self.adsRenderingSettings.webOpenerPresentingController = self.superVC;
}

#pragma mark AdsLoader Delegates
- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    // Create ads rendering settings to tell the SDK to use the in-app browser.
    [self createAdsRenderingSettings];
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:self.adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"Error loading ads: %@", adErrorData.adError.message);
    // we get here live streaming path bcs we have only pre ads for live channel
    [self adsPlaingFinishedNowPlayNormalVideo];
}

#pragma mark AdsManager Delegates
- (void)adsManager:(IMAAdsManager *)adsManager
 didReceiveAdEvent:(IMAAdEvent *)event {
    // When the SDK notified us that ads have been loaded, play them.
    if (event.type == kIMAAdEvent_LOADED) {
        [adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager
 didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    NSLog(@"AdsManager error: %@", error.message);
    
    // we get here live streaming path bcs we have only pre ads for live channel
    [self adsPlaingFinishedNowPlayNormalVideo];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [self.videoPlayer pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    NSLog(@"CONTENT RESUME");
    // we get here live streaming path bcs we have only pre ads for live channel
    [self adsPlaingFinishedNowPlayNormalVideo];
}

- (void)orientationChanged:(NSNotification *)note
{
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        CGRect bound = [UIScreen mainScreen].bounds;
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) || bound.size.width > bound.size.height)
        {
            [self setupFullScreen];
        } else
        {
            [self setupSmallScreen];
        }
        
    }else
    {
        
        /*   NSString *CheckHeight = [[NSUserDefaults standardUserDefaults]
         stringForKey:@"CheckHeight"];
         
         NSLog(@"FULLLSCREEEN CheckHeight  %@", CheckHeight);
         
         if([CheckHeight isEqual: @"IpadFullScreen"])
         {
         
         [self SetUpIpadScreen];
         }else
         {
         
         [self setupFullScreen];
         }*/
        
        
    }
    
}

-(IBAction)fullScreen:(UIButton *)sender
{
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || orientation == 0 || [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown)
        {
            [self setupFullScreen];
        } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft)
        {
            [self setupSmallScreen];
        }
    }else
    {
        NSString *CheckHeight = [[NSUserDefaults standardUserDefaults]
                                 stringForKey:@"CheckHeight"];
        
        NSLog(@"FULLLSCREEEN CheckHeight   %@", CheckHeight);
        
        if([CheckHeight isEqual: @"IpadFullScreen"])
        {
            
            [self SetUpIpadScreen];
        }else
        {
            
            
            
            [self setupFullScreen];
        }
    }
    
}

-(void)SetUpIpadScreen
{
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    if (self.isFindLocalVideoPath) {
        self.adPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self addSubview:self.adsVideoView];
    } else {
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self addSubview:self.videoPlayerView];
        [self.btn_fullScreen setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
    }
    
    [self updateIPADPlayerHeight];
    
    [self.btn_fullScreen setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
}

-(void)updateIPADPlayerHeight
{
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGRect bound = self.frame;
    
    //  CGFloat newHeight = screenSize.size.height - 350;
    //  CGFloat newHeight = 450;
    
    CGFloat ration = (screenSize.size.height - 150) / (screenSize.size.width - 200) ;
    
    
    CGFloat newHeight = (screenSize.size.height - 150) * ration;
    
    
    
    
    NSString *Valueheight = @"Ipaddefault";
    
    NSLog(@"FULLLSCREEEN %@", Valueheight);
    [[NSUserDefaults standardUserDefaults] setObject:Valueheight forKey:@"CheckHeight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // CGFloat ration = screenSize.size.width / screenSize.size.height;
    //CGFloat newHeight = bound.size.width * ration;
    
    CGRect frame;
    
    if (self.isFindLocalVideoPath && self.adsVideoView.hidden == NO) {
        if (newHeight > 0) {
            self.videoParentFixedHeight.constant = newHeight;
            
            frame = self.adsVideoView.frame;
            frame.origin.x = 50;
            frame.origin.y = 0;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self.adsVideoView setFrame:frame];
            [self.adPlayerLayer setFrame:frame];
            
            frame = self.frame;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self setFrame:frame];
        }
        self.adPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    } else {
        if (newHeight > 0) {
            self.videoParentFixedHeight.constant = newHeight;
            
            frame = self.videoPlayerView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self.videoPlayerView setFrame:frame];
            [self.videoPlayerLayer setFrame:frame];
            
            frame = self.frame;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self setFrame:frame];
        }
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResize;
    }
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = YES;
    frame = self.loadingIndicator.frame;
    frame.origin.x = self.videoPlayerView.frame.size.width / 2 - 10;
    frame.origin.y = self.videoPlayerView.frame.size.height / 2 - 10;
    self.loadingIndicator.frame = frame;
}

-(void)setupFullScreen
{
    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSNumber *valueLeft = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        valueLeft = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
        valueLeft = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    }
    
    [[UIDevice currentDevice] setValue:valueLeft forKey:@"orientation"];
    
    if (self.isFindLocalVideoPath && self.adsVideoView.hidden == NO)
    {
        self.adsVideoView.translatesAutoresizingMaskIntoConstraints = YES;
        [_superVC.view addSubview:self.adsVideoView];
        CGRect vidFrame = self.adsVideoView.frame;
        vidFrame.origin.x = 0;
        vidFrame.origin.y = 0;
        vidFrame.size.width = _superVC.view.frame.size.width;
        vidFrame.size.height = _superVC.view.frame.size.height;
        self.adsVideoView.frame = vidFrame;
        [self.adPlayerLayer setFrame:vidFrame];
    } else
    {
        self.videoPlayerView.translatesAutoresizingMaskIntoConstraints = YES;
        [_superVC.view addSubview:self.videoPlayerView];
        CGRect vidFrame = self.videoPlayerView.frame;
        vidFrame.origin.x = 0;
        vidFrame.origin.y = 0;
        vidFrame.size.width = _superVC.view.frame.size.width;
        vidFrame.size.height = _superVC.view.frame.size.height;
        self.videoPlayerView.frame = vidFrame;
        [self.videoPlayerLayer setFrame:vidFrame];
        
        self.videoPlayerView.hidden = NO;
        
        [self.btn_fullScreen setImage:[UIImage imageNamed:@"small_screen"] forState:UIControlStateNormal];
        
        NSString *Valueheight = @"IpadFullScreen";
        [[NSUserDefaults standardUserDefaults] setObject:Valueheight forKey:@"CheckHeight"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame = self.loadingIndicator.frame;
    frame.origin.x = self.videoPlayerView.frame.size.width / 2 - 10;
    frame.origin.y = self.videoPlayerView.frame.size.height / 2 - 10;
    self.loadingIndicator.frame = frame;
}

-(void)setupSmallScreen
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    if (self.isFindLocalVideoPath) {
        self.adPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self addSubview:self.adsVideoView];
    } else {
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        [self addSubview:self.videoPlayerView];
        [self.btn_fullScreen setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
    }
    
    [self updatePlayerHeight];
    
    [self.btn_fullScreen setImage:[UIImage imageNamed:@"full_screen"] forState:UIControlStateNormal];
}

-(void)updatePlayerHeight
{
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGRect bound = self.frame;
    CGFloat ration = screenSize.size.width / screenSize.size.height;
    CGFloat newHeight = bound.size.width * ration;
    
    CGRect frame;
    
    if (self.isFindLocalVideoPath && self.adsVideoView.hidden == NO) {
        if (newHeight > 0) {
            self.videoParentFixedHeight.constant = newHeight;
            
            frame = self.adsVideoView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self.adsVideoView setFrame:frame];
            [self.adPlayerLayer setFrame:frame];
            
            frame = self.frame;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self setFrame:frame];
        }
        self.adPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    } else {
        if (newHeight > 0) {
            self.videoParentFixedHeight.constant = newHeight;
            
            frame = self.videoPlayerView.frame;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self.videoPlayerView setFrame:frame];
            [self.videoPlayerLayer setFrame:frame];
            
            frame = self.frame;
            frame.size.width = bound.size.width;
            frame.size.height = newHeight;
            [self setFrame:frame];
        }
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = YES;
    frame = self.loadingIndicator.frame;
    frame.origin.x = self.videoPlayerView.frame.size.width / 2 - 10;
    frame.origin.y = self.videoPlayerView.frame.size.height / 2 - 10;
    self.loadingIndicator.frame = frame;
}

-(IBAction)shareVideoOnSocialMedia:(UIButton *)sender
{
    if (self.sharingContent.count > 0)
    {
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:self.sharingContent applicationActivities:nil];
        
        activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypePostToWeibo];
        
        
        //if iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.superVC presentViewController:activityVC animated:TRUE completion:nil];
        }
        //if iPad
        else {
            // Change Rect to position Popover
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
            [popup presentPopoverFromRect:sender.superview.frame inView:self.superVC.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

-(void)resetAllPlayer
{
    [self removeIEMAdsContainerFromSuperView];
    [self removeLocalAdsSetupFromSuperView];
    [self removeNormalVideoPlayer];
}

-(void)removeIEMAdsContainerFromSuperView
{
    [self.adsManager pause];
    self.adsManager = nil;
    self.adDisplayContainer = nil;
}

-(void)removeLocalAdsSetupFromSuperView
{
    self.isFindLocalVideoPath = false;
    self.adsVideoView.hidden = YES;
    self.videoPlayerView.hidden = NO;
    [self.adPlayer pause];
    self.adPlayer = nil;
    [self.adPlayerLayer removeFromSuperlayer];
    self.adPlayerLayer = nil;
}

-(void)removeNormalVideoPlayer
{
    [self.videoPlayer pause];
    [self.videoPlayerLayer removeFromSuperlayer];
    self.videoPlayer = nil;
    self.lbl_currentTime.text = @"00:00";
    self.lbl_remainTime.text = @"00:00";
    self.progressBar.value = 0.0;
}

@end
