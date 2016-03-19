//
//  DialogDetailController.h
//  RB
//
//  Created by hjc on 16/1/22.
//  Copyright © 2016年 hjc. All rights reserved.
//

#define DIALOG_TYPE_PEER 1
#define DIALOG_TYPE_GROUP 2

#import "BaseDialogDetailController.h"
#import "MUser.h"

#import <AVFoundation/AVFoundation.h>

@interface RBDialogDetailController : BaseDialogDetailController <UIActionSheetDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic) NSInteger userId;
@property (nonatomic) NSString *nickname;
@property (nonatomic, strong) MUser *sender;
@property (nonatomic, strong) MUser *target;
@property (nonatomic) NSInteger groupId;
@property (nonatomic) NSInteger dialogType;

@end
