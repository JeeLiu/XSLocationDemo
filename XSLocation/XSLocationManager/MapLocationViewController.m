//
//  MapLocationViewController.m
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import "MapLocationViewController.h"
#import "Annotation.h"
#import "XSLocationManager.h"
#import <MapKit/MapKit.h>

@interface MapLocationViewController ()<MKMapViewDelegate> {
    XSLocationManager *locationManager;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    locationManager = [XSLocationManager sharedInstance];
    locationManager.timeoutUpdating = 6;
    
    [self geocodingQuery];
}

- (void)geocodingQuery {
    __weak typeof(self) weakSelf = self;
    
    [locationManager geocodingQuery];
    
    locationManager.geocodingBlock = ^(NSArray *placemarks){
        
        CLPlacemark *placemark = (CLPlacemark *)placemarks[0];
        NSLog(@"%@",[NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                     
                     placemark.subThoroughfare ? placemark.subThoroughfare : @"subThoroughfare",
                     placemark.thoroughfare ? placemark.thoroughfare : @"thoroughfare",
                     placemark.postalCode ? placemark.postalCode : @"postalCode",
                     placemark.locality ? placemark.locality : @"locality",
                     placemark.administrativeArea ? placemark.administrativeArea : @"administrativeArea",
                     placemark.country ? placemark.country : @"country"]);
        
        
        NSMutableArray *annotations = [NSMutableArray new];
        
        for (int i = 0; i < [placemarks count]; i++) {
            CLPlacemark * thisPlacemark = [placemarks objectAtIndex:i];
            
            Annotation *ann = [[Annotation alloc] initWithPlacemark:thisPlacemark];
            [annotations addObject:ann];
        }
        
        [weakSelf.mapView addAnnotations:annotations];
        [weakSelf.mapView setSelectedAnnotations:annotations];
        
        Annotation *an = [annotations lastObject];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:an.coordinate.latitude
                                                     longitude:an.coordinate.longitude];
        [weakSelf mapZoomWithMap:weakSelf.mapView userLocation:loc];
        
        
    };
    
    
    locationManager.geocodingErrorBlock = ^(NSError *error){
        
        [[[UIAlertView alloc]initWithTitle:@"Geocoding Error"
                                   message:[error localizedDescription]
                                  delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles: nil]show];
        
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    MKPinAnnotationView *MyPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    
    MyPin.animatesDrop = YES;
    MyPin.pinColor = MKPinAnnotationColorPurple;
    MyPin.highlighted = YES;
    MyPin.canShowCallout = YES;
    return MyPin;
}

# pragma mark - Private Methods

- (void)mapZoomWithMap:(MKMapView *)map userLocation:(CLLocation *)userLoc{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLoc.coordinate.latitude;
    location.longitude = userLoc.coordinate.longitude;
    region.span = span;
    region.center = location;
    [map setRegion:region animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
