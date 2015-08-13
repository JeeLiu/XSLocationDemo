//
//  ViewController.m
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import "ViewController.h"
#import "XSLocationManager.h"
@interface ViewController () {
    XSLocationManager *locationManager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    locationManager = [XSLocationManager sharedInstance];
    locationManager.timeoutUpdating = 6;
    
    NSLog(@"Last saved location: %@",locationManager.getLastSavedLocation);
    
    
    [self userLocation];
}

- (void)userLocation {
    //__weak typeof(self) weakSelf = self;
    
    [locationManager locationQuery];
    
    locationManager.locationUpdatedBlock = ^(CLLocation *location){
        
        
        NSLog(@"update %@",[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]);
        
    };
    
    
    locationManager.locationEndBlock = ^(CLLocation *location){
        
        NSLog(@"end %@",[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]);
    };
    
    
    
    locationManager.locationErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"Location Error"
                                   message:[error localizedDescription]
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles: nil] show];
        
    };
}
- (IBAction)push:(id)sender {
    
    [self performSegueWithIdentifier:@"MapPush" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
