//
//  NetWorkManager.h
//  RB
//
//  Created by hjc on 15/12/8.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWorkManager : NSObject

+(instancetype) shareInstace;

-(NSString *) uploadFile:(NSString *) path;

@end
