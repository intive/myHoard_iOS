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
@property (nonatomic, strong) NSArray *coreDataSearchResults;
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
    
    [self.navigationController setNavigationBarHidden:YES];    
    _tableView.backgroundColor = [UIColor appBackgroundColor];
    _coreDataSearchResults = [[NSArray alloc]init];
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
    _coreDataSearchResults = [[NSArray alloc]init];
    [_tableView reloadData];
}

#pragma mark - table view delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [_coreDataSearchResults count];
    }else {
        return [_coreDataCollections count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"searchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        MHCollection *collection = [_coreDataSearchResults objectAtIndex:indexPath.row];
        cell.textLabel.text = collection.objName;
    }else {
        MHCollection *collection = [_coreDataCollections objectAtIndex:indexPath.row];
        cell.textLabel.text = collection.objName;
    }
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

#pragma mark - search delegate methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    
    NSPredicate *predicate;
    
    if ([scope isEqualToString:@"Name"]) {
         predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@", searchText];
        _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
    }else if ([scope isEqualToString:@"Description"]) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objDescription beginswith[c] %@", searchText];
        _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@", searchText];
        _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}
@end
