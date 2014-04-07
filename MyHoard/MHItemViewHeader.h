//
//  MHItemViewHeader.h
//  MyHoard
//
//  Created by Kacper Tłusty on 07.04.2014.
//  Copyright (c) 2014 BLStream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHItemViewHeader : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *collectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *collectionTags;

@end
