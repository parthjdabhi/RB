//
//  SearchAccountController.m
//  RB
//
//  Created by hjc on 15/12/13.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "SearchAccountController.h"
#import "UserInfoController.h"
#import "FriendItemCell.h"
#import "NetWorkManager.h"
#import "MUser.h"
#import "IMDAO.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SearchAccountController ()

@end

@implementation SearchAccountController

- (void)viewDidLoad {
    [super viewDidLoad];

    _searchTextField.returnKeyType = UIReturnKeyGo;
    [_searchTextField addTarget:self action:@selector(searchData:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [_resultTableView setHidden:YES];
    
    UINib *nib = [UINib nibWithNibName:@"FriendItemCell" bundle:nil];
    [_resultTableView registerNib:nib forCellReuseIdentifier:@"FriendItemCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) searchData:(UITextField *)textField {
    NSString *searchContent = _searchTextField.text;
    
    [[NetWorkManager sharedInstance] searchUserWithKeyword:searchContent
                                                   success:^(NSArray *responseObject) {
                                                       _resultArray = [[NSMutableArray alloc] init];
                                                       for (NSDictionary *dict in responseObject) {
                                                           MUser *user = [[MUser alloc] init];
                                                           user.uid = [[dict objectForKey:@"uid"] integerValue];
                                                           user.nickname = [dict objectForKey:@"nickname"];
                                                           user.avatarUrl = [dict objectForKey:@"avatar_url"];
                                                           user.avatarThumbUrl = [dict objectForKey:@"avatar_thumb"];
                                                           user.signature = [dict objectForKey:@"signature"];
                                                           user.gender = [[dict objectForKey:@"gender"] integerValue];
                                                           
                                                           [[IMDAO shareInstance] saveUser:user];
                                                           [_resultArray addObject:user];
                                                           [_resultTableView setHidden:NO];
                                                           [_resultTableView reloadData];
                                                       }
        
                                                   } fail:^(NSError *error) {
        
                                                   }];
}

#pragma mark tableview delegate

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendItemCell" forIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    MUser *u = (MUser *)[_resultArray objectAtIndex:row];
    cell.title.text = u.nickname;
    //    NSLog(@"avater_%d.jpg", f.uid);
//    cell.avater.image = [UIImage imageNamed:[NSString stringWithFormat:@"avater_%d.jpg", u.uid]];
    NSURL *url = [NSURL URLWithString:u.avatarUrl];
    [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserInfoController *uic = [[UserInfoController alloc] init];
    MUser *u = (MUser *)[_resultArray objectAtIndex:[indexPath row]];
    uic.uid = u.uid;
    uic.target = u;
    
    [self.navigationController pushViewController:uic animated:YES];
}

- (IBAction)cancelBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
