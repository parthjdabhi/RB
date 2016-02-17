//
//  DialogDetailController.h
//  RB
//
//  Created by hjc on 16/1/22.
//  Copyright © 2016年 hjc. All rights reserved.
//

#define DIALOG_TYPE_PEER 1
#define DIALOG_TYPE_GROUP 2

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import "BaseDialogDetailController.h"
#import "IMDAO.h"
#import "AppProfile.h"

@interface DialogDetailController : BaseDialogDetailController <UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString *nickname;
@property (nonatomic, strong) MUser *sender;
@property (nonatomic, strong) MUser *target;
@property (nonatomic) NSInteger groupId;
@property (nonatomic) NSInteger dialogType;

@end
