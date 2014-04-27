//
//  HeapAppDelegate.h
//  Heaped
//
//  Created by Michael Zhao on 4/2/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "iOStream.h"
#import <UIKit/UIKit.h>
#import "HeapLocationSender.h"

@interface HeapAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property HeapLocationSender *ranger;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
