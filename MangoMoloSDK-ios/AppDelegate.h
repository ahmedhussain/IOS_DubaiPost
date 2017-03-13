//
//  AppDelegate.h
//  MangoMoloSDK-ios
//
//  Created by Curiologix on 13/03/2017.
//  Copyright © 2017 Dotcom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

