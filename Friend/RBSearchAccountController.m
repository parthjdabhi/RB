//
//  SearchAccountController.m
//  RB
//
//  Created by hjc on 15/12/13.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "RBSearchAccountController.h"

#import "RBUserInfoController.h"
#import "RBFriendItemCell.h"
#import "NetWorkManager.h"
#import "MUser.h"
#import "IMDAO.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RBSearchAccountController ()

@end

@implementation RBSearchAccountController

- (void)viewDidLoad {
    [super viewDidLoad];

    _searchBar.delegate = self;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_searchBar becomeFirstResponder];
    
    [_resultTableView setHidden:YES];
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

#pragma mark - SearchBar delegate
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchContent = searchBar.text;
    
    void (^successBlock)(NSArray *) = ^(NSArray *responseObject) {
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
        
    };
    
    [[NetWorkManager sharedInstance] searchUserWithKeyword:searchContent
                                                   success:successBlock
                                                      fail:^(NSError *error) {
        
                                                   }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RBFriendItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RBFriendItemCell" forIndexPath:indexPath];
    
    NSUInteger row = [indexPath row];
    MUser *u = (MUser *)[_resultArray objectAtIndex:row];
    cell.title.text = u.nickname;
    
    NSURL *url = [NSURL URLWithString:u.avatarUrl];
    [cell.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    RBUserInfoController *uic = segue.destinationViewController;

    NSIndexPath *indexPath = self.resultTableView.indexPathForSelectedRow;
    MUser *u = (MUser *)[_resultArray objectAtIndex:[indexPath row]];
    uic.uid = u.uid;
    uic.target = u;
}

@end
