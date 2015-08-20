//
//  ViewController.m
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import "ViewController.h"
#import "XSLocationManager.h"
#import "MapRouteViewController.h"
@interface ViewController () {
    XSLocationManager *locationManager;
    
}
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (assign, nonatomic) CLLocationCoordinate2D currentCoordinate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.currentCoordinate = kCLLocationCoordinate2DInvalid;
    
    locationManager = [XSLocationManager sharedInstance];
    locationManager.timeoutUpdating = 6;
    
    NSLog(@"Last saved location: %@",locationManager.getLastSavedLocation);
    
    
    [self userLocation];
    
}

- (void)userLocation {
    __weak typeof(self) weakSelf = self;
    
    [locationManager locationQuery];
    
    locationManager.locationUpdatedBlock = ^(CLLocation *location){
        
        
        NSLog(@"update %@",[NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude]);
        
    };
    
    
    locationManager.locationEndBlock = ^(CLLocation *location){
        
        weakSelf.label.text = [NSString stringWithFormat:@"Lat: %f - Lng: %f", location.coordinate.latitude, location.coordinate.longitude];
        
        NSLog(@"end %@",weakSelf.label.text);
        weakSelf.currentCoordinate = location.coordinate;
        
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


- (IBAction)route:(id)sender {
    if (CLLocationCoordinate2DIsValid(_currentCoordinate)) {
        [self performSegueWithIdentifier:@"MapRoute" sender:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MapRoute"]) {
        MapRouteViewController *controller = segue.destinationViewController;
        controller.coordinate2D = _currentCoordinate;
    }
}

@end
