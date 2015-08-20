//
//  MapRouteViewController.m
//  XSLocation
//
//  Created by jcliuzl on 15/8/20.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import "MapRouteViewController.h"
#import "XSLocationManager.h"
#import <MapKit/MapKit.h>
@interface MapRouteViewController ()<MKMapViewDelegate> {
    XSLocationManager *locationManager;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [XSLocationManager sharedInstance];
    locationManager.timeoutUpdating = 6;
    
    [self mapZoomWithMap:self.mapView coordinate:_coordinate2D];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self routeSearch];
}

- (void)routeSearch {
    __weak typeof(self) weakSelf = self;
    
//    [locationManager reverseGeocodingQueryWithText:@"体育中心"];
//    
//    locationManager.reverseGeocodingBlock = ^(NSArray *placemarks) {
//        
//        CLPlacemark *placemark = (CLPlacemark *)placemarks[0];
//        
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        
//        [strongSelf->locationManager routesBetweenTwoPointsWithUserLat:strongSelf.coordinate2D.latitude lngUser:strongSelf.coordinate2D.longitude latDest:placemark.location.coordinate.latitude lngDest:placemark.location.coordinate.longitude transporType:WALKING onCompletionBlock:^(NSArray *routes, NSError *error) {
//            MKRoute *route = routes[0];
//            [strongSelf.mapView addOverlay:route.polyline];
//        }];
//    };
    
    
    
    [locationManager routesBetweenTwoPointsWithUserLat:_coordinate2D.latitude lngUser:_coordinate2D.longitude latDest:23.142682f lngDest:113.334353f transporType:WALKING onCompletionBlock:^(NSArray *routes, NSError *error) {
        MKRoute *route = routes[0];
        [weakSelf.mapView addOverlay:route.polyline];
    }];
}

- (void)mapZoomWithMap:(MKMapView *)map coordinate:(CLLocationCoordinate2D)coordinate{
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = coordinate.latitude;
    location.longitude = coordinate.longitude;
    region.span = span;
    region.center = location;
    [map setRegion:region animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = [UIColor redColor];
    return renderer;
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
