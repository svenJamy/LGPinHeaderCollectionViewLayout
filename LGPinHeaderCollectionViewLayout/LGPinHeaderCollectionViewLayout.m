//
//  LGPinHeaderCollectionViewLayout.m
//  LGPinHeaderCollectionViewLayout
//
//  Created by gujianming on 21/06/2017.
//  Copyright © 2017 jamy. All rights reserved.
//

#import "LGPinHeaderCollectionViewLayout.h"

@interface LGPinHeaderCollectionViewLayout ()
@property (nonatomic, assign, readonly) BOOL stickyHeaders;
@property (nonatomic, assign, readonly) CGFloat pinHeight;
@end

@implementation LGPinHeaderCollectionViewLayout

- (instancetype)initWithStickyHeaders:(BOOL)stickyHeaders pinHeight:(CGFloat)pinHeight {
  if (self = [super init]) {
    _stickyHeaders = stickyHeaders;
    _pinHeight = pinHeight;
  }
  return self;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  const CGRect oldBounds = self.collectionView.bounds;
  if (CGRectGetMinY(newBounds) != CGRectGetMinY(oldBounds)) {
    return YES;
  }
  return !CGSizeEqualToSize(oldBounds.size, newBounds.size);
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
  NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
  
  if (!self.stickyHeaders) {
    return [attributes copy];
  }
  
  NSInteger numberOfSections = self.collectionView.numberOfSections;
  if (numberOfSections == 0) {
    return attributes;
  }
  
  UICollectionViewLayoutAttributes *headerAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
  if (headerAttributes.frame.size.width > 0 && headerAttributes.frame.size.height > 0 && ![attributes containsObject:headerAttributes]) {
    [attributes addObject:headerAttributes];
  }
  
  for (UICollectionViewLayoutAttributes *itemAttributes in attributes) {
    if (itemAttributes.representedElementKind == UICollectionElementKindSectionHeader && itemAttributes.indexPath.section == 0) {
      UICollectionViewLayoutAttributes *headerAttributes = itemAttributes;
      CGPoint contentOffset = self.collectionView.contentOffset;
      CGPoint originInCollectionView = CGPointMake(headerAttributes.frame.origin.x - contentOffset.x, headerAttributes.frame.origin.y - contentOffset.y);
      originInCollectionView.y -= self.collectionView.contentInset.top;
      CGRect frame = headerAttributes.frame;
      const CGFloat fixedOffset = frame.size.height - self.pinHeight;
      if (originInCollectionView.y < -fixedOffset) {
        frame.origin.y += -(originInCollectionView.y + fixedOffset);
      }
      
      headerAttributes.frame = frame;
      headerAttributes.zIndex = 1024;
      break;
    }
  }
  
  return [attributes copy];
}

/// for ios8 bug
- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
  UICollectionViewLayoutAttributes *attribute = [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
  if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
    attribute.zIndex = 1024;
  }
  return attribute;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
  UICollectionViewLayoutAttributes *attribute = [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
  if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
    attribute.zIndex = 1024;
  }
  return attribute;
}

@end
