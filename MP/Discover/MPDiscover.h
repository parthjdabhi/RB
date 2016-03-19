//
//  MPDiscover.h
//  RB
//
//  Created by hjc on 16/3/10.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MUser.h"

@interface MPDiscover : NSObject

@property(nonatomic) NSString *moduleName;
@property(nonatomic) NSString *title;
@property(nonatomic) NSString *content;
@property(nonatomic) NSString *moviePosterUrl;
@property(nonatomic) MUser *author;

@end
