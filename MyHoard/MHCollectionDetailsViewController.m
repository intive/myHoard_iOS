//
//  MHCollectionDetailsViewController.m
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
#import "MHCollectionDetailsViewController.h"
#import "UIImage+Gallery.h"
#import "MHItemDetailsViewController.h"
#import "MHAddItemViewController.h"

typedef NS_ENUM(NSInteger, ItemSortMode) {
    ItemSortModeByName = 0,
    ItemSortModeByDate
};

#define HEADER_HEIGHT 44

@interface MHCollectionDetailsViewController ()

@property (nonatomic, assign) ItemSortMode sortMode;

@end

@implementation MHCollectionDetailsViewController
{
    UIView* _headerView;
    BOOL _isDragging;
    BOOL _isVisible;
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
    // Do any additional setup after loading the view, typically from a nib.
    
    self.menuButtonImage = [UIImage imageNamed:@"plus"];
    self.selectedMenuButtonImage = [UIImage imageNamed:@"cancel"];

    self.view.backgroundColor = [UIColor lighterGray];
    
    _collectionView.backgroundColor = [UIColor lighterGray];
    self.collectionName.title = _collection.objName;
    
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collection.items.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    MHCollectionDetailsCell *cell = (MHCollectionDetailsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MHItemCell" forIndexPath:indexPath];
    
    NSMutableArray *objects = [[NSMutableArray alloc]init];
    [objects addObjectsFromArray:_collection.items.allObjects];
    if (self.sortMode == ItemSortModeByName)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
        [objects sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    else if (self.sortMode == ItemSortModeByDate)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objCreatedDate" ascending:NO];
        [objects sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    MHItem *object = [objects objectAtIndex:indexPath.row];
    
    cell.itemTitle.textColor = [UIColor collectionNameFrontColor];
    cell.itemComment.textColor = [UIColor appBackgroundColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.mediaView.backgroundColor = [UIColor darkerGray];
    
    [self configureCell:cell withItem:object];
    
    return cell;
}


- (void)configureCell:(MHCollectionDetailsCell *)cell withItem:(MHItem *)item
{
    cell.itemComment.text = item.objDescription;
    cell.itemTitle.text = item.objName;

    for(MHMedia *media in item.media) {
        [UIImage thumbnailForAssetPath:media.objLocalPath completion:^(UIImage *image) {
            cell.mediaView.image = image;
        }];
        break; //just read first item
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self collectionView:_collectionView numberOfItemsInSection:[self numberOfSectionsInCollectionView:_collectionView]];
    
    if (count) {
        MHItem  *object = [_collection.items.allObjects  objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ShowItemDetails" sender:object];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowItemDetails"]) {
        MHItemDetailsViewController * vc = [segue destinationViewController];
        vc.item = sender;
    } else if ([segue.identifier isEqualToString:@"AddItemSegue"]) {
        UINavigationController* nc = segue.destinationViewController;
        MHAddItemViewController *vc = (MHAddItemViewController *)nc.visibleViewController;
        vc.selectedCollection = self.collection;
    }
}

#pragma mark - Collection header configure

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MHCollectionDetailsHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MHItemViewHeader" forIndexPath:indexPath];

        headerView.backgroundColor = [UIColor darkerGray];
        headerView.collectionTitle.textColor = [UIColor collectionNameFrontColor];
        headerView.collectionTags.textColor = [UIColor whiteColor];

        headerView.collectionTitle.text = _collection.objDescription.length ? _collection.objDescription : _collection.objName;
        
        for (NSString *tag in _collection.objTags) {
            headerView.collectionTags.text = [NSString stringWithFormat:@"%@#%@ ", headerView.collectionTags.text, tag];
        }
        
        reusableview = headerView;
    }
    
    
    return reusableview;
}

#pragma mark MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 1;
}

- (NSString*)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return [NSString stringWithFormat:@"Add item to '%@'", _collection.objName];
            break;
        default:
            return @"unused menu item";
    }
}

- (void)dropDownMenu:(MHDropDownMenu*)menu didSelectItemAtIndex:(NSUInteger)index {
    if (index == 0) {
        [self performSegueWithIdentifier:@"AddItemSegue" sender:nil];
    } else {
        NSLog(@"Unknown menu item %lu selected:", (unsigned long)index);
    }
    
}

#pragma mark scroll view

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_isVisible) return;
    _isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_isVisible) {
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
        self.sortMode = ItemSortModeByDate;
    } else {
        self.sortMode = ItemSortModeByName;
    }
    [self.collectionView reloadData];
}

@end