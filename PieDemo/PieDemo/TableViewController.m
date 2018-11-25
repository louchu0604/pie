//
//  TableViewController.m
//  PieDemo
//
//  Created by louchu on 2018/11/15.
//  Copyright © 2018年 Cy Lou. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "CollectionViewController.h"
#import "CYFPSLabel.h"

@interface TableViewController ()
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"samples"];
    _datas = [[NSMutableArray alloc]initWithObjects:@{@"vc":@"CollectionViewController",@"name":@"轮播滚动图"}, nil];
    [self.tableView registerClass:[TableViewCell class] forCellReuseIdentifier:@"mytablecell"];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//     [[CYFPSLabel sharedFPSLabel] showFPS];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mytablecell" forIndexPath:indexPath];
    if(!cell){
        cell = [[TableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"mytablecell"];
        
    }
    cell.textLabel.text = [_datas[indexPath.row] valueForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class cls = NSClassFromString([_datas[indexPath.row] valueForKey:@"vc"]);
    
    if ([[_datas[indexPath.row] valueForKey:@"vc"] isEqualToString:@"CollectionViewController"]) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        CollectionViewController *vc= [[CollectionViewController alloc]initWithCollectionViewLayout:flow];
          [self.navigationController pushViewController:vc animated:YES];
    }else
    {
          [self.navigationController pushViewController:[cls new] animated:YES];
    }
    
  
  
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
