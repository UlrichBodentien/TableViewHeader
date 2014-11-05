//
//  ViewController.m
//  TableViewHeader
//
//  Created by David Anderson on 2014-08-25.
//  Copyright (c) 2014 ElectroBarn Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *temporaryView;

@property (assign, nonatomic) BOOL translatesAutoresizingMask;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // In iOS 8 beta 5 `self.headerView` (a.k.a. `self.tableView.tableHeaderView`) has `translatesAutoresizingMaskIntoConstraints` set to `YES` which results in a vertical height constraint equivalent to the height of the view in the storyboard (or whatever the frame was last set to in `-sizeHeaderToFit`). In our case we want to change the height of the `headerView` at runtime by modifying constraints. When we attempt to do this, the contraints in the system generated by `translatesAutoresizingMaskIntoConstraints = YES` conflict with our runtime constraints, and autolayout then discards (non-deterministically) one of the constraints, resulting in an undesirable, unexpected layout.
    // By disabling `translatesAutoresizingMaskIntoConstraints` before triggering a layout pass, and reenabling it afterward, the conflicting constraint is avoided and layout appears as expected, but ONLY if the `preferredMaxLayoutWidth` of the label is not set to automatic and has a value that is correct for the current resizeable simulator width. We do not want to have to calculate the `preferredMaxLayoutWidth` at runtime and expect to be able to use the automatic value.
    
    // ## Step 1
    [self disableAutoresizeMaskConstraints]; // disable this method and `reenableAutoresizeMaskConstraints` to trigger the unexpected conflicting constraints.
    
    // Unfortunately, by disabling the AutoresizingMaskConstraints, the current (runtime) width of the headerView is no longer constrained. Therefore, an "automatic" setting for `preferredMaxLayoutWidth` is unbounded and results in a single-line label that is not properly wrapped.

    // Thus, in order to avoid having an unconstrained width, we need to set up a width constraint that mimics the NSAutoresizingMaskLayoutConstraint that we have disabled, but leaving the height unconstrained.
    
    // ## Step 1.5
    CGFloat headerWidth = self.headerView.bounds.size.width;
    NSArray *temporaryWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[headerView(width)]" options:0 metrics:@{@"width": @(headerWidth)} views:@{@"headerView": self.headerView}];
    [self.headerView addConstraints:temporaryWidthConstraints];
    
    // ## Step 3
    [self sizeHeaderToFit];
    
    // now that we've coerced our headerView to lay out correctly, remove our temporary width contraint and reapply our autoresizeMaskConstraints

    // ## Step 3.5
    [self.headerView removeConstraints:temporaryWidthConstraints];

    // ## Step 4
    [self reenableAutoresizeMaskConstraints]; // disable this method and `disableAutoresizeMaskConstraints` to trigger the unexpected conflicting constraints.
}

- (void)sizeHeaderToFit {
    UIView *header = self.tableView.tableHeaderView;
    
    [header setNeedsLayout];
    [header layoutIfNeeded];
    
    CGSize headerSize = [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    CGRect frame = header.frame;
    
    frame.size.height = headerSize.height;
    header.frame = frame;
    
    self.tableView.tableHeaderView = header;
}

- (void)disableAutoresizeMaskConstraints {
    
    self.translatesAutoresizingMask = self.headerView.translatesAutoresizingMaskIntoConstraints;
    if (self.translatesAutoresizingMask) {
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
}

- (void)reenableAutoresizeMaskConstraints {
    self.headerView.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMask;
}

@end
