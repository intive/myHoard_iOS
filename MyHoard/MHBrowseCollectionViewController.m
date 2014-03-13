//
//  MHBrowseCollectionViewController.m
//  MyHoard
//
//  Created by Konrad Gnoinski on 12/03/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHBrowseCollectionViewController.h"
#import "MHCoreDataContext.h"
#import "MHCollection.h"
#import "MHDatabaseManager.h"
#import "MHAddItem2ViewController.h"

@interface MHBrowseCollectionViewController ()

@end

@implementation MHBrowseCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.09375 green:0.09375 blue:0.09375 alpha:1.0];
    self.collections = [NSMutableArray arrayWithArray:[MHDatabaseManager getAllCollections]];

    self.tableView.backgroundColor = [UIColor appBackgroundColor];
    self.tableView.tintColor = [UIColor collectionNameFrontColor];
    [self.tableView setSeparatorColor:[UIColor collectionNameFrontColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor navigationBarBackgroundColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- ( void ) viewDidAppear:(BOOL)animated{
    [self update];
}

- (void) update{
    [self.collections removeAllObjects];
    self.collections = [NSMutableArray arrayWithArray:[MHDatabaseManager getAllCollections]];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.collections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    MHCollection *collect = [_collections objectAtIndex:indexPath.row];
    cell.textLabel.text = collect.objName;

    cell.textColor = [UIColor collectionNameFrontColor];
    cell.backgroundColor = [UIColor appBackgroundColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.lastSelectedCollection = [MHDatabaseManager getCollectionWithObjId:[_collections objectAtIndex:indexPath.row]];
    self.collectionNameString = @"col";
    NSLog(@"collectionname:%@",_collectionNameString);
    [[self delegate]setCollectionName:self.collectionNameString];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
