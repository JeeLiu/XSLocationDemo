//
//  Annotation.m
//  XSLocation
//
//  Created by jcliuzl on 15/8/13.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import "Annotation.h"

@implementation Annotation

- (id)initWithPlacemark:(CLPlacemark *)thisPlacemark {
    self = [super init];
    if (self)  {
        
        MKCoordinateRegion Bridge = { {0.0, 0.0} , {0.0, 0.0} };
        Bridge.center.latitude = thisPlacemark.location.coordinate.latitude;
        Bridge.center.longitude = thisPlacemark.location.coordinate.longitude;
        Bridge.span.longitudeDelta = 0.01f;
        Bridge.span.latitudeDelta = 0.01f;
        
        _title = [NSString stringWithFormat:@"Localidad: %@%@",thisPlacemark.administrativeArea, thisPlacemark.locality];
        _subtitle = [NSString stringWithFormat:@"Calle: %@ %@",thisPlacemark.subLocality,thisPlacemark.subThoroughfare];
        _coordinate = Bridge.center;
    }
    
    return self;
}

@end
