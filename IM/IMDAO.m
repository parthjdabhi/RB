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
    NSString *userTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid integer, nickname VARCHAR(50), avater_url VARCHAR(200), signature VARCHAR(200), stamp TIMESTAMP)", table];
    [userDB executeUpdate:userTableSql];
    
    NSString *friendTableSql = @"CREATE TABLE IF NOT EXISTS friend(uid integer, comment_name VARCHAR(50), stamp TIMESTAMP);";
    [userDB executeUpdate:friendTableSql];
    
    NSString *newfriendTableSql = @"CREATE TABLE IF NOT EXISTS newfriend(uid integer, nickname VARCHAR(50), comment VARCHAR(50), source integer, is_friend integer, stamp TIMESTAMP);";
    [userDB executeUpdate:newfriendTableSql];
    
    NSString *groupTableSql = @"CREATE TABLE IF NOT EXISTS group_info(id integer, name VARCHAR(50), avater_url VARCHAR(200), master_id integer, members text, stamp TIMESTAMP);";
    [userDB executeUpdate:groupTableSql];
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
        NSString *sql = @"INSERT INTO user (uid, nickname, avater_url, signature) VALUES (?,?,?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:user.uid], user.nickname, user.avaterUrl, user.signature];
    } else {
        NSString *sql = @"UPDATE user set nickname=?,avater_url=?,signature=? WHERE uid=?";
        [userDB executeUpdate:sql, user.nickname, user.avaterUrl, user.signature, [NSNumber numberWithUnsignedInt:user.uid]];
    }
}
-(void) saveUsers:(NSArray<User *> *) users
{
    for (User *u in users) {
        [self saveUser:u];
    }
}

-(NSArray *) getUsersWithUid:(int) uid {
    NSString *sql = @"SELECT * FROM user";
    FMResultSet *res = [userDB executeQuery:sql];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    while ([res next])
    {
        User *user = [[User alloc] init];
        user.uid = [res intForColumn:@"uid"];
        user.nickname = [res stringForColumn:@"nickname"];
        user.avaterUrl = [res stringForColumn:@"avater_url"];
        user.signature = [res stringForColumn:@"signature"];
        
        [arr addObject:user];
    }
    
    return arr;
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
        user.avaterUrl = [res stringForColumn:@"avater_url"];
        user.signature = [res stringForColumn:@"signature"];
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
    NSString *sql = @"SELECT * FROM dialog WHERE uid=? and type=1";
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

-(Dialog *) getDiaglogWithGid:(unsigned int) gid
{
    NSString *sql = @"SELECT * FROM dialog WHERE uid=? and type=2";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithUnsignedInt:gid]];
    
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
    if (message.messageType == 2) {
        uid = message.to;
        table = [NSString stringWithFormat:@"msg_g%d", message.to];
    }
    
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
    
    Dialog *dialog = nil;
    if (message.messageType == 2) {
        dialog = [self getDiaglogWithGid:uid];
    } else {
        dialog = [self getDiaglogWithUid:uid];
    }
    
    if (dialog == nil) {
        NSString *dialogName = nil;
        if (message.messageType == 2) {
            dialogName = [self getGroupWithId:uid].name;
        } else {
            dialogName = [self getUserWithUid:uid].nickname;
        }
        
        dialog = [[Dialog alloc] init];
        dialog.uid = uid;
        dialog.name = dialogName;
        dialog.desc = description;
        dialog.unreadCount = 1;
        dialog.type = message.messageType;
        dialog.stamp = message.stamp;
        [self saveDialog:dialog];
    } else {
        sql = @"UPDATE dialog SET description=?, is_read=0, unread_count=unread_count+1, stamp=? WHERE uid=? and type=?";
        [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:message.messageType]];
    }
}


-(void) saveRecvMessages:(NSArray *) messages
{
    
}

-(void) saveSendMessage:(Message *) message
{
    int uid = message.to;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    if (message.messageType == 2) {
        table = [NSString stringWithFormat:@"msg_g%d", message.to];
    }
    
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
    
    Dialog *dialog = nil;
    if (message.messageType == 2) {
        dialog = [self getDiaglogWithGid:uid];
    } else {
       dialog = [self getDiaglogWithUid:uid];
    }
    
    if (dialog == nil) {
        NSString *dialogName = nil;
        if (message.messageType == 2) {
            dialogName = [self getGroupWithId:uid].name;
        } else {
            dialogName = [self getUserWithUid:uid].nickname;
        }
        dialog = [[Dialog alloc] init];
        dialog.uid = uid;
        dialog.name = dialogName;
        dialog.desc = description;
        dialog.unreadCount = 0;
        dialog.type = message.messageType;
        dialog.stamp = message.stamp;
        [self saveDialog:dialog];
    } else {            
        sql = @"UPDATE dialog SET description=?, stamp=? WHERE uid=? and type=?";
        [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:message.messageType]];
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
        if ([res intForColumn:@"type"] < 3) {
            if ([res intForColumn:@"ct"] == 2) {
                message = [[VoiceMessage alloc] init];
            } else if ([res intForColumn:@"ct"] == 3) {
                message = [[PictureMessage alloc] init];
            } else {
                message = [[Message alloc] init];
            }
        } else if ([res intForColumn:@"type"] == 3) {
            message = [[IMNotification alloc] init];
        }

        message.from = [res intForColumn:@"fid"];
        message.to = [res intForColumn:@"tid"];
        message.messageType = [res intForColumn:@"type"];
        message.contentType = [res intForColumn:@"ct"];
        message.messageBody = [res stringForColumn:@"content"];
        message.stamp = [res longLongIntForColumn:@"stamp"];
        [message parseMessageBody];
        [arr addObject:message];
    }
    
    return arr;
}

-(NSArray *) getMessageWithGid:(int) gid {
    NSString *table = [NSString stringWithFormat:@"msg_g%d", gid];
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
        message.messageType = [res intForColumn:@"type"];
        message.contentType = [res intForColumn:@"ct"];
        message.messageBody = [res stringForColumn:@"content"];
        message.stamp = [res longLongIntForColumn:@"stamp"];
        [message parseMessageBody];
        [arr addObject:message];
    }
    
    return arr;
}

-(void) saveRecvNotification:(IMNotification *) message {
    int uid = message.uid;
    NSString *table = [NSString stringWithFormat:@"msg_%d", uid];
    if (message.contentType >= 10 && message.gid > 0) {
        table = [NSString stringWithFormat:@"msg_g%d", message.gid];
    }
    
    NSString *messageTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (fid integer, tid integer, type integer, ct integer, content VARCHAR(1000), stamp TIMESTAMP)", table];
    [userDB executeUpdate:messageTableSql];
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (fid, tid, type, ct, content, stamp) VALUES (?,?,?,?,?,?)", table];
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:message.from], [NSNumber numberWithUnsignedInt:message.to], [NSNumber numberWithUnsignedInt:message.messageType], [NSNumber numberWithUnsignedInt:message.contentType], message.messageBody, [NSNumber numberWithUnsignedLongLong:message.stamp/1000]];
    
    NSString *description = message.messageContent;
//    if (message.contentType == 2) {
//        description = @"[语音]";
//    } else if(message.contentType == 3) {
//        description = @"[图片]";
//    }
    
    Dialog *dialog = nil;
    int messageType = 0;
    if (message.contentType >= 10 && message.gid > 0) {
        dialog = [self getDiaglogWithGid:message.gid];
        messageType = 2;
    } else {
        // 打招呼不生成dialog记录
        if (message.contentType == 1) {
            return;
        }
        dialog = [self getDiaglogWithUid:message.uid];
        messageType = 1;
    }
    
    if (dialog == nil) {
        NSString *dialogName = nil;
    if (message.contentType >= 10 && message.gid > 0) {
            dialogName = [self getGroupWithId:uid].name;
        } else {
            dialogName = [self getUserWithUid:uid].nickname;
        }
        dialog = [[Dialog alloc] init];
        dialog.uid = uid;
        dialog.name = dialogName;
        dialog.desc = description;
        dialog.unreadCount = 1;
        dialog.type = messageType;
        dialog.stamp = message.stamp;
        [self saveDialog:dialog];
    } else {
        if (message.contentType == 2) {
            sql = @"UPDATE dialog SET description=?, stamp=?,is_read=0, unread_count=unread_count+1 WHERE uid=? and type=?";
            [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:messageType]];
        } else {
            sql = @"UPDATE dialog SET description=?, stamp=? WHERE uid=? and type=?";
            [userDB executeUpdate:sql, description, [NSNumber numberWithUnsignedLongLong:message.stamp/1000], [NSNumber numberWithUnsignedInt:uid], [NSNumber numberWithUnsignedInt:messageType]];
        }

    }
}

#pragma mark unread message count
-(int) getUnreadCountWithUid:(int) uid {
    Dialog *d = [self getDiaglogWithUid:uid];
    
    if (d) {
        return d.unreadCount;
    }
    return 0;
}

-(void) clearUnreadCountWithUid:(int) uid {
    NSString *sql = @"UPDATE dialog SET unread_count=0, is_read=1 WHERE uid=? and type=1";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:uid]];
}

-(int) getUnreadCountWithGid:(int) gid {
    Dialog *d = [self getDiaglogWithGid:gid];
    
    if (d) {
        return d.unreadCount;
    }
    return 0;
}

-(void) clearUnreadCountWithGid:(int) gid {
    NSString *sql = @"UPDATE dialog SET unread_count=0, is_read=1 WHERE uid=? and type=2";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:gid]];
}

-(int) getMsgUnreadCount {
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

-(void) setMsgUnreadCount:(int) count {
    [userDB executeUpdate:@"UPDATE profile SET val=? WHERE key='msg_unread_count'", [NSString stringWithFormat:@"%d", count]];
}

-(int) getNoticeUnreadCount {
    NSString *sql = @"SELECT * FROM profile WHERE key='notice_unread_count'";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next])
    {
        return [res intForColumn:@"val"];
    }
    
    sql = @"INSERT into profile (key, val) VALUES ('notice_unread_count', 0)";
    [userDB executeUpdate:sql];
    return 0;
}

-(void) setNoticeUnreadCount:(int) count {
    [userDB executeUpdate:@"UPDATE profile SET val=? WHERE key='notice_unread_count'", [NSString stringWithFormat:@"%d", count]];
}


#pragma mark friend
-(void) saveFriend:(Friend *) f {
    if (![self getFriendWithId:f.uid]) {
        NSString *sql = @"INSERT INTO friend (uid, comment_name, stamp) VALUES (?,?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:f.uid], f.commentName, [NSNumber numberWithUnsignedLongLong:f.stamp/1000]];
    }
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
        f.commentName = [res stringForColumn:@"comment_name"];
        
        User *u = [self getUserWithUid:f.uid];
        f.nickname = u.nickname;
        f.avaterUrl = u.avaterUrl;
        f.signature = u.signature;
        
        [arr addObject:f];
    }
    return arr;
}

-(Friend *) getFriendWithId:(int) uid {
    NSString *sql = @"SELECT * FROM friend WHERE uid=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInt:uid]];
    
    while ([res next])
    {
        Friend *f = [[Friend alloc] init];
        f.uid = [res intForColumn:@"uid"];
        f.commentName= [res stringForColumn:@"comment_name"];
        
        User *u = [self getUserWithUid:f.uid];
        f.nickname = u.nickname;
        f.avaterUrl = u.avaterUrl;
        f.signature = u.signature;
        
        return f;
    }
    return nil;
}

-(void) delFriendWithId:(int) uid {
    [userDB executeUpdate:@"DELETE FROM friend WHERE uid=?", [NSString stringWithFormat:@"%d", uid]];
}

#pragma mark group
-(void) saveGroup:(Group *) g {
    NSMutableArray *memberIds = [[NSMutableArray alloc] init];
    
    for (User *u in g.members) {
        [memberIds addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d", u.uid], @"id", nil]];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:memberIds
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        NSString *memberStr = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
        NSString *sql = @"INSERT INTO group_info (id, name, avater_url, master_id, members, stamp) VALUES (?,?,?,?,?,?)";
        [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:g._id], g.name, g.avaterUrl, [NSNumber numberWithUnsignedInt:g.masterId], memberStr, [NSNumber numberWithUnsignedLongLong:g.stamp/1000]];
    }else{
    }
    

}

-(void) saveGroups:(NSArray<Group *> *) arr {
    for (Group *g in arr) {
        [self saveGroup:g];
    }
}

-(NSArray *) getGroupsWithUid:(int) uid {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = @"SELECT * FROM group_info";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next]) {
        Group *g = [[Group alloc] init];
        g._id = [res intForColumn:@"id"];
        g.name= [res stringForColumn:@"name"];
        g.masterId = [res intForColumn:@"master_id"];
        g.avaterUrl = [res stringForColumn:@"avater_url"];
        
        [arr addObject:g];
    }
    return arr;
}

-(Group *) getGroupWithId:(int) uid {
    NSString *sql = @"SELECT * FROM group_info WHERE id=?";
    FMResultSet *res = [userDB executeQuery:sql, [NSNumber numberWithInt:uid]];
    
    while ([res next]) {
        Group *g = [[Group alloc] init];
        g._id = [res intForColumn:@"id"];
        g.name= [res stringForColumn:@"name"];
        g.masterId = [res intForColumn:@"master_id"];
        g.avaterUrl = [res stringForColumn:@"avater_url"];
        
        NSError *error = nil;
        NSArray *memberIds = [NSJSONSerialization JSONObjectWithData:[[res stringForColumn:@"members"]
                                                   dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableLeaves
                                                               error:&error];
        
        if (!error) {
            NSMutableArray *members = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in memberIds) {
                int userId = [[dict valueForKey:@"id"] integerValue];
                User *u = [self getUserWithUid:userId];
                if (u) {
                    [members addObject:u];
                }
            }
            g.members = members;
        }

        return g;
    }
    return nil;
}

-(void) addMembers:(NSArray *) members ToGid:(int) gid {
    Group *group = [self getGroupWithId:gid];
    NSMutableArray *memberIds = group.members;
    
    for (User *u in members) {
        [memberIds addObject:[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d", u.uid], @"id", nil]];
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:memberIds
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        NSString *memberStr = [[NSString alloc] initWithData:jsonData
                                                    encoding:NSUTF8StringEncoding];
        NSString *sql = @"UPDATE group_info set members=? WHERE id=?";
        [userDB executeUpdate:sql, memberStr, [NSNumber numberWithUnsignedInt:gid]];
    }else{
    }
}

#pragma mark make friend record
-(void) saveMakeFriendRecord:(User *) u {
    NSString *sql = @"SELECT * FROM newfriend where uid=?";
    // 记录已存在的话不重复插入
    if ([[userDB executeQuery:sql, [NSNumber numberWithUnsignedInt:u.uid]] next]) {
        return;
    }
    
    sql = @"INSERT INTO newfriend (uid, nickname, comment, source, is_friend, stamp) VALUES (?,?,?,?,?,?)";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:u.uid], u.nickname, u.comment, [NSNumber numberWithUnsignedInt:u.source], [NSNumber numberWithUnsignedInt:u.isFriend], [NSNumber numberWithUnsignedLongLong:[[NSDate date] timeIntervalSince1970]]];
}

-(void) updateMakeFriendRecord:(User *) u {
    NSString *sql = @"UPDATE newfriend SET is_friend=? WHERE uid=?";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:u.isFriend], [NSNumber numberWithUnsignedInt:u.uid]];
}

-(NSArray *) getMakeFriendRecordsByUid:(int) uid {
    NSMutableArray *arr = [NSMutableArray array];
    
    NSString *sql = @"SELECT * FROM newfriend";
    FMResultSet *res = [userDB executeQuery:sql];
    
    while ([res next]) {
        User *u = [[User alloc] init];
        u.uid = [res intForColumn:@"uid"];
        u.nickname= [res stringForColumn:@"nickname"];
        u.source = [res intForColumn:@"source"];
        u.comment = [res stringForColumn:@"comment"];
        u.isFriend = [res intForColumn:@"is_friend"];
        
        [arr addObject:u];
    }
    return arr;
}

-(void) delMakeFriendRecordWithId:(int) uid {
    NSString *sql = @"DELETE FROM newfriend WHERE uid=?";
    [userDB executeUpdate:sql, [NSNumber numberWithUnsignedInt:uid]];
}

@end
