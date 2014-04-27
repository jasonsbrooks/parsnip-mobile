//
//  dealTableViewController.m
//  Heaped
//
//  Created by Charles Jin on 4/4/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "dealTableViewController.h"
#import "dealViewController.h"

@interface dealTableViewController () <UITableViewDelegate>

@end

@implementation dealTableViewController

NSDictionary *infoDict;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self receiveDealUpdates];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[infoDict objectForKey: @"deals"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"DealCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString * entry;
    entry = infoDict[@"deals"][indexPath.row];
    
    cell.textLabel.text = entry;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    return cell;
}



#pragma mark - Notifications

-(void)receiveDealUpdates
{
    // Set up notification center for receiving distance updates from the beacons.
    // Might want to put this method in viewDidAppear for for efficient deallocation.
    [[NSNotificationCenter defaultCenter]
     addObserver:self    // Wants to know when update happens
     selector:@selector(handleDealUpdate:)  // Method that gets called when notification happens.
     name:@"dealInfo"   // Title of notification.
     object:nil];
}

-(void)handleDealUpdate:(NSNotification *)note
{
    NSLog(@"Detected dealInfo notification.");
    
//    infoDict = note.userInfo[@"advertisements"];
     infoDict = note.userInfo;
    
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
    
    [self viewDidLoad];
    
    NSLog(@"Store name: %@", infoDict[@"name"]);
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showDealDetails"])
    {
        dealViewController *dealDetailViewController = [segue destinationViewController];
        
        NSIndexPath *myIndexPath = [self.tableView indexPathForSelectedRow];
        
        long row = [myIndexPath row];

        // access db with row
        dealDetailViewController.dealArray = @[infoDict[@"deals"][row], infoDict[@"details"][row],
            infoDict[@"descriptions"][row],
            infoDict[@"images"][row]];
    }
    
}


@end
