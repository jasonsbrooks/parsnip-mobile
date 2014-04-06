//
//  dealViewController.m
//  Heaped
//
//  Created by Charles Jin on 4/4/14.
//  Copyright (c) 2014 Michael Zhao. All rights reserved.
//

#import "dealViewController.h"

@interface dealViewController ()

@end

@implementation dealViewController

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
    // Do any additional setup after loading the view from its nib.
    _dealTitle.text = _dealArray[0];
    _dealTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];

    _dealBlurb.text = _dealArray[1];
    _dealBlurb.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    _dealDescription.text = _dealArray[2];
    _dealDescription.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
    
    _dealBG.image = [UIImage imageNamed:_dealArray[3]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
