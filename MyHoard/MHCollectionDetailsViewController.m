//
//  MHCollectionDetailsViewController.m
//  MyHoard
//
//  Created by user on 2/16/14.
//  Copyright (c) 2014 BLStream. All rights reserved.
//
#import "MHCollectionDetailsViewController.h"
#import "MHItemDetailsViewController.h"
#import "MHAddItemViewController.h"
#import "MHImageCache.h"
#import "MHImagePickerViewController.h"
#import "MHAddCollectionViewController.h"
#import "MHItemDetailsPageViewController.h"

typedef NS_ENUM(NSInteger, ItemSortMode) {
    ItemSortModeByName = 0,
    ItemSortModeByDate
};

#define HEADER_HEIGHT 44

@interface MHCollectionDetailsViewController ()
{
    ItemSortMode _sortMode;
    NSArray* _items;
}

@end

@implementation MHCollectionDetailsViewController
{
    UIView* _headerView;
    BOOL _isDragging;
    BOOL _isVisible;
    UIButton* _dateButton;
    UIButton* _nameButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setSortMode:_sortMode]; //set sort mode again, so the _items array is correct after adding new item to the colelction.
    
    [_collectionView reloadData];
    _collectionName.title = _collection.objName;
}

- (void) setSortMode:(ItemSortMode)mode {
    _sortMode = mode;
    
    NSMutableArray* objects = [NSMutableArray arrayWithArray:[self.collection.items allObjects]];
    if (_sortMode == ItemSortModeByName)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objName" ascending:YES selector:@selector(localizedStandardCompare:)];
        [objects sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    else if (_sortMode == ItemSortModeByDate)
    {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"objCreatedDate" ascending:NO];
        [objects sortUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    _items = objects;

    [self.collectionView reloadData];
}

- (void)nameButton:(id) sender
{
    [self reverseSort];
}

- (void)dateButton:(id) sender
{
    [self reverseSort];
}

- (void)reverseSort
{
    NSArray *oldArray = [NSArray arrayWithArray:_items];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[_items count]];
    NSEnumerator *enumerator = [oldArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    _items = array;
    [self.collectionView reloadData];

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
    _dateButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 8, segmentedControl.frame.size.width / 2, segmentedControl.frame.size.height)];
    _nameButton = [[UIButton alloc] initWithFrame:CGRectMake(8 + (segmentedControl.frame.size.width / 2), 8, segmentedControl.frame.size.width / 2, segmentedControl.frame.size.height)];
    
    _dateButton.alpha = 1.0f;
    _nameButton.alpha = 1.0f;
    
    _dateButton.hidden = YES;
    
    [_dateButton addTarget:self action:@selector(dateButton:) forControlEvents:UIControlEventTouchUpInside];
    [_nameButton addTarget:self action:@selector(nameButton:) forControlEvents:UIControlEventTouchUpInside];
    [_headerView addSubview:_dateButton];
    [_headerView addSubview:_nameButton];
    
    
    [self.collectionView addSubview:_headerView];
    self.collectionView.alwaysBounceVertical = YES;
    
    [self setSortMode:ItemSortModeByName];
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
    
    MHItem *object = [_items objectAtIndex:indexPath.row];
    
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
    cell.mediaView.image = nil;

    for(MHMedia *media in item.media) {
        cell.mediaView.image = [[MHImageCache sharedInstance] thumbnailForKey:media.objKey];
        break; //just read first item
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = [self collectionView:_collectionView numberOfItemsInSection:[self numberOfSectionsInCollectionView:_collectionView]];
    
    if (count) {
        MHItem  *object = [_items  objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ShowItemDetails" sender:object];
    }
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowItemDetails"]) {
        MHItemDetailsPageViewController * vc = [segue destinationViewController];
        vc.item = sender;
    } else if ([segue.identifier isEqualToString:@"AddItemSegue"]) {
        UINavigationController* nc = segue.destinationViewController;
        MHAddItemViewController *vc = (MHAddItemViewController *)nc.visibleViewController;
        vc.selectedCollection = self.collection;
        NSDictionary* d = sender;
        vc.selectedImage = d[kMHImagePickerInfoImage];
        vc.selectedLocation = d[kMHImagePickerInfoLocation];
    } else if ([segue.identifier isEqualToString:@"ChangeCollectionSettingsSegue"])
    {
        UINavigationController *nc = segue.destinationViewController;
        MHAddCollectionViewController *vc = (MHAddCollectionViewController *)nc.visibleViewController;
        vc.collection = self.collection;
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
        
        NSMutableString* tags = [NSMutableString new];
        for (NSString *tag in _collection.objTags) {
            [tags appendFormat:@"#%@ ", tag];
        }
        headerView.collectionTags.text = tags;
        
        reusableview = headerView;
    }
    
    
    return reusableview;
}

#pragma mark MHDropDownMenu

- (NSInteger)numberOfItemsInDropDownMenu:(MHDropDownMenu *)menu {
    return 2;
}

- (NSString*)titleInDropDownMenu:(MHDropDownMenu *)menu atIndex:(NSInteger)index {
    switch (index) {
        case 0:
            return @"Add item to collection";
            break;
        case 1:
            return @"Edit collection";
            break;
        default:
            return @"unused menu item";
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
    } else if (index == 1) {
        [self performSegueWithIdentifier:@"ChangeCollectionSettingsSegue" sender:_collection];
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
        _dateButton.hidden = NO;
        _nameButton.hidden = YES;
        [self setSortMode:ItemSortModeByDate];
    } else {
        _dateButton.hidden = YES;
        _nameButton.hidden = NO;
        [self setSortMode:ItemSortModeByName];
    }
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    MHImagePickerViewController *imagePickerController = [[MHImagePickerViewController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.completionBlock = ^(NSDictionary* info) {
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


@end