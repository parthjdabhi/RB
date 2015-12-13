//
//  IMDAO.m
//  ByteBuffer
//
//  Created by hjc on 14-8-3.
//  Copyright (c) 2014年 hjc. All rights reserved.
//

#import "IMDAO.h"
#import "FMDatabase.h"

@interface IMDAO()
{
    FMDatabase *commonDB;
    FMDatabase *userDB;
}

@end

@implementation IMDAO

static IMDAO *sharedInstance;

+(IMDAO *) shareInstance
{
    static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		
		sharedInstance = [[IMDAO alloc] init];
	}
    
    return sharedInstance;
}

-(id) init
{
    self = [super init];
    commonDB = [FMDatabase databaseWithPath:[self commonDBPath]];
    userDB = [FMDatabase databaseWithPath:[self userDBPath]];
    [commonDB open];
    [userDB open];

    NSString *profileTableSql = @"CREATE TABLE IF NOT EXISTS profile(key VARCHAR(50), val VARCHAR(500));";
    [userDB executeUpdate:profileTableSql];
    
    NSString *dialogTableSql = @"CREATE TABLE IF NOT EXISTS dialog(uid integer, name VARCHAR(50), description VARCHAR(100), type integer, avater VARCHAR(200), is_read interger, unread_count integer, stamp TIMESTAMP)";
    [userDB executeUpdate:dialogTableSql];
    
    NSString *table = @"user";
    NSString *userTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid integer, nickname VARCHAR(50), stamp TIMESTAMP)", table];
    [userDB executeUpdate:userTableSql];
    
    NSString *friendTableSql = @"CREATE TABLE IF NOT EXISTS friend(uid integer, comment_name VARCHAR(50), stamp TIMESTAMP);";
    [userDB executeUpdate:friendTableSql];
    return self;
}

-(NSString *) commonDBPath
{
    return [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(), @"common.sqlite"];
}

-(NSString *) userDBPath
{
    return [NSString stringWithFormat:@"%@/Documents/user_%d%@", NSHomeDirectory(), [User currentUser].uid, @".sqlite"];
}

#pragma mark user

-(void) saveUser:(User *) user
{
    if (![self getUserWithUid:user.uid]) {        
        NSString *sql = @"INSERT INTO user (uid, nickname) VALUES (?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:user.uid], user.nickname];
    }
}
-(void) saveUsers:(NSArray<User *> *) users
{
    for (User *u in users) {
        [self saveUser:u];
    }
}
-(User *) getUserWithUid:(int) uid {
    NSString *sql = @"SELECT * FROM user WHERE uid=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithUnsignedInt:uid]];
    
    User *user = nil;
    
    while ([res next])
    {
        user = [[User alloc] init];
        user.uid = [res intForColumn:@"uid"];
        user.nickname = [res stringForColumn:@"nickname"];
    }
    
    return user;
}

#pragma mark dialog

-(void) saveDialog:(Dialog *) dialog
{
    NSString *sql = @"INSERT INTO dialog (uid, name, description, type, avater, is_read, unread_count, stamp) VALUES (?,?,?,?,?,?,?,?)";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:dialog.uid], dialog.name, dialog.desc, [NSNumber numberWithUnsignedInt:dialog.type], dialog.avater, [NSNumber numberWithUnsignedInt:dialog.unreadCount>0?0:1], [NSNumber numberWithUnsignedInt:dialog.unreadCount], [NSNumber numberWithUnsignedLongLong:dialog.stamp/1000]];
}

-(void) saveDialogs:(NSArray *) dialogs
{
    
}

-(void) deleteDialogWithId:(int) _id
{
    [userDB executeUpdate:[NSString stringWithFormat:@"delete FROM dialog where uid=%d", _id]];
    [userDB executeUpdate:[NSString stringWithFormat:@"drop table msg_%d", _id]];
}

-(NSArray *) getDialogs
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM dialog ORDER BY is_read ASC, stamp DESC"];
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    Dialog *dialog = nil;
    
    while ([res next])
    {
        dialog = [[Dialog alloc] init];
        dialog.uid = [res intForColumn:@"uid"];
        dialog.name = [res stringForColumn:@"name"];
        dialog.desc = [res stringForColumn:@"description"];
        dialog.type = [res intForColumn:@"type"];
        dialog.avater = [res stringForColumn:@"avater"];
        dialog.unreadCount = [res intForColumn:@"unread_count"];
        dialog.stamp = [res longLongIntForColumn:@"stamp"];
        [arr addObject:dialog];
    }
    
    return arr;
}

-(Dialog *) getDiaglogWithUid:(unsigned int) uid
{
    NSString *sql = @"SELECT * FROM dialog WHERE uid=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithUnsignedInt:uid]];
    
    Dialog *dialog = nil;
    
    while ([res next])
    {
        dialog = [[Dialog alloc] init];
        dialog.uid = [res intForColumn:@"uid"];
        dialog.name = [res stringForColumn:@"name"];
        dialog.desc = [res stringForColumn:@"description"];
        dialog.type = [res intForColumn:@"type"];
        dialog.avater = [res stringForColumn:@"avater"];
        dialog.unreadCount = [res intForColumn:@"unread_count"];
        dialog.stamp = [res longLongIntForColumn:@"stamp"];
    }
    
    return dialog;
}

-(void) updateDiaglog:(Dialog *) dialog
{
    NSString *sql = @"UPDATE dialog SET name=?, description=?, type=?, avater=?, unread_count=?, stamp=? WHERE uid=?";
    [userDB executeUpdate:sql, dialog.name, dialog.description, [NSNumber numberWithUnsignedInt:dialog.type], dialog.avater, [NSNumber numberWithUnsignedInt:dialog.unreadCount], [NSNumber numberWithUnsignedLongLong:dialog.stamp/1000], [NSNumber numberWithUnsignedInt:dialog.uid]];
}

#pragma mark message

-(void) saveRecvMessage:(Message *) message
{
    int uid = message.from;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    NSString *messageTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fid integer, tid integer, type integer, ct integer, content VARCHAR(1000), stamp TIMESTAMP)", table];
    [userDB executeUpdate:messageTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (fid, tid, type, ct, content, stamp) VALUES (?,?,?,?,?,?)", table];
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:message.from], [NSNumber numberWithUnsignedInt:message.to], [NSNumber numberWithUnsignedInt:message.messageType], [NSNumber numberWithUnsignedInt:message.contentType], message.messageBody, [NSNumber numberWithUnsignedLongLong:message.stamp/1000]];
    
    NSString *description = message.messageContent;
    if (message.contentType == 2) {
        description = @"[语音]";
    } else if(message.contentType == 3) {
        description = @"[图片]";
    }
    
    Dialog *dialog = [self getDiaglogWithUid:uid];
    if (dialog == nil) {
        dialog = [[Dialog alloc] init];
        dialog.uid = uid;
        dialog.name = [NSString stringWithFormat:@"%d", uid];
        dialog.desc = description;
        dialog.unreadCount = 1;
        dialog.stamp = message.stamp;
        [self saveDialog:dialog];
    } else {
        sql = @"UPDATE dialog SET description=?, is_read=0, unread_count=unread_count+1, stamp=? WHERE uid=?";
        [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid]];
    }
}


-(void) saveRecvMessages:(NSArray *) messages
{
    
}

-(void) saveSendMessage:(Message *) message
{
    int uid = message.to;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    NSString *messageTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fid integer, tid integer, type integer, ct integer, content VARCHAR(1000), stamp TIMESTAMP)", table];
    [userDB executeUpdate:messageTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (fid, tid, type, ct, content, stamp) VALUES (?,?,?,?,?,?)", table];
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:message.from], [NSNumber numberWithUnsignedInt:message.to], [NSNumber numberWithUnsignedInt:message.messageType], [NSNumber numberWithUnsignedInt:message.contentType], message.messageBody, [NSNumber numberWithUnsignedLongLong:message.stamp/1000]];
    
    NSString *description = message.messageContent;
    if (message.contentType == 2) {
        description = @"[语音]";
    } else if(message.contentType == 3) {
        description = @"[图片]";
    }
    
    Dialog *dialog = [self getDiaglogWithUid:uid];
    if (dialog == nil) {
        dialog = [[Dialog alloc] init];
        dialog.uid = uid;
        dialog.name = [NSString stringWithFormat:@"%d", uid];
        dialog.desc = description;
        dialog.unreadCount = 1;
        dialog.stamp = message.stamp;
        [self saveDialog:dialog];
    } else {            
        sql = @"UPDATE dialog SET description=?, stamp=? WHERE uid=?";
        [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid]];
    }
    
}

-(NSArray *) getMessageWithUid:(int) uid
{
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY stamp ASC", table];
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    Message *message = nil;
    
    while ([res next])
    {
        if ([res intForColumn:@"ct"] == 2) {
            message = [[VoiceMessage alloc] init];
        } else if ([res intForColumn:@"ct"] == 3) {
            message = [[PictureMessage alloc] init];
        } else {
            message = [[Message alloc] init];
        }
        
        message.from = [res intForColumn:@"fid"];
        message.to = [res intForColumn:@"tid"];
        message.type = [res intForColumn:@"type"];
        message.contentType = [res intForColumn:@"ct"];
        message.messageBody = [res stringForColumn:@"content"];
        message.stamp = [res longLongIntForColumn:@"stamp"];
        [message parseMessageBody];
        [arr addObject:message];
    }
    
    return arr;
}


-(int) getUnreadCountWithUid:(int) uid {
    Dialog *d = [self getDiaglogWithUid:uid];
    
    if (d) {
        return d.unreadCount;
    }
    return 0;
}

-(void) clearUnreadCountWithUid:(int) uid {
    NSString *sql = @"UPDATE dialog SET unread_count=0, is_read=1 WHERE uid=?";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:uid]];
}

-(int) getUnreadCount {
    NSString *sql = @"SELECT * FROM profile WHERE key='msg_unread_count'";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next])
    {
        return [res intForColumn:@"val"];
    }
    
    sql = @"INSERT into profile (key, val) VALUES ('msg_unread_count', 0)";
    [userDB executeUpdate:sql];
    return 0;
}

-(void) setUnreadCount:(int) count {
    [userDB executeUpdate:@"UPDATE profile SET val=? WHERE key='msg_unread_count'", [NSString stringWithFormat:@"%d", count]];
}

-(void) saveFriend:(Friend *) f {
    NSString *sql = @"INSERT INTO friend (uid, comment_name, stamp) VALUES (?,?,?)";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:f.uid], f.commentName, [NSNumber numberWithUnsignedLongLong:f.stamp/1000]];
}

-(void) saveFriends:(NSArray *) arr {
    for (Friend *f in arr) {
        [self saveFriend:f];
    }
}

-(NSArray *) getFriendsWithUid:(int) uid {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = @"SELECT * FROM friend";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next])
    {
        Friend *f = [[Friend alloc] init];
        f.uid = [res intForColumn:@"uid"];
        f.commentName= [res stringForColumn:@"comment_name"];
        
        User *u = [self getUserWithUid:f.uid];
        f.nickname = u.nickname;
        
        [arr addObject:f];
    }
    return arr;
}

-(Friend *) getFriendWithId:(int) uid {
    NSString *sql = @"SELECT * FROM friend WHERE uid=?";
    FMResultSet *res = [userDB executeQuery:sql, uid];
    
    while ([res next])
    {
        Friend *f = [[Friend alloc] init];
        f.uid = [res intForColumn:@"uid"];
        f.commentName= [res stringForColumn:@"comment_name"];
        
        User *u = [self getUserWithUid:f.uid];
        f.nickname = u.nickname;
        
        return f;
    }
    return nil;
}

@end
