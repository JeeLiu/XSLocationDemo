//
//  XSLocationEncrypt.h
//  XSLocation
//
//  Created by jcliuzl on 15/8/20.
//  Copyright (c) 2015年 jcliuzl. All rights reserved.
//

#import <Foundation/Foundation.h>

void bd_decrypt(double bd_lat, double bd_lon, double *gg_lat, double *gg_lon);
void bd_encrypt(double gg_lat, double gg_lon, double *bd_lat, double *bd_lon);

@interface XSLocationEncrypt : NSObject

@end
