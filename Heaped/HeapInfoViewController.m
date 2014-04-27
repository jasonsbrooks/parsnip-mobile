//
//  HeapInfoViewController.m
//  Heaped
//
//  Created by Charles Jin on 4/17/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "HeapInfoViewController.h"

@interface HeapInfoViewController ()

@end

@implementation HeapInfoViewController

NSDictionary *infoDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self receiveInfoUpdates];
    // Do any additional setup after loading the view.
    
    _StoreTitle.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:40.0];
    
    if (infoDict == NULL){
        _StoreTitle.text = @"Loading";
        _Label1.text = @"";
        _Label2.text = @"";
        _Label3.text = @"Ranging for Stores...";
        _Label4.text = @"";
        _Label5.text = @"";
        _Label6.text = @"";
    } else {
        _StoreTitle.text = infoDict[@"name"];
        _Label1.text = @"";
        _Label2.text = @"";
        _Label3.text = @"Success!";
        _Label4.text = @"";
        _Label5.text = @"";
        _Label6.text = @"";
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

-(void)receiveInfoUpdates
{
    // Set up notification center for receiving distance updates from the beacons.
    // Might want to put this method in viewDidAppear for for efficient deallocation.
    [[NSNotificationCenter defaultCenter]
     addObserver:self    // Wants to know when update happens
     selector:@selector(handleInfoUpdate:)  // Method that gets called when notification happens.
     name:@"storeInfo"   // Title of notification.
     object:nil];
}

-(void)handleInfoUpdate:(NSNotification *)note
{
    NSLog(@"Detected storeInfo notification.");
    
    infoDict = note.userInfo;
    
    // NSString *state = [dealsDict valueForKey:@"state"];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
    [self viewDidLoad];
    
    // NSLog(@"State: %@", state);
    NSLog(@"Dict: %@", infoDict[@"storeName"]);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
