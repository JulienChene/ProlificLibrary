//
//  BookDetailViewController.h
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@protocol bookDetailViewControllerDelegate <NSObject>

- (void)bookCheckoutWithBook:(Book*)book;

@end

@interface BookDetailViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate>
{
    float checkoutViewTopSpaceContraintConstant;
}

@property (assign, nonatomic) id<bookDetailViewControllerDelegate>  delegate;
@property (strong, nonatomic) Book  *currentBook;

@property (weak, nonatomic) IBOutlet UILabel  *bookTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bookAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bookPublisherLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bookCategoriesLabel;
@property (weak, nonatomic) IBOutlet UILabel  *bookCheckOutLabel;
@property (weak, nonatomic) IBOutlet UILabel  *daysToGoLabel;

@property (weak, nonatomic) IBOutlet UISlider *bookCheckOutSlider;

@property (weak, nonatomic) IBOutlet UIView   *coverView;
@property (weak, nonatomic) IBOutlet UIView   *checkoutView;
@property (weak, nonatomic) IBOutlet UIView   *nameView;

@property (weak, nonatomic) IBOutlet UITextField        *nameTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameTextFieldLeadingSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameViewLeadingSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverViewTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *coverViewBottomSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkoutViewTopSpaceConstraint;

@end
