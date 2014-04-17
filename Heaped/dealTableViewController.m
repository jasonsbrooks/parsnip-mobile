//
//  dealTableViewController.m
//  Heaped
//
//  Created by Charles Jin on 4/4/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "dealTableViewController.h"
#import "dealViewController.h"

@interface dealTableViewController ()

@end

@implementation dealTableViewController

NSDictionary *dealsDict;

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
    
    if (dealsDict == NULL) {
    dealsDict = [NSDictionary dictionaryWithObjects:@[
        [@[@"All pants 100% off ;)", @"Cheese biscuits only 99 cents", @"Where's Waldo?"] mutableCopy],
        [@[@"pants plz", @"wtf are those", @"there's waldo"] mutableCopy],
        [@[@"yo", @"yo", @"yo"] mutableCopy],
        [@[@"default", @"default", @"default"] mutableCopy]]
        forKeys:@[@"deals", @"details", @"descriptions", @"images"]];
    }
    
    self.deals = dealsDict;
    
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
    return [[self.deals objectForKey: @"deals"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"DealCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSString * entry;
    entry = self.deals[@"deals"][indexPath.row];
    
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
     name:@"storeInfo"   // Title of notification.
     object:nil];
}

-(void)handleDealUpdate:(NSNotification *)note
{
    NSLog(@"Detected storeInfo notification.");
    
    dealsDict = note.userInfo;
    
    NSString *state = [dealsDict valueForKey:@"state"];
    
//    [self viewDidLoad];
    
    NSLog(@"State: %@", state);
    NSLog(@"Dict: %@", dealsDict[@"message"]);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


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
        
        dealDetailViewController.dealArray = @[self.deals[@"deals"][row], self.deals[@"details"][row],
            self.deals[@"descriptions"][row],
            self.deals[@"images"][row]];
    }
    
}


@end
