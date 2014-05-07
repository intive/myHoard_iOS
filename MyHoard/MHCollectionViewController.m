//
//  MHCollectionViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollectionViewController.h"
#import "MHCollectionDetailsViewController.h"
#import "MHAddItemViewController.h"
#import "MHMedia.h"
#import "MHAPI.h"
#import "MHImagePickerViewController.h"
#import "MHImageCache.h"



typedef NS_ENUM(NSInteger, CollectionSortMode) {
    CollectionSortModeByName = 0,
    CollectionSortModeByDate
};

#define HEADER_HEIGHT 44

@interface MHCollectionViewController ()

@property (nonatomic, assign) CollectionSortMode sortMode;

@end

@implementation MHCollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    
    NSTimer *_cellSelectionTimer;
    MHCollectionCell *_selectedCell;
    
    UIView* _headerView;
    BOOL _isDragging;
    BOOL _isVisible;
}

- (void)viewWillAppear:(BOOL)animated {
    [_selectedCell.kenBurnsView stopAnimation];
    _selectedCell = nil;

    [_collectionView reloadData];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_selectedCell.kenBurnsView stopAnimation];
    _selectedCell = nil;

    [self stopCellSelectionTimer];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [self setEnableMHLogo:YES];
    // Do any additional setup after loading the view, typically from a nib.
    self.menuButtonImage = [UIImage imageNamed:@"plus"];
    self.selectedMenuButtonImage = [UIImage imageNamed:@"cancel"];
    
    self.title = @"";
    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    
    self.collectionView.backgroundColor = [UIColor appBackgroundColor];
    self.sortMode = CollectionSortModeByName;
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - HEADER_HEIGHT, self.view.frame.size.width, HEADER_HEIGHT)];
    _headerView.backgroundColor = [UIColor blackColor];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Date", @"Name", nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
    segmentedControl.frame = CGRectMake(8, 8, _headerView.frame.size.width - 16, _headerView.frame.size.height - 16);
    segmentedControl.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl.selectedSegmentIndex = 1;
    segmentedControl.layer.borderColor = [UIColor lighterYellow].CGColor;
    segmentedControl.layer.borderWidth = 1.0;
    segmentedControl.layer.cornerRadius = 6.0;
    segmentedControl.tintColor = [UIColor lighterYellow];
    
    [segmentedControl addTarget:self
                         action:@selector(segmentedControlValueChanged:)
               forControlEvents:UIControlEventValueChanged];
    
    [_headerView addSubview:segmentedControl];
    [self.collectionView addSubview:_headerView];
    self.collectionView.alwaysBounceVertical = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionVIew
    
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = [self numberOfCollectionsInDatabaseForSection:section];
    if (count == 0) { //add one dummy element with +
        count = 1;
    }
    return count;
}
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MHCollectionCell *cell = (MHCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MHCollectionCell" forIndexPath:indexPath];
    
    cell.collectionTitle.textColor = [UIColor collectionNameFrontColor];
    cell.kenBurnsView.backgroundColor = [UIColor darkerGray];
    cell.tagsView.backgroundColor = [UIColor clearColor];

    if ([self numberOfCollectionsInDatabaseForSection:indexPath.section] == 0) { //special case for + element
        cell.collectionTitle.text = @"Name";
        cell.badgeView.hidden = YES;
        cell.tagsView.tagList = @[@"Tags"];
        cell.plusSignImageView.hidden = NO;
    } else {
        MHCollection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
#pragma mark - cell setup
        
        cell.plusSignImageView.hidden = YES;
        
        [self configureCell:cell withCollection:object];
    }
    
    return cell;
}

#pragma mark - cell configuration with images

- (void)configureCell:(MHCollectionCell *)cell withCollection:(MHCollection *)collection {
    
    cell.collectionTitle.text = collection.objName;
    
    if (collection.items.count == 0) {
        cell.badgeView.hidden = YES;
    }else {
        cell.badgeView.badgeValue = @(collection.items.count);
        cell.badgeView.hidden = NO;
    }
    
    cell.tagsView.tagList = collection.objTags;

    [cell.kenBurnsView removeAllImages];
    
    NSMutableArray* items = [NSMutableArray arrayWithArray:collection.items.allObjects];

    if (_selectedCell == nil) {
        _selectedCell = cell;
        
        NSInteger max = collection.items.count < 5 ? collection.items.count : 5;

        [self addImages:max from:items toCell:cell];
        
        [self startCellSelectionTimer];
        
    } else {

        [self addImages:1 from:items toCell:cell];
        
    }
}

- (void)addImages:(NSInteger)numberOfImages from:(NSMutableArray *)items toCell:(MHCollectionCell *)cell {
    NSInteger current = 0;
    if (items.count) {
        while (current < numberOfImages) {
            MHItem* item = items[arc4random() % items.count];
            [items removeObject:item];
            if (item.media.count) {
                for(MHMedia* media in item.media) {
                    UIImage* image = [[MHImageCache sharedInstance] thumbnailForKey:media.objKey];
                    [cell.kenBurnsView addImage:image];
                    current++;
                    if (current == numberOfImages) {
                        [cell.kenBurnsView startAnimation];
                    }
                }
            } else {
                current++;
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self numberOfCollectionsInDatabaseForSection:indexPath.section];

    if (count) {
        MHCollection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"ShowItemsSegue" sender:object];
    } else {
        //special case for empty collection list - add new collection
        [self performSegueWithIdentifier:@"AddCollectionSegue" sender:nil];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowItemsSegue"]) {
        MHCollectionDetailsViewController * vc = [segue destinationViewController];
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        vc.collection = [self.fetchedResultsController objectAtIndexPath:indexPaths[0]];
    } else if ([segue.identifier isEqualToString:@"AddItemSegue"]) {
        UINavigationController* nc = segue.destinationViewController;
        MHAddItemViewController *vc = (MHAddItemViewController *)nc.visibleViewController;
        NSDictionary* info = sender;
        vc.selectedImage = info[kMHImagePickerInfoImage];
        vc.selectedLocation = info[kMHImagePickerInfoLocation];
    }
}

#pragma mark - Fetched results controller
    
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
    return _fetchedResultsController;
    }

    if (_sortMode == CollectionSortModeByDate) {
        _fetchedResultsController = [self sortByDate];
    } else {
        _fetchedResultsController = [self sortByName];
    }
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
        
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
        }
        
    [_sectionChanges addObject:change];
}
    
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}
    
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert:
                            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                            break;
                    }
                }];
            }
        } completion:nil];
    }
        
    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
    {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || self.collectionView.window == nil) {
            [self.collectionView reloadData];
                
        } else {
            
            [self.collectionView performBatchUpdates:^{
                    
                for (NSDictionary *change in _objectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                            
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
        
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}
    
- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in self->_objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
        
    return shouldReload;
}

- (void)startCellSelectionTimer {
    [self stopCellSelectionTimer];
    _cellSelectionTimer = [NSTimer scheduledTimerWithTimeInterval:[MHKenBurns animationDuration] target:self selector:@selector(cellSelectionTimerFired) userInfo:nil repeats:NO];
}

- (void)stopCellSelectionTimer {
    [_cellSelectionTimer invalidate];
    _cellSelectionTimer = nil;
    
}

- (void)cellSelectionTimerFired
{
    [_selectedCell.kenBurnsView stopAnimation];
    _selectedCell = nil;
    
    NSArray *visibleCells = [self.collectionView indexPathsForVisibleItems];
    NSIndexPath *cellPath = visibleCells[arc4random() % visibleCells.count];
    
    MHCollectionCell *cell = (MHCollectionCell *)[self.collectionView cellForItemAtIndexPath:cellPath];
    [self.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];

    MHCollection *object = [self.fetchedResultsController objectAtIndexPath:cellPath];
    
    [self configureCell:cell withCollection:object];

}

- (NSFetchedResultsController*) sortByName{
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objOwner = %@", [[MHAPI getInstance]userId]]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    return frc;
}

- (NSFetchedResultsController*) sortByDate{
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"objOwner = %@", [[MHAPI getInstance]userId]]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objCreatedDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    return frc;
}

- (NSInteger)numberOfCollectionsInDatabaseForSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (void)setSortMode:(CollectionSortMode)sortMode {
    _sortMode = sortMode;
    _fetchedResultsController = nil;
    
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
}

#pragma mark MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 2;

}

- (NSString*)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    NSString *ret = @"";
    switch (index) {
        case 0:
            ret = @"Element";
            break;
        case 1:
            ret = @"Collection";
            break;
    }
    return ret;
}

- (UIImage *)imageInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index{
    switch (index) {
        case 0:
            return [UIImage imageNamed:@"element_y"];
            break;
        case 1:
            return [UIImage imageNamed:@"collection_y"];
            break;
        default:
            return nil;
    }
}

- (void)dropDownMenu:(MHDropDownMenu*)menu didSelectItemAtIndex:(NSUInteger)index {
    if (index == 0)
    {
        UIActionSheet *alert = [[UIActionSheet alloc]initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:@"Create without photo", @"Take a photo", @"Choose from library", nil];
        [alert showInView:self.view];
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [alert setButton:1 toState:NO];
        }
    }
    
    else if (index == 1) {
        [self performSegueWithIdentifier:@"AddCollectionSegue" sender:nil];
    } else {
        NSLog(@"Unknown menu item %lu selected:", (unsigned long)index);
    }
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {

    MHImagePickerViewController *imagePickerController = [[MHImagePickerViewController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.completionBlock = ^(NSDictionary *info) {
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self performSegueWithIdentifier:@"AddItemSegue" sender:info];
        }];

    };

    [self presentViewController:imagePickerController animated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex){
        case 0:
            [self performSegueWithIdentifier:@"AddItemSegue" sender:nil];
            break;
        case 1:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
            break;
        case 2:
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
    }
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
            self.collectionView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -HEADER_HEIGHT)
            self.collectionView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (_isDragging && scrollView.contentOffset.y < 0) {
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _isDragging = NO;

    if (_isVisible) {
        if (scrollView.contentOffset.y < 0) {
            _isVisible = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.collectionView.contentInset = UIEdgeInsetsZero;
            }];
        }
    } else {
        if (scrollView.contentOffset.y <= -HEADER_HEIGHT) {
            _isVisible = YES;
            [UIView animateWithDuration:0.3 animations:^{
                self.collectionView.contentInset = UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0);
            }];
        }
    }
}

#pragma mark segmented control

- (void)segmentedControlValueChanged:(UISegmentedControl *)sender {
    NSInteger index = [sender selectedSegmentIndex];
    if (index == 0) {
        self.sortMode = CollectionSortModeByDate;
    } else {
        self.sortMode = CollectionSortModeByName;
    }
    [self.collectionView reloadData];
}

@end