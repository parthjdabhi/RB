//
//  MPMoviePostAddController.m
//  RB
//
//  Created by hjc on 16/3/14.
//  Copyright © 2016年 hjc. All rights reserved.
//

#import "MPMoviePostAddController.h"

#import "MPMoviePostAddCell.h"
#import "MPMovieSelectListController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface MPMoviePostAddController ()<MPMovieSelectModalViewControllerDelegate, UITextViewDelegate>
{
    UITextView *_inputTextView;
}
@end

@implementation MPMoviePostAddController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationItem *item = self.navigationItem;
    item.title = @"新建派对";
    item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToPreViewController:)];
    item.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(addMoviePost:)];
}

- (void)viewWillAppear:(BOOL)animated {
    if (_movie == nil) {
        _tableViewHeightConstraint.constant = 160;
    } else {
        _tableViewHeightConstraint.constant = 200;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (_movie == nil) {
//        [self performSegueWithIdentifier:@"MPMovieListSegue" sender:self];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[MPMovieSelectListController class]]) {
        MPMovieSelectListController *vc = (MPMovieSelectListController *)segue.destinationViewController;
        vc.delegate = self;
    }
}

- (void) addMoviePost:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void) backToPreViewController:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 80;
    }
    
    if (_movie == nil) {
        return 40;
    }
    
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPMoviePostAddCell *cell = nil;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"MPMoviePostText" forIndexPath:indexPath];
        
        if (_inputTextView == nil) {
            
            _inputTextView = cell.inputTextView;
            _inputTextView.text = @"发布邀约吧";
            _inputTextView.textColor = [UIColor lightGrayColor];
            _inputTextView.delegate = self;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        
        if (_movie == nil) {
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell.textLabel.text = @"选择电影";
            
            return cell;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"MPMoviePostMovie" forIndexPath:indexPath];

        [cell.movieImageView sd_setImageWithURL:[NSURL URLWithString:_movie.poster]];
        cell.movieNameLabel.text = _movie.name;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0 && _movie == nil) {
        [self performSegueWithIdentifier:@"MPMovieListSegue" sender:self];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
    }
}

#pragma mark - MPMovieSelectModalViewControllerDelegate mothed
-(void) selectMovie:(MPMovie *) movie {
    _movie = movie;
    
    [self.tableView reloadData];
}

#pragma mark - UITextViewDelegate mothed
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"发布邀约吧"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"发布邀约吧";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
