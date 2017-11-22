//
//  ViewController.m
//  MangoMoloSDK-ios
//
//  Created by Curiologix on 08/05/2017.
//  Copyright © 2017 Dotcom. All rights reserved.
//

#import "ViewController.h"

#import "AssistTableCell.h"
#import "SimpleTableCell.h"
#import "UIImageView+WebCache.h"


///IPAD
#import "IpadArabiccell.h"
#import "IpadEnglishcell.h"


#import "config.h"


#import "EMReachability.h"
#import "AppDelegate.h"

//Progress
#import "MBProgressHUD.h"

@interface ViewController ()

{
    
    UIActivityIndicatorView *spinner;
    UIActivityIndicatorView *IMGactivityIndicator;
    
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    { ///Set Screeen
        
        AutoPlay= @"1";
        frames = self.view.frame;
        screenSize = [UIScreen mainScreen].bounds;
        Screenwidth = screenSize.size.width;
        ScreenHeight =  screenSize.size.height;
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self AddNavigation];
            
            [self MangomoloPlayer];
            
            EMReachability *reachability = [EMReachability reachabilityWithHostname:@"media.dubaipost.ae"];
            reachability.reachableBlock = ^(EMReachability *reach) {
                ////Start
                
                [self fetchdata];
                
                
                if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
                {
                    
                    ////TableResize IPHONE
                    CGFloat ration = Screenwidth / ScreenHeight;
                    CGFloat newHeight = Screenwidth * ration;
                    _contenttableView = [[UITableView alloc] initWithFrame:CGRectMake(0,newHeight + 66, MIN(CGRectGetHeight(frames), CGRectGetWidth(frames)), 568)];
                    
                    _contenttableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    [_contenttableView setShowsVerticalScrollIndicator:NO];
                    
                    
                    [_contenttableView setDataSource:self];
                    [_contenttableView setDelegate:self];
                    
                    [self.view addSubview:_contenttableView];
                    ///
                    
                }
                else
                {
                    
                    ///TableResize IPAD
                    CGFloat tablePointX = Screenwidth - 202;
                    
                    _contenttableView = [[UITableView alloc] initWithFrame:CGRectMake(tablePointX,66, 202,ScreenHeight - 70)];
                    _contenttableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    [_contenttableView setShowsVerticalScrollIndicator:NO];
                    
                    
                    [_contenttableView setDataSource:self];
                    [_contenttableView setDelegate:self];
                    [self.view addSubview:_contenttableView];
                    ////
                    
                }
                [self.view setBackgroundColor:[UIColor whiteColor]];
                //END
                
                [reach stopNotifier];
            };
            reachability.unreachableBlock = ^(EMReachability *reach) {
                
                NSLog(@"DUBAIPOST : viewDidLoad :  unreachableBlock ");////
                //  [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self connectiontext];
                ///
                [reach stopNotifier];
            };
            [reachability startNotifier];
             NSLog(@"DUBAIPOST MBPROGRESS 1");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
           
            
        });
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            
            [self TabletSummary_Init];
        }
        
        
        
        
        
        
        
    }
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma Universal



-(void) connectiontext
{
    
    NSString *GetLang = [self ChkLanguage];
    
    if([GetLang  isEqual: @"E"])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(English_NO_CONNECTION_TITLE, nil)message:English_NO_CONNECTION_TEXT preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(Arabic_NO_CONNECTION_TITLE, nil)message:Arabic_NO_CONNECTION_TEXT preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    
    
}

- (void)MangomoloPlayer
{
    
    _player = [[[NSBundle mainBundle] loadNibNamed:@"MangoMoloPlayer" owner:self options:nil] objectAtIndex:0];
    
    CGFloat Newwidth = Screenwidth - 202;
    CGFloat ration = (ScreenHeight - 150) / (Screenwidth - 200) ;
    CGFloat newHeight = (ScreenHeight - 150) * ration;
    
    
    // set player frame here
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        _player.frame = CGRectMake(0, 66, frame.size.width, 250);
        
    }else
    {
        _player.frame = CGRectMake(0, 66, Newwidth,newHeight);
    }
    // set up observe notificationa
    _player.superVC = self;
    [_player setupObserveNotifications];
    
    // check geo blocking
    if ([_player checkGeoBlockingWithCountryCode:@"" geoStatus:@"" geoCountry:@""])
    {
        // setup pre, mid, post ads
        // please fill ads array with dictory objects
        [_player setupPreAds:nil midAds:nil postAds:nil];
        
        // setup analytics that will call every 10 seconds
        [_player setupAnalytics:@"" channelID:@"" videoID:@"" sessionID:@"" device:@"" withAnalyticsPath:@""];
        
        // enable progress bar if video is not live
        _player.progressBar.userInteractionEnabled = YES;
        
        // set up list streaming path now
        //   [_player setupPlayerWithStreamingPath:@"http://e247.mangomolo.com/2017-04-30/vidCFW1yK7dMg.mp4"];
        [self.view addSubview:_player];
        
        
        
    }
    
    
    
}
- (void)MangomoloplayVideoWithURL:(NSString *)url {
    
    //_player.sharingContent = @[@"title",@"video path"];
    [_player setupPlayerWithStreamingPath:url];
    
}

- (void)MangomoloplayVideo:(NSString *)passurl:(NSString *)title:(NSString *)Vimage {
    
    
    _player.sharingContent = @[title,passurl];
    [_player setupPlayerWithStreamingPath:passurl];
    
}


-(void)fetchdata {
    
    //todo: verify (in addtion; can first condition be removed?
    if (pageToken == nil || [pageToken isEqualToString:@""]) {
        pageToken = @"";
    }
    
    if (parsedItems == nil) {
        parsedItems = [[NSMutableArray alloc]init];
    }
    
    NSString *URLString;
    
    if ([GetLanguageSelected isEqualToString:[self ChkLanguage]])
    {
        URLString=[NSString stringWithFormat:kBaseUrlEng];
        
    }else
    {
        URLString=[NSString stringWithFormat:KBaseUrlArabic];
    }
    
    // NSLog(@"%@", str);
    
    
    NSURL *url = [[NSURL alloc]initWithString:URLString];
    dispatch_async(dispatch_get_main_queue(), ^{
       NSLog(@"DUBAIPOST MBPROGRESS 2");
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        EMReachability *reachability = [EMReachability reachabilityWithHostname:@"media.dubaipost.ae"];
        reachability.reachableBlock = ^(EMReachability *reach) {
            ////
            
            NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                                  delegate:nil
                                                             delegateQueue:[NSOperationQueue mainQueue]];
            [[session dataTaskWithURL:[NSURL URLWithString:URLString]
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error)
              {
                  // handle response
                  if (data == nil) {
                      NSLog(@"DUBAIPOST : VC : fetchdata :  NIL ");
                      NSLog(@"DUBAIPOST MBPROGRESS 3");
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                      
                      [self connectiontext];
                      
                      return ;
                  }else
                  {
                      NSLog(@"DUBAIPOST : VC : fetchdata :  Available ");
                      jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                      NSArray *jsonArray = [jsonDict valueForKey:@"results"];
                      
                      for (id result in jsonArray)
                      {
                          [parsedItems addObject:result];
                      }
                      [_contenttableView reloadData];
                      
                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                       NSLog(@" DUBAIPOST MBPROGRESS 4");
                      
                  }
                  
              }] resume];
            /////
            [reach stopNotifier];
        };
        reachability.unreachableBlock = ^(EMReachability *reach) {
            
            NSLog(@"DUBAIPOST : VC : fetchdata :  unreachableBlock ");////
            [MBProgressHUD hideHUDForView:self.view animated:YES];
             NSLog(@"DUBAIPOST MBPROGRESS 5");
            [self connectiontext];
            ///
            [reach stopNotifier];
        };
        [reachability startNotifier];
    });
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"DUBAIPOST : VC : connection didFailWithError ");
    if(error.code==-1009){
        //do something
        NSLog(@"DUBAIPOST : VC : connection didFailWithError : 1009 ");
    }
}



- (NSString *)ChkLanguage
{
    
    NSString *Getlanguage = [[NSUserDefaults standardUserDefaults]
                             stringForKey:@"Language"];
    return Getlanguage;
}

-(void) RefreshData
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        EMReachability *reachability = [EMReachability reachabilityWithHostname:@"media.dubaipost.ae"];
        reachability.reachableBlock = ^(EMReachability *reach) {
            ////Start
            @try {
                
                //  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW,0), ^{
                    // Do something...
                    
                    
                    query = false;
                    parsedItems = nil;
                    pageToken = @"";
                    AutoPlay = @"1";
                    [self fetchdata];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        sleep(2);
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                         NSLog(@"DUBAIPOST MBPROGRESS 6");
                    });
                });
                
            }
            @catch (NSException *exception) {
                
                NSLog(@"DUBAIPOST : VC : Catch Exceiption Refresh: %@", exception.reason);
            }
            @finally {
                NSLog(@"DUBAIPOST : VC : Catch Exceiption Finally: ");
                
            }
            //END
            
            [reach stopNotifier];
        };
        reachability.unreachableBlock = ^(EMReachability *reach) {
            
            NSLog(@"DUBAIPOST : viewDidLoad :  unreachableBlock ");////
            NSLog(@"DUBAIPOST MBPROGRESS 7");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [self connectiontext];
            ///
            [reach stopNotifier];
        };
        [reachability startNotifier];
         NSLog(@"DUBAIPOST MBPROGRESS 8");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
    
    
    
    
    
    
    
}

-(void) ChangeLanguage
{
    NSString *GetLang = [self ChkLanguage];
    
    // if([GetLang  isEqual: @"E"])
    
    if([GetLang  isEqual: @"E"])
    {
        
        NSString *valueToSave = @"A";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"Language"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageEnglish"] forState:UIControlStateNormal];
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageEnglish"] forState:UIControlStateHighlighted];
        
        // register Araboc cell nib once
        
        
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            [_contenttableView registerNib:[UINib nibWithNibName:@"SimpleTableCell" bundle:nil] forCellReuseIdentifier:@"SimpleTableCell"];
        }else
        {
            [_contenttableView registerNib:[UINib nibWithNibName:@"IpadArabiccell" bundle:nil] forCellReuseIdentifier:@"IpadArabiccell"];
        }
        
        
        
    }else
    {
        NSString *valueToSave = @"E";
        [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"Language"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageArabic"] forState:UIControlStateNormal];
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageArabic"] forState:UIControlStateHighlighted];
        
        
        // register English cell nib once
        
        
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            [_contenttableView registerNib:[UINib nibWithNibName:@"AssistTableCell" bundle:nil] forCellReuseIdentifier:@"AssistTableCell"];
        }else
        {
            [_contenttableView registerNib:[UINib nibWithNibName:@"IpadEnglishcell" bundle:nil] forCellReuseIdentifier:@"IpadEnglishcell"];
        }
        
    }
    NSLog(@"DUBAIPOST MBPROGRESS 9");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        EMReachability *reachability = [EMReachability reachabilityWithHostname:@"media.dubaipost.ae"];
        reachability.reachableBlock = ^(EMReachability *reach) {
            ////Start
            query = false;
            parsedItems = nil;
            pageToken = @"";
            AutoPlay = @"1";
            [self fetchdata];
            
            //END
            
            [reach stopNotifier];
        };
        reachability.unreachableBlock = ^(EMReachability *reach) {
            
            NSLog(@"DUBAIPOST : viewDidLoad :  unreachableBlock ");////
            NSLog(@"DUBAIPOST MBPROGRESS 10");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self connectiontext];
            
            
            ///
            [reach stopNotifier];
        };
        [reachability startNotifier];
        NSLog(@"DUBAIPOST MBPROGRESS 11");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
    
    
    
    
    
}


-(void) AddNavigation
{
    
    UIImage *img = [UIImage imageNamed:@"Logo"];
    UIImageView *mainHeading;
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        mainHeading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 88, 68)];
    }else
    {
        mainHeading = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 128, 55)];
    }
    [mainHeading setImage:img];
    // setContent mode aspect fit
    [mainHeading setContentMode:UIViewContentModeScaleAspectFit];
    
    UINavigationBar* navbar;
    if (@available(iOS 11.0, *)) {
        [[self navigationController] navigationBar].prefersLargeTitles = false;
        [[self navigationController] navigationItem].largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 44)];
    }else
    {
        navbar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    }
    
    
    
    // UINavigationBar* navbar = [[UINavigationBar alloc] init];
    
    UINavigationItem* navItem = [[UINavigationItem alloc] initWithTitle:@"hai"];
    navItem.titleView = mainHeading;
    LanguageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString *GetLang = [self ChkLanguage];
    
    if([GetLang  isEqual: @"E"])
    {
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageArabic"] forState:UIControlStateNormal];
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageArabic"] forState:UIControlStateHighlighted];
    }else
    {
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageEnglish"] forState:UIControlStateNormal];
        [LanguageBtn setBackgroundImage:[UIImage imageNamed:@"LanguageEnglish"] forState:UIControlStateHighlighted];
    }
    
    
    
    LanguageBtn.backgroundColor =[UIColor clearColor];
    [LanguageBtn setFrame:CGRectMake(0, 0, 44, 44)];
    [LanguageBtn addTarget:self
                    action:@selector(ChangeLanguage)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *LanguageButton = [[UIBarButtonItem alloc]initWithCustomView:LanguageBtn];
    navItem.leftBarButtonItem = LanguageButton;
    
    /* Create left button item. */
    UIButton *goToCategories = [UIButton buttonWithType:UIButtonTypeCustom];
    [goToCategories setBackgroundImage:[UIImage imageNamed:@"RefreshButton"] forState:UIControlStateNormal];
    [goToCategories setBackgroundImage:[UIImage imageNamed:@"RefreshButton"] forState:UIControlStateHighlighted];
    goToCategories.backgroundColor =[UIColor clearColor];
    [goToCategories setFrame:CGRectMake(0, 0, 44, 44)];
    [goToCategories addTarget:self
                       action:@selector(RefreshData)
             forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *categoriesButton = [[UIBarButtonItem alloc]initWithCustomView:goToCategories];
    navItem.rightBarButtonItem = categoriesButton;
    
    
    
    
    
    /* Assign the navigation item to the navigation bar.*/
    [navbar setItems:@[navItem]];
    
    /* add navigation bar to the root view.*/
    
    [self.view addSubview:navbar];
    
    
    
    
}




-(void)viewWillLayoutSubviews
{
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _contenttableView.contentInset = UIEdgeInsetsMake(0, 0, 250, 0);
            
        });
    }
    else
    {
        
        
    }
    
    
}

#pragma TableInitializaion tabledesign
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (parsedItems == nil) {
        return 0;
    }
    return parsedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    @try {
        
        
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            
            if ([GetLanguageSelected isEqualToString:[self ChkLanguage]])
            {
                AssistTableCell *cell;
                
                static NSString *CellIdentifier = @"AssistTableCell";
                
                
                cell = [_contenttableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                
                
                if (cell == nil) {
                    
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"AssistTableCell" owner:self options:nil]objectAtIndex:0];
                    
                }
                
                NSString *title;
                title  = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"title_en"];
                cell.lblTitle.text = title;
                
                
                /*  NSDateFormatter *dateFormatter = [NSDateFormatter new];
                 [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                 
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 
                 NSDate *date11 = [dateFormatter dateFromString:datestring];
                 
                 [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm"];
                 cell.lblDate.text =[dateFormatter stringFromDate:date11];*/
                NSString *GetDuration = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"duration"];
                
                
                
                
                cell.lblDate.text=[self timeFormatted:(GetDuration)];
                
                NSString *url=[NSString stringWithFormat:@"%@%@",Mangomolo_Image, [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"img"]];
                [cell.image sd_setImageWithURL:[NSURL URLWithString:url]
                              placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
                
                
                
                cell.image.contentMode = UIViewContentModeScaleAspectFill;
                cell.image.clipsToBounds = YES;
                
                
                
                [cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
                [cell.contentView.layer setBorderWidth:0.5f];
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                UIView *bgColorView = [[UIView alloc] init];
                
                bgColorView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:0.35];
                [cell setSelectedBackgroundView:bgColorView];
                
                
                if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
                    
                    if([AutoPlay  isEqual: @"1"])
                    {
                        AutoPlay=@"0";
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        
                        
                        
                        [_contenttableView selectRowAtIndexPath:indexPath
                                                       animated:YES
                                                 scrollPosition:UITableViewScrollPositionNone];
                        [self tableView:_contenttableView didSelectRowAtIndexPath:indexPath];
                        
                        [_contenttableView setContentOffset:CGPointZero animated:YES];
                    }
                    
                }
                
                return cell;
            }else
            {
                SimpleTableCell *cell;
                static NSString *CellIdentifier = @"SimpleTableCell";
                
                
                cell = [_contenttableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                
                
                if (cell == nil) {
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"SimpleTableCell" owner:self options:nil]objectAtIndex:0];
                    
                }
                
                
                
                NSString *title;
                title  = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"title_ar"];
                cell.lblTitle.text = title;
                
                cell.lblTitle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
                cell.lblTitle.textAlignment = NSTextAlignmentRight;
                cell.lblDate.textAlignment = NSTextAlignmentRight;
                
                /*   NSString *datestring = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"publish_time"];
                 
                 NSDateFormatter *dateFormatter = [NSDateFormatter new];
                 [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                 //  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 
                 NSDate *date11 = [dateFormatter dateFromString:datestring];
                 
                 [dateFormatter setDateFormat:@"dd-MM-yyyy hh:mm"];
                 cell.lblDate.text =[dateFormatter stringFromDate:date11];
                 */
                
                NSString *GetDuration = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"duration"];
                
                
                
                
                cell.lblDate.text=[self timeFormatted:(GetDuration)];
                
                NSString *url=[NSString stringWithFormat:@"%@%@",Mangomolo_Image, [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"img"]];
                [cell.image sd_setImageWithURL:[NSURL URLWithString:url]
                              placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
                
                
                cell.image.contentMode = UIViewContentModeScaleAspectFill;
                cell.image.clipsToBounds = YES;
                
                
                
                [cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
                
                
                [cell.contentView.layer setBorderWidth:0.5f];
                
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                UIView *bgColorView = [[UIView alloc] init];
                
                bgColorView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:0.35];
                [cell setSelectedBackgroundView:bgColorView];
                
                
                if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
                    
                    if([AutoPlay  isEqual: @"1"])
                    {
                        AutoPlay=@"0";
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        
                        
                        
                        [_contenttableView selectRowAtIndexPath:indexPath
                                                       animated:YES
                                                 scrollPosition:UITableViewScrollPositionNone];
                        [self tableView:_contenttableView didSelectRowAtIndexPath:indexPath];
                        
                        [_contenttableView setContentOffset:CGPointZero animated:YES];
                        
                        
                    }
                    
                }
                return cell;
            }
            
        }else
        {
            
            ////IPAD DESIGN
            
            if ([GetLanguageSelected isEqualToString:[self ChkLanguage]])
            {
                IpadEnglishcell *cell;
                static NSString *CellIdentifier = @"IpadEnglishcell";
                cell = [_contenttableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"IpadEnglishcell" owner:self options:nil]objectAtIndex:0];
                }
                
                NSString *title;
                title  = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"title_en"];
                cell.lbltitle.text = title;
                cell.lbltitle.textAlignment = NSTextAlignmentLeft;
                
                
                NSString *url=[NSString stringWithFormat:@"%@%@",Mangomolo_Image, [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"img"]];
                [cell.imgheader sd_setImageWithURL:[NSURL URLWithString:url]
                                  placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
                
                
                cell.imgheader.contentMode = UIViewContentModeScaleAspectFill;
                cell.imgheader.clipsToBounds = YES;
                
                
                //  tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                
                //   [cell.contentView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
                //  [cell.contentView.layer setBorderWidth:1.0f];
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                UIView *bgColorView = [[UIView alloc] init];
                //   bgColorView.backgroundColor = [UIColor colorWithRed:11/255.0 green:170/255.0 blue:251/255.0 alpha:1];
                
                bgColorView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:0.5];
                [cell setSelectedBackgroundView:bgColorView];
                
                
                if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
                    
                    if([AutoPlay  isEqual: @"1"])
                    {
                        AutoPlay=@"0";
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        
                        
                        
                        [_contenttableView selectRowAtIndexPath:indexPath
                                                       animated:YES
                                                 scrollPosition:UITableViewScrollPositionNone];
                        [self tableView:_contenttableView didSelectRowAtIndexPath:indexPath];
                        
                        [_contenttableView setContentOffset:CGPointZero animated:YES];
                    }
                    
                }
                return cell;
            }
            else
            {
                ///IPA arabic
                IpadArabiccell *cell;
                static NSString *CellIdentifier = @"IpadArabiccell";
                cell = [_contenttableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil)
                {
                    cell = [[[NSBundle mainBundle]loadNibNamed:@"IpadArabiccell" owner:self options:nil]objectAtIndex:0];
                }
                
                NSString *title;
                title  = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"title_ar"];
                cell.lbltitle.text = title;
                cell.lbltitle.textAlignment = NSTextAlignmentRight;
                
                
                NSString *url=[NSString stringWithFormat:@"%@%@",Mangomolo_Image, [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"img"]];
                [cell.imgheader sd_setImageWithURL:[NSURL URLWithString:url]
                                  placeholderImage:[UIImage imageNamed:@"placeholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
                
                
                cell.imgheader.contentMode = UIViewContentModeScaleAspectFill;
                cell.imgheader.clipsToBounds = YES;
                
                
                //  tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                
                //[cell.contentView.layer setBorderColor:[UIColor blueColor].CGColor];
                
                
                //     [cell.contentView.layer setBorderColor:(__bridge CGColorRef _Nullable)([UIColor colorWithRed:11/255.0 green:170/255.0 blue:251/255.0 alpha:1])];
                //  [cell.contentView.layer setBorderWidth:2.0f];
                
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                UIView *bgColorView = [[UIView alloc] init];
                //      bgColorView.backgroundColor = [UIColor colorWithRed:11/255.0 green:170/255.0 blue:251/255.0 alpha:1];
                bgColorView.backgroundColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:.5];
                [cell setSelectedBackgroundView:bgColorView];
                
                
                
                if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
                    
                    if([AutoPlay  isEqual: @"1"])
                    {
                        AutoPlay=@"0";
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        
                        
                        
                        [_contenttableView selectRowAtIndexPath:indexPath
                                                       animated:YES
                                                 scrollPosition:UITableViewScrollPositionNone];
                        [self tableView:_contenttableView didSelectRowAtIndexPath:indexPath];
                        
                        [_contenttableView setContentOffset:CGPointZero animated:YES];
                    }
                    
                }
                return cell;
                
            }
            
            
        }
    }
    @catch (NSException *exception) {
        
        
        NSLog(@"DUBAIPOST : VC : cellForRowAtIndexPath Catch Exceiption : %@", exception.reason);
    }
    @finally {
        NSLog(@"DUBAIPOST : VC : cellForRowAtIndexPath Finallay found");
        
    }
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return 80;
    
    if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        return 75;
    }
    else
    {
        return 155;
    }
    
    
    
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @try {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *Videourl,*VideoTitle, *VideoImage;
            
            Videourl=[NSString stringWithFormat:@"%@%@",Mangomolo_Video, [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"url"]];
            VideoImage=[NSString stringWithFormat:@"%@%@",Mangomolo_Video, [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"img"]];
            
            if ([GetLanguageSelected isEqualToString:[self ChkLanguage]])
            {
                
                VideoTitle=[NSString stringWithFormat:@"%@", [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"title_en"]];
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    articleTitle.text=VideoTitle;
                    
                    /*NSString *datestring = [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"publish_time"];
                     
                     NSDateFormatter *dateFormatter = [NSDateFormatter new];
                     [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                     //  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
                     [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                     
                     NSDate *date11 = [dateFormatter dateFromString:datestring];
                     
                     [dateFormatter setDateFormat:@"MM-dd-yyyy"];
                     //    cell.lblDate.text =[dateFormatter stringFromDate:date11];
                     NSString *GetResult=[self remaningTime:date11 endDate:[NSDate date]];
                     
                     //   articleDate.text=[self remaningTime:date11 endDate:[NSDate date]];
                     
                     articleDate.text=[NSString stringWithFormat:@"%@%@",@" Published  : ",GetResult];*/
                    
                  //  articleDate.text=[NSString stringWithFormat:@"%@%@",@"Date :", [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"publish_time"]];
                    
                    articleAuthor.text=[NSString stringWithFormat:@"%@", [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"description_en"]];
                    
                    
                    articleTitle.textAlignment = NSTextAlignmentLeft;
                 //  articleDate.textAlignment = NSTextAlignmentLeft;
                    articleAuthor.textAlignment = NSTextAlignmentLeft;
                  //  articleduration.textAlignment = NSTextAlignmentLeft;
                    
                }
                
            }else
            {
                VideoTitle=[NSString stringWithFormat:@"%@", [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"title_ar"]];
                
                if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                {
                    
                    //    [self Clearlabel];
                    articleTitle.text=VideoTitle;
                 //   articleDate.text=[NSString stringWithFormat:@"%@%@",@" التاريخ :", [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"publish_time"]];
                    
                    //      articleDate.text=[self remaningTime:[[parsedItems objectAtIndex:indexPath.row] valueForKey:@"publish_time"] endDate:[NSDate date]];
                    
                    articleAuthor.text=[NSString stringWithFormat:@"%@", [[parsedItems objectAtIndex:indexPath.row] valueForKey:@"description_ar"]];
                    
                    articleTitle.textAlignment = NSTextAlignmentRight;
                  //  articleDate.textAlignment = NSTextAlignmentRight;
                    articleAuthor.textAlignment = NSTextAlignmentRight;
                 //   articleduration.textAlignment = NSTextAlignmentRight;
                    
                    
                }
                
                
                
            }
            
            
            [self MangomoloplayVideo:Videourl:VideoTitle:VideoImage];
            
        });
        
    }
    @catch (NSException *exception) {
        NSLog(@"DUBAIPOST : VC : On Row Select Catch Exception : %@", exception.reason);
    }
    @finally {
        NSLog(@"DUBAIPOST : VC : On Row Select Finally");
        
    }
}


-(void) Clearlabel
{
    [articleTitle removeFromSuperview];
   // [articleDate removeFromSuperview];
   // [articleduration removeFromSuperview];
    [articleAuthor removeFromSuperview];
    
}


- (NSString *)timeFormatted:(NSString*)totalSeconds{
    
    
    int seconds = totalSeconds.integerValue % 60;
    int minutes = (totalSeconds.integerValue / 60) % 60;
    
    
    return [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
}




-(void) TabletSummary_Init
{
    
    
    CGFloat ration = (ScreenHeight - 150) / (Screenwidth - 200) ;
    CGFloat Newwidth = Screenwidth-202;
    
    CGFloat newHeight = (ScreenHeight - 150) * ration;
    
    
    
    articleTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, newHeight + 90, Newwidth - 20, 40)];
    
    articleTitle.backgroundColor = [UIColor clearColor];
    articleTitle.textColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:1];
    
    
    articleTitle.numberOfLines = 0;
    // articleTitle.font = [UIFont systemFontOfSize:30];
    articleTitle.font = [UIFont boldSystemFontOfSize:24];
    //articleTitle.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
    
    
    
  /*  articleDate = [[UILabel alloc] initWithFrame:CGRectMake(10, articleTitle.frame.origin.y+articleTitle.frame.size.height+10, Newwidth - 20, 20)];
    articleDate.backgroundColor = [UIColor clearColor];
    articleDate.textColor = [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1];
    
    articleDate.font = [UIFont systemFontOfSize:16];
    articleDate.numberOfLines = 10;
    
    articleduration = [[UILabel alloc] initWithFrame:CGRectMake(10, articleDate.frame.origin.y+articleDate.frame.size.height+5, Newwidth - 20, 20)];
    articleduration.backgroundColor = [UIColor clearColor];
    articleduration.textColor = [UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1];
    articleduration.font = [UIFont systemFontOfSize:16];
    articleduration.numberOfLines = 10;
    
    */
    articleAuthor = [[UILabel alloc] initWithFrame:CGRectMake(10, articleTitle.frame.origin.y+articleTitle.frame.size.height+10, Newwidth - 30, 20)];
    articleAuthor.backgroundColor = [UIColor clearColor];
    articleAuthor.textColor = [UIColor colorWithRed:55/255.0 green:55/255.0 blue:55/255.0 alpha:1];
    
    articleAuthor.font = [UIFont systemFontOfSize:18];
    articleAuthor.lineBreakMode = NSLineBreakByWordWrapping;
    articleAuthor.numberOfLines = 0;
    
    
    
    
    
    [self.view addSubview:articleTitle];
  //  [self.view addSubview:articleDate];
    [self.view addSubview:articleAuthor];
  //  [self.view addSubview:articleduration];
}

+ (BOOL)isNetworkAvailable
{
    CFNetDiagnosticRef dReference;
    dReference = CFNetDiagnosticCreateWithURL (NULL, (__bridge CFURLRef)[NSURL URLWithString:@"www.dubaipost.ae"]);
    
    CFNetDiagnosticStatus status;
    status = CFNetDiagnosticCopyNetworkStatusPassively (dReference, NULL);
    
    CFRelease (dReference);
    
    if ( status == kCFNetDiagnosticConnectionUp )
    {
        NSLog(@"DUBAIPOST : VC : isNetworkAvailable Connection is Available");
        return YES;
    }
    else
    {
        NSLog(@"DUBAIPOST : VC : isNetworkAvailable Connection is down");
        return NO;
    }
}



/*
 -(NSString*)remaningTime:(NSDate*)startDate endDate:(NSDate*)endDate {
 
 NSDateComponents *components;
 NSInteger days;
 NSInteger hour;
 NSInteger minutes;
 NSString *durationString;
 
 components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute
 fromDate: startDate toDate: endDate options: 0];
 days = [components day];
 hour = [components hour];
 minutes = [components minute];
 
 if (days > 0) {
 
 if (days > 1) {
 durationString = [NSString stringWithFormat:@"%d days ago", days];
 }
 else {
 durationString = [NSString stringWithFormat:@"%d day ago", days];
 }
 return durationString;
 }
 
 if (hour > 0) {
 
 if (hour > 1) {
 durationString = [NSString stringWithFormat:@"%d hours ago", hour];
 }
 else {
 durationString = [NSString stringWithFormat:@"%d hour ago", hour];
 }
 return durationString;
 }
 
 if (minutes > 0) {
 
 if (minutes > 1) {
 durationString = [NSString stringWithFormat:@"%d minutes ago", minutes];
 }
 else {
 durationString = [NSString stringWithFormat:@"%d minute ago", minutes];
 }
 return durationString;
 }
 
 if (minutes == 0) {
 
 if (minutes > 1) {
 durationString = [NSString stringWithFormat:@"Just Now"];
 }
 else {
 durationString = [NSString stringWithFormat:@"Just Now"];
 }
 return durationString;
 }
 
 
 return @"";
 }
 */
@end

