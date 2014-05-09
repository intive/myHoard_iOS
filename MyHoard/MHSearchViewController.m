//
//  MHSearchViewController.m
//  MyHoard
//
//  Created by user on 09/05/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHSearchViewController.h"
#import "MHDatabaseManager.h"
#import "MHCollection.h"
#import "MHCollectionDetailsViewController.h"

@interface MHSearchViewController ()

@property (nonatomic, strong) NSArray *coreDataCollections;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MHSearchViewController

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
    
    _tableView.backgroundColor = [UIColor appBackgroundColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - redresh table view data

- (void)viewWillAppear:(BOOL)animated{
    [self update];
}

- (void)update {
    _coreDataCollections = [MHDatabaseManager allCollections];
    [_tableView reloadData];
}

#pragma mark - table view delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_coreDataCollections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"searchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    MHCollection *collection = [_coreDataCollections objectAtIndex:indexPath.row];
    cell.textLabel.text = collection.objName;
    cell.textLabel.textColor = [UIColor collectionNameFrontColor];
    cell.backgroundColor = [UIColor appBackgroundColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHCollection *collection = [_coreDataCollections objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"collectionDetails" sender:collection];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"collectionDetails"]) {
        MHCollectionDetailsViewController * vc = [segue destinationViewController];
        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        vc.collection = [_coreDataCollections objectAtIndex:indexPath.row];
    }
}

@end
