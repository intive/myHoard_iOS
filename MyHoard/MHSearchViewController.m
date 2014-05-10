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
#import "UIImage+customImage.h"
#import "MHItemDetailsViewController.h"

#define HEADER_HEIGHT 44

NSString *const scopeTypeAll = @"All";
NSString *const scopeTypeName = @"Name";
NSString *const scopeTypeDescription = @"Description";

@interface MHSearchViewController () {
    UIView* _headerView;
    NSString * _scope;
    BOOL _isVisible, _isDragging, _noResults;
}

@property (nonatomic, strong) NSArray *coreDataCollections;
@property (nonatomic, strong) NSArray *coreDataSearchResults;
@property (nonatomic, strong) NSMutableArray *coreDataItems;
@property (nonatomic, strong) NSArray *coredataItemsSearchResult;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

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
    _coredataItemsSearchResult = [[NSArray alloc]init];
    
    _searchBar.barTintColor = [UIColor lighterGray];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor lightLoginAndRegistrationTextFieldTextColor]];
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor lightLoginAndRegistrationTextFieldTextColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:@{UITextAttributeTextColor: [UIColor lightLoginAndRegistrationTextFieldTextColor]} forState:UIControlStateNormal];
    [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor appBackgroundColor] size:CGSizeMake(320, 30)] forState:UIControlStateNormal];
    [_searchBar becomeFirstResponder];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - HEADER_HEIGHT, self.view.frame.size.width, HEADER_HEIGHT)];
    _headerView.backgroundColor = [UIColor blackColor];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"All", @"Name", @"Description", nil];
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    _segmentedControl.frame = CGRectMake(8, 8, _headerView.frame.size.width - 16, _headerView.frame.size.height - 16);
    _segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    _segmentedControl.selectedSegmentIndex = 0;
    _segmentedControl.layer.borderColor = [UIColor lighterYellow].CGColor;
    _segmentedControl.layer.borderWidth = 1.0;
    _segmentedControl.layer.cornerRadius = 6.0;
    _segmentedControl.tintColor = [UIColor lighterYellow];
    
    [_segmentedControl addTarget:self
                         action:@selector(segmentedControlValueChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [_headerView addSubview:_segmentedControl];
    [_tableView addSubview:_headerView];
    _tableView.alwaysBounceVertical = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [self update];
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
    _coredataItemsSearchResult = nil;
    _coreDataItems = [self allItems];
    [_tableView reloadData];
}

- (NSMutableArray *)allItems {
    
    _coreDataItems = [[NSMutableArray alloc]init];
    
    if ([_coreDataCollections count]) {
        for (MHCollection *collection in _coreDataCollections) {
            for (MHItem *item in collection.items) {
                [_coreDataItems addObject:item];
            }
        }
    }
    return _coreDataItems;
}

#pragma mark - table view delegate methods

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Collections";
    }else {
        return @"Items";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_coreDataSearchResults count] == 0) {
                _noResults = YES;
                return 1;
            }else {
                _noResults = NO;
                return [_coreDataSearchResults count];
            }
        }else {
            return [_coreDataCollections count];
        }
    }else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_coreDataItems count] == 0) {
                _noResults = YES;
                return 1;
            }else {
                _noResults = NO;
                return [_coredataItemsSearchResult count];
            }
        }else {
            return [_coreDataItems count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.searchDisplayController.searchResultsTableView && _noResults) {
        
        tableView.backgroundColor = [UIColor appBackgroundColor];

        static NSString *cellId = @"emptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            cell.userInteractionEnabled = NO;
            cell.backgroundColor = [UIColor appBackgroundColor];
        }
        
        return cell;
    }
    
    static NSString *cellId = @"searchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if ([indexPath section] == 0) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            MHCollection *collection = [_coreDataSearchResults objectAtIndex:indexPath.row];
            cell.textLabel.text = collection.objName;
        }else {
            MHCollection *collection = [_coreDataCollections objectAtIndex:indexPath.row];
            cell.textLabel.text = collection.objName;
        }
    }else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            MHItem *item = [_coredataItemsSearchResult objectAtIndex:indexPath.row];
            cell.textLabel.text = item.objName;
        }else {
            MHItem *item = [_coreDataItems objectAtIndex:indexPath.row];
            cell.textLabel.text = item.objName;
        }
    }
    cell.textLabel.textColor = [UIColor collectionNameFrontColor];
    cell.backgroundColor = [UIColor appBackgroundColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0) {
        if (_tableView == self.searchDisplayController.searchResultsTableView) {
            MHCollection *collection = [_coreDataSearchResults objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"collectionDetails" sender:collection];
        }else {
            MHCollection *collection = [_coreDataCollections objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"collectionDetails" sender:collection];
        }
    }else {
        if (_tableView == self.searchDisplayController.searchResultsTableView) {
            MHItem *item = [_coredataItemsSearchResult objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"itemDetails" sender:item];
        }else {
            MHItem *item = [_coreDataItems objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"itemDetails" sender:item];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

#pragma mark - segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"collectionDetails"]) {
        MHCollectionDetailsViewController * vc = [segue destinationViewController];
        vc.collection = sender;
    }else if ([segue.identifier isEqualToString:@"itemDetails"]) {
        MHItemDetailsViewController * vc = [segue destinationViewController];
        vc.item = sender;
    }
}

#pragma mark - search delegate methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    
    NSPredicate *predicate;
    scope = _scope;
    _coreDataSearchResults = nil;
    
    if (searchText.length < 3) {
        _coreDataSearchResults = _coreDataCollections;
        _coredataItemsSearchResult = _coreDataItems;
    }else {
        if ([scope isEqualToString:scopeTypeName]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@", searchText];
            _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
            _coredataItemsSearchResult = [_coreDataItems filteredArrayUsingPredicate:predicate];
        }else if ([scope isEqualToString:scopeTypeDescription]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.objDescription beginswith[c] %@", searchText];
            _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
            _coredataItemsSearchResult = [_coreDataItems filteredArrayUsingPredicate:predicate];
        }else {
            predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@", searchText];
            _coreDataSearchResults = [_coreDataCollections filteredArrayUsingPredicate:predicate];
            _coredataItemsSearchResult = [_coreDataItems filteredArrayUsingPredicate:predicate];
        }
    }
    
    if (searchText.length > 12) {
        [_searchBar resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Search fraze can be no longer than 12 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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

#pragma mark - search bar utility methods

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    
    if (!_isVisible) {
        _segmentedControl.hidden = YES;
    }
    
    CGRect statusBarFrame =  [[UIApplication sharedApplication] statusBarFrame];
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.transform = CGAffineTransformMakeTranslation(0, statusBarFrame.size.height + 20);
        }
    }];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    
    [UIView animateWithDuration:0.25 animations:^{
        for (UIView *subview in self.view.subviews) {
            subview.transform = CGAffineTransformIdentity;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            _segmentedControl.hidden = NO;
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _coreDataSearchResults = nil;
    [_tableView reloadData];
}

#pragma mark - keyboard observers

- (void)keyboardDidShow: (NSNotification *) notif{
    
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.frame = CGRectOffset(_tableView.frame, 0, -20);
    }];
}

- (void)keyboardDidHide: (NSNotification *) notif{
    
    [UIView animateWithDuration:0.25 animations:^{
        _tableView.frame = CGRectOffset(_tableView.frame, 0, 0);
    }];
}

@end
