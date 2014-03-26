//
//  MHCollectionViewController.m
//  MyHoard
//
//  Created by Kacper Tłusty on 11.03.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import "MHCollectionViewController.h"
#import "MHItemViewController.h"

typedef NS_ENUM(NSInteger, CollectionSortMode) {
    CollectionSortModeByName = 0,
    CollectionSortModeByDate
};

@interface MHCollectionViewController ()

@property (nonatomic, strong) MHBadgeView *badge;
@property (nonatomic, assign) CollectionSortMode sortMode;

-(void)resetIdleTimer;
-(void)idleTimerExceeded;

@end

@implementation MHCollectionViewController
{
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
    NSTimer *timeToChangeCollection;
    UICollectionViewCell *animatingCell;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
        [super awakeFromNib];
}
    
- (void)viewDidLoad
{

    [super viewDidLoad];
    [self setEnableMHLogo:YES];
    // Do any additional setup after loading the view, typically from a nib.

    
    _objectChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
    animatingCell = nil;
    
    self.collectionView.backgroundColor = [UIColor appBackgroundColor];
    self.sortMode = CollectionSortModeByDate;
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
        
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MHCollectionCell *cell = (MHCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MHCollectionCell" forIndexPath:indexPath];
        
    MHCollection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.collectionTitle.text = object.objName;
    
    if ([object.objItemsNumber isEqualToNumber:@0]) {
        
        _badge.hidden = YES;
        
    }else {
        
        _badge = [MHBadgeView createBadgeWithValue:object.objItemsNumber withTextColor:[UIColor darkerGray] withBackgroundColor:[UIColor darkerYellow] withScale:1.0];
        
        _badge.frame = CGRectMake(102, 110, _badge.frame.size.width, _badge.frame.size.height);
        
    }
    
    [cell.contentView addSubview:_badge];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    MHCollection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"ShowItemsSegue" sender:object];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MHItemViewController * vc = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"ShowItemsSegue"]) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        vc.collection = [self.fetchedResultsController objectAtIndexPath:indexPaths[0]];

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

-(void)sendEvent:(UIEvent *)event
{
    [self resetIdleTimer];
}

-(void)resetIdleTimer
{
    [self stopAnimationTimer];
    timeToChangeCollection = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];

}

-(void)idleTimerExceeded
{
    if (animatingCell != nil) {
        //[animatingCell.kenberns animeStop];
    }
    NSNumber *randomCell = [NSNumber numberWithUnsignedLong:(rand() % [self.collectionView numberOfSections])];
    NSIndexPath *cellPath = [NSIndexPath indexPathWithIndex:[randomCell unsignedIntegerValue]];
    
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MHCollectionCell" forIndexPath:cellPath];
    [self.collectionView scrollToItemAtIndexPath:cellPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    //animating and showing cell, other things which needs to be implemented
    //[cell.KenBerns anime];
    animatingCell = cell;
    [self resetIdleTimer];
}

- (NSFetchedResultsController*) sortByName{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    return frc;
}

- (NSFetchedResultsController*) sortByDate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MHCollection" inManagedObjectContext:[MHCoreDataContext getInstance].managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objCreatedDate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[MHCoreDataContext getInstance].managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    return frc;
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

- (void)stopAnimationTimer
{
    [timeToChangeCollection invalidate];
    timeToChangeCollection = nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimationTimer];
}

#pragma mark MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 2;
}

- (NSString*)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"Add collection";
            break;
        default:
            return @"unused menu item";
    }
}

- (UIColor*)backgroundColorInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    return [UIColor navigationBarBackgroundColor];
}

- (void)dropDownMenu:(MHDropDownMenu*)menu didSelectItemAtIndex:(NSUInteger)index {
    if (index == 0) {
        [self performSegueWithIdentifier:@"AddCollectionSegue" sender:nil];
    } else {
        NSLog(@"Unknown menu item %lu selected:", (unsigned long)index);
    }
}

@end