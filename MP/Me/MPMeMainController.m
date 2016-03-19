//
//  MPMeMainController.m
//  RB
//
//  Created by hjc on 16/3/15.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMeMainController.h"

#import "IMDAO.h"
#import "PictureViewController.h"
#import "MPMeItemCell.h"

#import "IMImageStore.h"
#import "NetWorkManager.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MPMeMainController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSMutableArray *_tableCells;
}
@end

@implementation MPMeMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    _tableViewHeightConstraint.constant = 325;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载数据
-(void)initData {
    _tableCells = [[NSMutableArray alloc] init];
    
    [_tableCells addObject:@{@"cells":@[@{@"title":@"用户信息", @"cell":@"InfoCell"}, @{@"title":@"菜单", @"cell":@"MenuCell"}]}];
    [_tableCells addObject:@{@"cells":@[@{@"title":@"我的派对", @"cell":@"TicketCell"}, @{@"title":@"优惠券", @"cell":@"CouponCell"}]}];
    [_tableCells addObject:@{@"cells":@[@{@"title":@"看过的电影", @"cell":@"MovieCell"}]}];
    [_tableCells addObject:@{@"cells":@[@{@"title":@"设置", @"cell":@"SettingCell"}]}];
}

#pragma mark - 数据源方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _tableCells.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableDictionary *group = _tableCells[section];
    NSMutableArray * cells = (NSMutableArray *)[group objectForKey:@"cells"];
    return cells.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *group = _tableCells[indexPath.section];
    NSMutableArray *cells = (NSMutableArray *) group[@"cells"];
    NSMutableDictionary *cellDict = cells[indexPath.row];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        MPMeItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDict[@"cell"] forIndexPath:indexPath];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSURL *url = [NSURL URLWithString:[MUser currentUser].avatarThumbUrl];
        [cell.avatarImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"]];
        
        [cell.avatarImageView.layer setMasksToBounds:YES];
        [cell.avatarImageView.layer setCornerRadius:5];
        
        [cell.avatarImageView setUserInteractionEnabled:YES];
        [cell.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarOnClick:)]];
        
        cell.nickname.text = [MUser currentUser].nickname;
        cell.signature.text = [MUser currentUser].nickname;

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        MPMeItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDict[@"cell"] forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        return cell;
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellDict[@"cell"] forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self getPhotoFromLibrary:nil];
        }];
        UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self getPhotoFromCamera:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        [alertController addAction:deleteAction];
        [alertController addAction:archiveAction];
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        
        if (popover){
            popover.sourceView = self.view;
            popover.sourceRect = self.view.bounds;
            popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 0;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return 75;
    }
    return 44;
}

- (void)avatarOnClick:(NSNotification *)note {
    if ([MUser currentUser] && [MUser currentUser].avatarUrl) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        PictureViewController *pvc = [[PictureViewController alloc] init];
        pvc.imgArr = @[[MUser currentUser].avatarUrl];
        pvc.hidesBottomBarWhenPushed = TRUE;
        
        [self.navigationController pushViewController:pvc animated:YES];
    }
}

#pragma mark imagepicker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    NSString *key = [[[NSUUID alloc] init] UUIDString];
    [[IMImageStore shareStore] setImage:image forKey:key];
    
    [[NetWorkManager sharedInstance] uploadAvatarWithImage:image uid:[MUser currentUser].uid success:^(NSDictionary *responseObject) {
        NSString *url = [responseObject objectForKey:@"url"];
        NSString *thumbUrl = [responseObject objectForKey:@"thumb"];
        [[MUser currentUser] setAvatarUrl:url];
        [[MUser currentUser] setAvatarThumbUrl:thumbUrl];
        [[IMDAO shareInstance] updateUser:[MUser currentUser]];
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.imageView.image = image;
    } fail:^(NSError *error) {
        
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(NSData *) getNSDataFromImage:(UIImage *) image {
    NSData *data = UIImagePNGRepresentation(image);
    
    if (data == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    }
    return data;
}

-(NSData *) getNSDataFromThumb:(UIImage *) image {
    NSData *data = data = UIImageJPEGRepresentation(image, 0.1);
    
    if (data == nil) {
        UIImagePNGRepresentation(image);
    }
    return data;
}

- (void) getPhotoFromLibrary:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void) getPhotoFromCamera:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

@end
