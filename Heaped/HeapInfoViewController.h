//
//  HeapInfoViewController.h
//  Heaped
//
//  Created by Charles Jin on 4/17/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeapInfoViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *StoreTitle;
@property (strong, nonatomic) IBOutlet UILabel *Label1;
@property (strong, nonatomic) IBOutlet UILabel *Label2;
@property (strong, nonatomic) IBOutlet UILabel *Label3;
@property (strong, nonatomic) IBOutlet UILabel *Label4;
@property (strong, nonatomic) IBOutlet UILabel *Label5;
@property (strong, nonatomic) IBOutlet UILabel *Label6;

-(void) viewDidLoad;

@end
