//
//  Annotation.h
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface Annotation : NSObject<MKAnnotation>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

- (id)initWithPlacemark:(CLPlacemark *)placemark;

@end
