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

#define HEADER_HEIGHT 44

NSString *const scopeTypeAll = @"All";
NSString *const scopeTypeName = @"Name";
NSString *const scopeTypeDescription = @"Description";

@interface MHSearchViewController () {
    UIView* _headerView;
    NSString * _scope;
    BOOL _isVisible, _isDragging;
}

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
    
    [self.navigationController setNavigationBarHidden:NO]; // so menu would be available for user
    _tableView.backgroundColor = [UIColor appBackgroundColor];
    _coreDataSearchResults = [[NSArray alloc]init];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - HEADER_HEIGHT, self.view.frame.size.width, HEADER_HEIGHT)];
    _headerView.backgroundColor = [UIColor blackColor];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"All", @"Name", @"Description", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.frame = CGRectMake(8, 8, _headerView.frame.size.width - 16, _headerView.frame.size.height - 16);
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl.selectedSegmentIndex = 0;
    segmentedControl.layer.borderColor = [UIColor lighterYellow].CGColor;
    segmentedControl.layer.borderWidth = 1.0;
    segmentedControl.layer.cornerRadius = 6.0;
    segmentedControl.tintColor = [UIColor lighterYellow];
    
    [segmentedControl addTarget:self
                         action:@selector(segmentedControlValueChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [_headerView addSubview:segmentedControl];
    [_tableView addSubview:_headerView];
    _tableView.alwaysBounceVertical = YES;
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
    scope = _scope;
    
    if ([scope isEqualToString:scopeTypeName]) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@", searchText];
        _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
    }else if ([scope isEqualToString:scopeTypeDescription]) {
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

#pragma mark segmented control

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    NSInteger index = [sender selectedSegmentIndex];
    switch (index) {
        case 0:
            _scope = scopeTypeAll;
            break;
        case 1:
            _scope = scopeTypeName;
            break;
        case 2:
            _scope = scopeTypeDescription;
            break;
        default:
            _scope = scopeTypeAll;
            break;
    }
    [_tableView reloadData];
}

#pragma mark scroll view

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isVisible) return;
    _isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isVisible) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            _tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -HEADER_HEIGHT)
            _tableView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (_isDragging && scrollView.contentOffset.y < 0) {
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _isDragging = NO;
    
    if (_isVisible) {
        if (scrollView.contentOffset.y < 0) {
            _isVisible = NO;
            [UIView animateWithDuration:0.3 animations:^{
                _tableView.contentInset = UIEdgeInsetsZero;
            }];
        }
    } else {
        if (scrollView.contentOffset.y <= -HEADER_HEIGHT) {
            _isVisible = YES;
            [UIView animateWithDuration:0.3 animations:^{
                _tableView.contentInset = UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0);
            }];
        }
    }
}

@end
