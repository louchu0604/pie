//
//  CollectionViewController.m
//  PieDemo
//
//  Created by louchu on 2018/11/15.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "CollectionViewController.h"
#import "CollectionViewCell.h"
@interface CollectionViewController ()
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"MyCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    _datas = [NSMutableArray new];
    _formatter = [[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"yyyy/MM/dd"];
    [_datas addObject:[_formatter stringFromDate:[NSDate date]]];
    [self dataShouldFresh];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.collectionView.pagingEnabled = YES;

    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
}
- (void)dataShouldFresh
{
//     lock
    NSString *firstDateString = [_datas firstObject];
    NSDate *firstDate = [_formatter dateFromString:firstDateString];
    NSDate *needDate  = [firstDate dateByAddingTimeInterval:-24*60*60];
    [_datas insertObject:[_formatter stringFromDate:needDate] atIndex:0];
    [self.collectionView reloadData];
    
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    float swith = scrollView.contentOffset.x;
    int idx = swith/3;
    
    if (idx<=3) {
        [self dataShouldFresh];
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"user sel %d",indexPath.row);
//    判断距离
   
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row<=3) {
//        [self dataShouldFresh];
//    }
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
   
    [cell freshDate:_datas[indexPath.row]];
    
    return cell;
}
//设置itemsize的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT);
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
