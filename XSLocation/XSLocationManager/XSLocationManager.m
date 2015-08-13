//
//  XSLocationManager.m
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import "XSLocationManager.h"

typedef NS_ENUM(NSUInteger, XSLastQuery) {
    kXSQueryLocation = 0,
    kXSQueryGeocoding,
    kXSQueryReverseGeocoding
};

@implementation XSLocationManager {
    BOOL _stopLocation;
    BOOL _isGeocoding;
    BOOL _isLocation;
    NSTimer *_queryingTimer;
    CLLocation *_location;
    int _lastTypeAction;
    NSString *_reverseGeocodingLastText;
}

@synthesize timeoutUpdating = _timeoutUpdating;

# pragma mark - Getters
-(NSInteger)timeoutUpdating{
    return _timeoutUpdating;
}

# pragma mark - Setters
- (void) setTimeoutUpdating:(NSInteger)timeoutUpdating {
    _timeoutUpdating = timeoutUpdating;
}

# pragma mark - Life cycle

+ (instancetype)sharedInstance {
    static XSLocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _timeoutUpdating = kDefaultTimeOut;
    }
    return self;
}

# pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    switch([error code]) {
        case kCLErrorNetwork:
        case kCLErrorDeferredDistanceFiltered:
        case kCLErrorDenied:{
            if(self.locationErrorBlock){
                self.locationErrorBlock(error);
            }
        }
            break;
        case kCLErrorLocationUnknown:{
            NSLog(@"kCLErrorLocationUnknown");
        } break;
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (_lastTypeAction) {
        case kXSQueryLocation:
            [self locationQuery];
            break;
        case kXSQueryGeocoding:
            [self geocodingQuery];
            break;
        case kXSQueryReverseGeocoding:
            [self reverseGeocodingQueryWithText:_reverseGeocodingLastText];
            break;
        default:
            break;
    }
}

/**
 *  < iOS 8
 *
 */
-(void)locationManager:(CLLocationManager *)delegator didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationManagerDidUpdateToLocation:newLocation];
}

/**
 *  > iOS 8
 *
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self locationManagerDidUpdateToLocation:[locations lastObject]];
}

# pragma mark - Public Methods
- (void)requestAuthorizationLocation{
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        if (!_isAlwaysAuthorization && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization]; // 只能在前台开启定位
        } else if (_isAlwaysAuthorization && [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization]; //  在后台可定位
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        if (_isAllowsBackgroundUpdates && [self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
//            _locationManager.allowsBackgroundLocationUpdates = YES;
        }
    }
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager stopUpdatingLocation];
}

- (void)locationQuery{
    [self startUpdatingLocation];
    _isLocation = YES;
    _lastTypeAction = kXSQueryLocation;
}

- (void)geocodingQuery{
    [self startUpdatingLocation];
    _isGeocoding = YES;
    _lastTypeAction = kXSQueryGeocoding;
}

- (CLLocation *)getLastSavedLocation{
    NSDictionary *userLoc = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_USERLOCATION];
    return [[CLLocation alloc] initWithLatitude:[[userLoc objectForKey:@"lat"]doubleValue]
                                      longitude:[[userLoc objectForKey:@"lng"]doubleValue]];
}

# pragma mark - Private Methods

- (void)startUpdatingLocation{
    
    if ([self locationIsEnabled] && [self canUseLocation]) {
        
        if (!self.locationManager)
            self.locationManager = [[CLLocationManager alloc]init];
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted ) {
            [self dispatchAlertCheckingVersionSystem];
        } else if (status == kCLAuthorizationStatusNotDetermined) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                //[self.locationManager requestAlwaysAuthorization];
                
                if (!_isAlwaysAuthorization && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                    [_locationManager requestWhenInUseAuthorization]; // 只能在前台开启定位
                } else if (_isAlwaysAuthorization && [self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                    [_locationManager requestAlwaysAuthorization]; //  在后台可定位
                }
                
            }
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
                if (_isAllowsBackgroundUpdates && [self.locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
                    //            _locationManager.allowsBackgroundLocationUpdates = YES;
                }
            }
            
        }
        [self.locationManager startUpdatingLocation];
        [self startTimer];
        
    } else {
        [self dispatchAlertCheckingVersionSystem];
    }
    
}

- (void)locationManagerDidUpdateToLocation:(CLLocation *)newLocation {
    if  ( newLocation == nil || newLocation.horizontalAccuracy < 0 ) {
        return;
    }
    
    NSTimeInterval newLocationTime = -[newLocation.timestamp timeIntervalSinceNow];
    
    if  ( newLocationTime > 5.0 ) {
        return;
    }
    
    CLLocationCoordinate2D newLocationCoordinate = newLocation.coordinate;
    
    if  ( !CLLocationCoordinate2DIsValid(newLocationCoordinate)
         || ( newLocationCoordinate.latitude == 0.0 && newLocationCoordinate.longitude == 0.0 )) {
        return;
    }
    
    _location = newLocation;
    
    if (self.locationUpdatedBlock) {
        self.locationUpdatedBlock(newLocation);
    }
    
    [self saveLocationInUserDefaultsWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
    
}

- (BOOL)locationIsEnabled{
    if(![CLLocationManager locationServicesEnabled] &&
       ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted))
        return NO;
    
    return YES;
    
}

- (BOOL)canUseLocation{
    
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        if ([CLLocationManager locationServicesEnabled] &&
            ((authStatus == kCLAuthorizationStatusAuthorizedAlways) ||
             (authStatus == kCLAuthorizationStatusAuthorizedWhenInUse) ||
             ((authStatus == kCLAuthorizationStatusNotDetermined)))) {
                return YES;
            }
        
        return NO;
    }
    
    if ([CLLocationManager locationServicesEnabled] &&
        ((authStatus == kCLAuthorizationStatusAuthorizedAlways) || ((authStatus == kCLAuthorizationStatusNotDetermined)))) {
        return YES;
    }
    
    return NO;
    
}

- (void)saveLocationInUserDefaultsWithLatitude:(double)lat longitude:(double)lng{
    
    NSNumber *latitude = [NSNumber numberWithDouble:lat];
    NSNumber *longitude = [NSNumber numberWithDouble:lng];
    
    NSDictionary *userLocation=@{@"lat":latitude,@"lng":longitude};
    
    [[NSUserDefaults standardUserDefaults] setObject:userLocation
                                              forKey:LAST_USERLOCATION];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dispatchAlertCheckingVersionSystem{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView setTag:1001];
        [alertView show];
        
    }
    else {
        NSString *titles;
        titles = @"Title";
        NSString *msg = @"Location services are off. To use location services you must turn on 'Always' in the Location Services Settings from Click on 'Settings' > 'Privacy' > 'Location Services'. Enable the 'Location Services' ('ON')";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titles
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==1001 && buttonIndex != alertView.cancelButtonIndex){
        // 跳转到设置界面
        if (&UIApplicationOpenSettingsURLString != NULL) {
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                [[UIApplication sharedApplication] openURL:settingsURL];
            }
        }
    }
}

- (NSError *)getCustomErrorWithUserInfo:(NSString *)info{
    return [NSError errorWithDomain:kCLErrorDomain
                               code:1
                           userInfo:@{NSLocalizedDescriptionKey:info}];
    
}


- (void)startTimer {
    [self stopTimer];
    _queryingTimer = [NSTimer scheduledTimerWithTimeInterval:_timeoutUpdating
                                                      target:self
                                                    selector:@selector(timerPassed)
                                                    userInfo:nil
                                                     repeats:NO];
}

-(void)stopTimer {
    if (_queryingTimer) {
        if ([_queryingTimer isValid]) {
            [_queryingTimer invalidate];
        }
        _queryingTimer = nil;
    }
}

- (void)timerPassed
{
    [self stopTimer];
    
    [self.locationManager stopUpdatingLocation];
    
    if (_isLocation) {
        if (self.locationEndBlock) {
            self.locationEndBlock(_location);
        }
        _isLocation = NO;
    }
    
    if (_isGeocoding) {
        [self getAddressFromLocation:_location];
        _isGeocoding = NO;
    }
    
}

- (void)getAddressFromLocation:(CLLocation *)location {
    if ([self locationIsEnabled] && [self canUseLocation]) {
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (self.geocodingErrorBlock && (error || placemarks.count == 0)) {
                self.geocodingErrorBlock(error);
                
            } else {
                if  (self.geocodingBlock) {
                    self.geocodingBlock(placemarks);
                }
                if (self.geocodingWithLocationBlock) {
                    self.geocodingWithLocationBlock(placemarks, _location);
                }
            }
        }];
        
    } else {
        [self dispatchAlertCheckingVersionSystem];
    }
}

- (void)reverseGeocodingQueryWithText:(NSString *)addressText{
    _reverseGeocodingLastText = addressText;
    
    _lastTypeAction = kXSQueryReverseGeocoding;
    
    CLCircularRegion *currentRegion = [[CLCircularRegion alloc] initWithCenter:CLLocationCoordinate2DMake(-33.861506931797535,151.21294498443604) radius:25000 identifier:@"NEARBY"];
    
    CLGeocoder *geocoder = [CLGeocoder new];
    
    [geocoder geocodeAddressString:addressText inRegion:currentRegion completionHandler:^(NSArray *placemarks, NSError *error){
        if (error) {
            self.reverseGeocodingErrorBlock(error);
            
            return;
        }
        
        if (!placemarks) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No placemarks" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            return;
        }
        
        self.reverseGeocodingBlock(placemarks);
    }];
    
}



-(void)routesBetweenTwoPointsWithUserLat:(float)latUser
                                 lngUser:(float)lngUser
                                 latDest:(float)latDest
                                 lngDest:(float)lngDest
                            transporType:(NSString *)transportType
                       onCompletionBlock:(XSDistanceCompletionBlock)onCompletion{
    
    MKPlacemark *source = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latUser, lngUser)
                                                addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc] initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latDest, lngDest)
                                                     addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc] initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    
    if ([transportType isEqualToString:AUTOMOVILE]) {
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
    } else if ([transportType isEqualToString:WALKING]){
        [request setTransportType:MKDirectionsTransportTypeWalking];
    } else {
        [request setTransportType:MKDirectionsTransportTypeAutomobile];
    }
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        //        MKRoute * rou = [[response routes]objectAtIndex:0];
        //        NSLog(@"%@",[self stringFromInterval:rou.expectedTravelTime]);
        
        onCompletion([response routes], nil);
    }];
}


// Transform NSTimeInterval to 00:00:00
- (NSString *)stringFromInterval:(NSTimeInterval)timeInterval {
#define SECONDS_PER_MINUTE (60)
#define MINUTES_PER_HOUR (60)
#define SECONDS_PER_HOUR (SECONDS_PER_MINUTE * MINUTES_PER_HOUR)
#define HOURS_PER_DAY (24)
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti = round(timeInterval);
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (ti / SECONDS_PER_HOUR) % HOURS_PER_DAY, (ti / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR, ti % SECONDS_PER_MINUTE];
    
#undef SECONDS_PER_MINUTE
#undef MINUTES_PER_HOUR
#undef SECONDS_PER_HOUR
#undef HOURS_PER_DAY
}


@end
