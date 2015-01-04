//
//  BookDetailViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "BookDetailViewController.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>

// TODO : Deal with picker

@implementation BookDetailViewController

@synthesize delegate;
@synthesize currentBook;

@synthesize bookTitleLabel;
@synthesize bookAuthorLabel;
@synthesize bookPublisherLabel;
@synthesize bookCategoriesLabel;
@synthesize bookCheckOutLabel;
@synthesize daysToGoLabel;

@synthesize bookCheckOutSlider;

@synthesize coverView;
@synthesize checkoutView;
@synthesize nameView;

@synthesize nameTextField;

@synthesize nameTextFieldWidthConstraint;
@synthesize nameTextFieldLeadingSpaceConstraint;
@synthesize pickerWidthConstraint;

@synthesize nameViewWidthConstraint;
@synthesize nameViewLeadingSpaceConstraint;

@synthesize coverViewTopSpaceConstraint;
@synthesize coverViewBottomSpaceConstraint;

@synthesize checkoutViewTopSpaceConstraint;

- (void)viewdidLoad
{
    [super viewDidLoad];
    
    checkoutViewTopSpaceContraintConstant = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Setting up checkoutView Top Space Constraint and placing checkout view in the middle of the view
    checkoutViewTopSpaceContraintConstant = ([[UIScreen mainScreen] bounds].size.height - checkoutView.frame.size.height) / 2;
    checkoutViewTopSpaceConstraint.constant = checkoutViewTopSpaceContraintConstant;
    
    [bookTitleLabel setText:[currentBook bookTitle]];
    
    [bookAuthorLabel setText:[currentBook bookAuthor]];
    
    // Book Publisher Label
    // Handling the case there is no publisher
    NSString *publisher = [currentBook bookPublisher];
    if ([publisher isEqualToString:@""])
        publisher = @"N/A";
        
    [bookPublisherLabel setText:[NSString stringWithFormat:@"Publisher: %@", publisher]];
    
    [bookCategoriesLabel setText:[NSString stringWithFormat:@"Tags: %@", [currentBook bookCategories]]];
    
    // Book Check Out Label
    // Handling the case where the book was never checked out before
    [self bookCheckoutHandler];
    
    // Setting blue border checkout box
    [checkoutView.layer setBorderWidth:0.5];
    [checkoutView.layer setBorderColor:[UIColor blueColor].CGColor];
    
    // Setting text field frame
    nameTextFieldWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width - (nameTextFieldLeadingSpaceConstraint.constant * 2);
    
    // Setting nameView width
    nameViewWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width * 2;
    
    // Setting Picker width
    pickerWidthConstraint.constant = [[UIScreen mainScreen] bounds].size.width;
    
    // Setting swipe on view to switch with pickerview
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [nameView addGestureRecognizer:swipeLeft];
    [nameView addGestureRecognizer:swipeRight];
    
    // Hiding cover view
    coverViewTopSpaceConstraint.constant = [[UIScreen mainScreen] bounds].size.height;
    coverViewBottomSpaceConstraint.constant = - [[UIScreen mainScreen] bounds].size.height;
    
    return [super viewWillAppear:animated];
}

- (void)bookCheckoutHandler
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *formattedDate = @"";
    
    [formatter setDateFormat:@"MMMM d, yyyy HH:mm"];
    
    if ([currentBook bookLastCheckedOut] == nil)
        formattedDate = @"Never Checked Out";
    else
        formattedDate = [NSString stringWithFormat:@"%@ @ %@",[currentBook bookLastCheckedOutBy], [formatter stringFromDate:[currentBook bookLastCheckedOut]]];
    
    [bookCheckOutLabel setText:[NSString stringWithFormat:@"Last Checked Out:\n%@", formattedDate]];
    
    // DaysToGo Label
    NSString *daysToGo = @"";
    if ([currentBook bookAvailability] < 0)
        daysToGo = @"In Stock";
    else
        daysToGo = [NSString stringWithFormat:@"%d days", [currentBook bookAvailability]];
    [daysToGoLabel setText:daysToGo];
    
    // BookCheckOut Slider
    float sliderValue = 0;
    if ([currentBook bookAvailability] < 0)
        sliderValue = 0;
    if ([currentBook bookAvailability] > 25)
        [bookCheckOutSlider setMinimumTrackTintColor:[UIColor orangeColor]];
    if ([currentBook bookAvailability] > 30)
        [bookCheckOutSlider setMinimumTrackTintColor:[UIColor redColor]];
    
    [bookCheckOutSlider setValue:sliderValue];
}






#pragma mark - Gesture recognizer

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    float space = 0;
    
    if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight)
        space = 0;

    if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        if (checkoutViewTopSpaceConstraint.constant != checkoutViewTopSpaceContraintConstant)
        {
            [nameTextField resignFirstResponder];
            [UIView animateWithDuration:0.5 animations:^{
                checkoutViewTopSpaceConstraint.constant = checkoutViewTopSpaceContraintConstant;
            
                [self.view layoutIfNeeded];
            }];
        }
        space = -[[UIScreen mainScreen] bounds].size.width;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        nameViewLeadingSpaceConstraint.constant = space;
        
        [self.view layoutIfNeeded];
    }];
}







#pragma mark - Buttons pressed

- (IBAction)checkoutButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        coverViewTopSpaceConstraint.constant = 0;
        coverViewBottomSpaceConstraint.constant = 0;
        
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)doneButtonPressed:(id)sender
{
    [nameTextField resignFirstResponder];
    
    [UIView animateWithDuration:0.5 animations:^{
        checkoutViewTopSpaceConstraint.constant = checkoutViewTopSpaceContraintConstant;
            
        coverViewTopSpaceConstraint.constant = [[UIScreen mainScreen] bounds].size.height;
        coverViewBottomSpaceConstraint.constant = - [[UIScreen mainScreen] bounds].size.height;
            
        [self.view layoutIfNeeded];
    }];
    
    // If the textfield is out
    if ((nameViewLeadingSpaceConstraint.constant == 0) && (![[nameTextField text] isEqualToString:@""]))
    {
        [currentBook setBookLastCheckedOut:[NSDate date]];
        [currentBook setBookLastCheckedOutBy:[nameTextField text]];
        [currentBook setBookAvailability:0];
        
        [self bookCheckoutHandler];
        [delegate bookCheckoutWithBook:currentBook];
    }
        
}

- (IBAction)shareButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share With"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Facebook", @"Twitter", nil];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}







#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *initialText = [NSString stringWithFormat:@"%@ - %@", [currentBook bookTitle], [currentBook bookAuthor]];
    
    if (buttonIndex == 0)
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeFacebook];
        [tweetSheet setInitialText:initialText];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    
    if (buttonIndex == 1)
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:initialText];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
}





#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardDidShowNotification object:nil];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        checkoutViewTopSpaceConstraint.constant = checkoutViewTopSpaceContraintConstant;
        
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}

- (void)keyboardNotification:(NSNotification*)notification
{
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        checkoutViewTopSpaceConstraint.constant = [[UIScreen mainScreen] bounds].size.height - (checkoutView.frame.size.height + keyboardHeight);
        
        if (checkoutViewTopSpaceConstraint.constant < 64)
            checkoutViewTopSpaceConstraint.constant = 64;
        
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return true;
}

@end
