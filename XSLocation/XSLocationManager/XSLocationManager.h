//
//  XSLocationManager.h
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define kDefaultTimeOut     5
#define LAST_USERLOCATION   @"kUserLocation"
#define WALKING             @"kWalking"
#define AUTOMOVILE          @"kAutomovile"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

// LOCATION -> Manages without blocks the various events on location. Updates , last update and error event.
/**
 *  Updating location, previous timeout
 *
 *  @param CLLocation
 */
typedef void (^XSLocationManagerUpdatingCallback)(CLLocation *);

/**
 *  End callback location
 *
 *  @param CLLocation
 */
typedef void (^XSLocationManagerEndCallback)(CLLocation *);

/**
 *  Error callback
 *
 *  @param NSError description
 */
typedef void (^XSLocationManagerErrorCallback)(NSError *);

// GEOCODING -> Manages without blocks the various events on Geocoding. Callback or error event.
/**
 *  Callback success
 *
 *  @param NSDictionary of placemark
 */
typedef void (^XSGeocodingManagerCallback)(NSArray *);
typedef void (^XSGeocodingManagerWithLocationCallback)(NSArray *, CLLocation *);

/**
 *  Error callback
 *
 *  @param NSError of Description error
 */
typedef void (^XSGeocodingManagerErrorCallback)(NSError *);

// REVERSE GEOCODING -> Manages without blocks the various events on Geocoding. Callback or error event.
/**
 *  Callback success
 *
 *  @param NSDictionary of placemark
 */
typedef void (^XSReverseGeocodingManagerCallback)(NSArray *);

/**
 *  Error callback
 *
 *  @param NSError of Description error
 */
typedef void (^XSReverseGeocodingManagerErrorCallback)(NSError *);

/**
 *  Distance callBack
 *
 */
typedef void (^XSDistanceCompletionBlock)(NSArray *routes, NSError *error);

@interface XSLocationManager : NSObject <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
/**
 isAlwaysAuthorization 
 * @YES : iOS8+ 在后台可定位
 * @NO  : iOS8+ 只能在前台开启定位
 */
@property (nonatomic, assign) BOOL isAlwaysAuthorization;
/**
 isAllowsBackgroundUpdates
 * @YES :
 * @NO  :
    iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
 */
@property (nonatomic, assign) BOOL isAllowsBackgroundUpdates;

@property (nonatomic) NSInteger timeoutUpdating;

@property (nonatomic, copy) XSLocationManagerUpdatingCallback locationUpdatedBlock;
@property (nonatomic, copy) XSLocationManagerEndCallback locationEndBlock;
@property (nonatomic, copy) XSLocationManagerErrorCallback locationErrorBlock;
@property (nonatomic, copy) XSGeocodingManagerCallback geocodingBlock;
@property (nonatomic, copy) XSGeocodingManagerWithLocationCallback geocodingWithLocationBlock;
@property (nonatomic, copy) XSGeocodingManagerErrorCallback geocodingErrorBlock;
@property (nonatomic, copy) XSReverseGeocodingManagerCallback reverseGeocodingBlock;
@property (nonatomic, copy) XSReverseGeocodingManagerErrorCallback reverseGeocodingErrorBlock;

- (void)requestAuthorizationLocation;

- (void)locationQuery;

- (void)geocodingQuery;

- (void)reverseGeocodingQueryWithText:(NSString *)addressText;

- (CLLocation *)getLastSavedLocation;

// 绘制路线
- (void)routesBetweenTwoPointsWithUserLat:(float)latUser
                                  lngUser:(float)lngUser
                                  latDest:(float)latDest
                                  lngDest:(float)lngDest
                             transporType:(NSString *)transportType
                        onCompletionBlock:(XSDistanceCompletionBlock)onCompletion;

+ (instancetype)sharedInstance;

@end
