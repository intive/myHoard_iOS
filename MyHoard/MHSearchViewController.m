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
#import "MHItemDetailsPageViewController.h"
#import "MHAPI.h"

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
@property (nonatomic, strong) NSArray *coredataItemsSearchResult;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) UITableViewCell *tableCell;

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
    [_tableView reloadData];
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
            _noResults = YES;
            return 1;
        }
    }else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_coredataItemsSearchResult count] == 0) {
                _noResults = YES;
                return 1;
            }else {
                _noResults = NO;
                return [_coredataItemsSearchResult count];
            }
        }else {
            _noResults = YES;
            return 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.backgroundColor = [UIColor appBackgroundColor];
    
    static NSString *cellId = @"searchCell";
    _tableCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (_tableCell == nil) {
        _tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    if ([indexPath section] == 0) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_coreDataSearchResults count]) {
                MHCollection *collection = [_coreDataSearchResults objectAtIndex:indexPath.row];
                _tableCell.textLabel.text = collection.objName;
                _tableCell.userInteractionEnabled = YES;
            }else {
                _tableCell.textLabel.text = @"";
                _tableCell.userInteractionEnabled = NO;
            }
        }else {
            _tableCell.textLabel.text = @"Search for collection";
            _tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
            _tableCell.userInteractionEnabled = NO;
        }
    }else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            if ([_coredataItemsSearchResult count]) {
                MHItem *item = [_coredataItemsSearchResult objectAtIndex:indexPath.row];
                _tableCell.textLabel.text = item.objName;
                _tableCell.userInteractionEnabled = YES;
            }else {
                _tableCell.textLabel.text = @"";
                _tableCell.userInteractionEnabled = NO;
            }
        }else {
            _tableCell.textLabel.text = @"Search for item";
            _tableCell.textLabel.textAlignment = NSTextAlignmentCenter;
            _tableCell.userInteractionEnabled = NO;
        }
    }
    _tableCell.textLabel.textColor = [UIColor collectionNameFrontColor];
    _tableCell.backgroundColor = [UIColor appBackgroundColor];
    
    return _tableCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath section] == 0) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            MHCollection *collection = [_coreDataSearchResults objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"collectionDetails" sender:collection];
        }
    }else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            MHItem *item = [_coredataItemsSearchResult objectAtIndex:indexPath.row];
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
        MHItemDetailsPageViewController * vc = [segue destinationViewController];
        vc.item = sender;
    }
}

#pragma mark - search delegate methods

- (void)filterContentForSearchText:(NSString *)searchText scope:(NSString *)scope {
    
    NSPredicate *predicate;
    scope = _scope;
    
    if (searchText.length < 3) {
        _coreDataSearchResults = nil;
        _coredataItemsSearchResult = nil;
    }else {
        if ([scope isEqualToString:scopeTypeName]) {
            [self checkForActiveSessionAndSetPredicate:predicate withSearchText:searchText];
        }else if ([scope isEqualToString:scopeTypeDescription]) {
            if ([MHAPI getInstance].userId) {
                predicate = [NSPredicate predicateWithFormat:@"SELF.objDescription beginswith[c] %@ AND SELF.objOwner == %@", searchText, [MHAPI getInstance].userId];
                [self fetchAllCollectionsWithPredicate:predicate];
                [self fetchAllItemsWithPredicate:predicate];
            }else {
                predicate = [NSPredicate predicateWithFormat:@"SELF.objDescription beginswith[c] %@ AND SELF.objOwner == %@", searchText, nil];
                [self fetchAllCollectionsWithPredicate:predicate];
                [self fetchAllItemsWithPredicate:predicate];
            }
        }else {
            [self checkForActiveSessionAndSetPredicate:predicate withSearchText:searchText];
        }
    }
    
    if (searchText.length > 20) {
        [_searchBar resignFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Search fraze can be no longer than 20 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [_tableView reloadData];
}

- (void)checkForActiveSessionAndSetPredicate:(NSPredicate *)predicate withSearchText:(NSString *)searchText {
    if ([MHAPI getInstance].userId) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@ AND SELF.objOwner == %@", searchText, [MHAPI getInstance].userId];
        [self fetchAllCollectionsWithPredicate:predicate];
        [self fetchAllItemsWithPredicate:predicate];
    }else {
        predicate = [NSPredicate predicateWithFormat:@"SELF.objName beginswith[c] %@ AND SELF.objOwner == %@", searchText, nil];
        [self fetchAllCollectionsWithPredicate:predicate];
        [self fetchAllItemsWithPredicate:predicate];
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
    _coredataItemsSearchResult = nil;
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

#pragma mark - FRC

- (void)fetchAllItemsWithPredicate:(NSPredicate *)predicate {
    
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHItem" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError *error = nil;
    [_frc performFetch:&error];
    
    if (!error) {
        _coredataItemsSearchResult = [_frc fetchedObjects];
    }
}

- (void)fetchAllCollectionsWithPredicate:(NSPredicate *)predicate {
    
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    NSError *error = nil;
    [_frc performFetch:&error];
    
    if (!error) {
        _coreDataSearchResults = [_frc fetchedObjects];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_frc != nil) {
        return _frc;
    }
    _frc.delegate = self;
    return _frc;
}

@end
