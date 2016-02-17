//
//  MeViewController.m
//  RB
//
//  Created by hjc on 15/12/24.
//  Copyright © 2015年 hjc. All rights reserved.
//

#import "MeViewController.h"
#import "IMDAO.h"
#import "IMImageStore.h"
#import "UIImage+ResizeMagick.h"
#import "IMFileHelper.h"
#import "NetWorkManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PictureViewController.h"
#import "LoginController.h"

@interface MeViewController ()

@end

@implementation MeViewController

-(instancetype) init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"更多";
        UIImage *i = [UIImage imageNamed:@"tabbarMore"];
        self.tabBarItem.image = i;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 加载数据
-(void)initData {
    _tableCells = [[NSMutableArray alloc] init];
    
    
    NSMutableArray *cs = [NSMutableArray arrayWithObjects: [NSMutableDictionary dictionaryWithObjectsAndKeys: @"1", @"name",nil], nil];
    [_tableCells addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:cs, @"cells", nil]];
    
    NSMutableDictionary *cell1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"设置备注", @"title", nil];
    //    NSMutableDictionary *cell2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"2", @"title",nil];
    NSMutableDictionary *group1 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell1, nil], @"cells", nil];
    [_tableCells addObject:group1];
    
    NSMutableDictionary *cell3 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"地区", @"title", @"深圳", @"detail", nil];
    NSMutableDictionary *cell4 = [NSMutableDictionary dictionaryWithObjectsAndKeys: @"更多", @"title",nil];
    NSMutableDictionary *group2 = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSMutableArray arrayWithObjects:cell3, cell4, nil], @"cells", nil];
    [_tableCells addObject:group2];
}

#pragma mark - 数据源方法
#pragma mark 返回分组数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //    NSLog(@"计算分组数 %lu", (unsigned long)_tableCells.count);
    return _tableCells.count;
}

#pragma mark 返回每组行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    NSLog(@"计算每组(组%li)行数",(long)section);
    NSMutableDictionary *group = _tableCells[section];
    NSMutableArray * cells = (NSMutableArray *)[group objectForKey:@"cells"];
    return cells.count;
}

#pragma mark返回每行的单元格
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSIndexPath是一个结构体，记录了组和行信息
    //    NSLog(@"生成单元格(组：%li,行%li)",(long)indexPath.section,(long)indexPath.row);
    NSMutableDictionary *group = _tableCells[indexPath.section];
    NSMutableArray *cells = (NSMutableArray *)[group objectForKey:@"cells"];
    NSMutableDictionary *contact = cells[indexPath.row];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSURL *url = [NSURL URLWithString:[MUser currentUser].avatarThumbUrl];
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avater_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
        [cell.imageView setUserInteractionEnabled:YES];
        [cell.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarOnClick:)]];
        
        cell.textLabel.text = [MUser currentUser].nickname;
        return cell;
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [contact objectForKey:@"title"];
        cell.detailTextLabel.text = [contact objectForKey:@"detail"];
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.textLabel.text = [contact objectForKey:@"title"];
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
//        UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                      initWithTitle:nil
//                                      delegate:self
//                                      cancelButtonTitle:nil
//                                      destructiveButtonTitle:nil
//                                      otherButtonTitles:@"相册", @"拍照",nil];
//        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//        [actionSheet showInView:self.view];
        
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

#pragma mark 设置分组标题内容高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }
    return 22;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return 60;
    }
    return 45;
}

#pragma mark 设置尾部说明内容高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (void)avatarOnClick:(NSNotification *)note {
    if ([MUser currentUser] && [MUser currentUser].avatarUrl) {
        PictureViewController *pvc = [[PictureViewController alloc] init];
        pvc.imgArr = [[NSMutableArray alloc] init];
        [pvc.imgArr addObject:[MUser currentUser].avatarUrl];

        [self.navigationController setNavigationBarHidden:YES animated:NO];
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

- (IBAction)logouBtnClick:(id)sender {
    [[IMDAO shareInstance] logout];
    
    LoginController *loginController = [[LoginController alloc] init];
    [self presentViewController:loginController animated:YES completion:nil];
}

@end
