//
//  dealViewController.h
//  Heaped
//
//  Created by Charles Jin on 4/4/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//


@interface dealViewController : UIViewController

@property (strong, nonatomic) NSArray *dealArray;
@property (strong, nonatomic) IBOutlet UILabel *dealTitle;
@property (strong, nonatomic) IBOutlet UILabel *dealBlurb;
@property (strong, nonatomic) IBOutlet UILabel *dealDescription;
@property (strong, nonatomic) IBOutlet UIImageView *dealBG;

@end
