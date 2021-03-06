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

@synthesize nameList;
@synthesize namePickerView;

@synthesize bookTitleLabel;
@synthesize bookAuthorLabel;
@synthesize bookPublisherLabel;
@synthesize bookCategoriesLabel;
@synthesize bookCheckOutLabel;
@synthesize daysToGoLabel;

@synthesize bookCheckOutSlider;
@synthesize checkoutButton;

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
    [self bookCheckOutHandler];
    
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
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardNotification:) name:UIKeyboardDidShowNotification object:nil];
    
    return [super viewWillAppear:animated];
}

// Updates UI components in relation to checkout
- (void)bookCheckOutHandler
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
    {
        sliderValue = 0;
        [checkoutButton setTitle:@"Checkout" forState:UIControlStateNormal];
    }
    else
    {
        if ([currentBook bookAvailability] > 25)
            [bookCheckOutSlider setMinimumTrackTintColor:[UIColor orangeColor]];
        if ([currentBook bookAvailability] > 30)
            [bookCheckOutSlider setMinimumTrackTintColor:[UIColor redColor]];
        
        [checkoutButton setTitle:@"Check In" forState:UIControlStateNormal];
    }
    
    [bookCheckOutSlider setValue:sliderValue];
}

// Function called when a book is checked in or out
- (void)bookCheckInHandler
{
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

// Handles the names when a book is added, not letting two same names in the list
- (void)checkIfBookExistsWithName:(NSString*)name
{
    // Check if the name is not already present
    int namePosition = 0;
    Boolean doesNameExist = false;
    
    while (namePosition < [nameList count])
    {
        if ([name isEqualToString:[nameList objectAtIndex:namePosition]])
        {
             doesNameExist = true;
            break;
        }
        namePosition++;
    }
    
     if (!doesNameExist)
        [nameList insertObject:name atIndex:0];
    else
    {
        [nameList insertObject:name atIndex:0];
        [nameList removeObjectAtIndex:namePosition + 1];
    }
 }







#pragma mark - Gesture recognizer

// Swipe between textField or pickerView
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
        [nameTextField resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        nameViewLeadingSpaceConstraint.constant = space;
        
        [self.view layoutIfNeeded];
    }];
}







#pragma mark - Buttons pressed

// Handles checkout button switching to Check in or checkout
- (IBAction)checkoutButtonPressed:(id)sender
{
    if ([[[checkoutButton titleLabel] text] isEqualToString:@"Checkout"])
        [UIView animateWithDuration:0.5 animations:^{
            coverViewTopSpaceConstraint.constant = 0;
            coverViewBottomSpaceConstraint.constant = 0;
        
            [self.view layoutIfNeeded];
        }];
    else
    {
        [currentBook setBookAvailability:-1];
        [self bookCheckInHandler];
        
        [checkoutButton setTitle:@"Checkout" forState:UIControlStateNormal];
    }
}

- (IBAction)doneButtonPressed:(id)sender
{
    float secondsToDelay = 0;
    if ([nameTextField isFirstResponder]) {
        secondsToDelay = 0.5;
    }
    
    [nameTextField resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secondsToDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            checkoutViewTopSpaceConstraint.constant = checkoutViewTopSpaceContraintConstant;
            
            coverViewTopSpaceConstraint.constant = [[UIScreen mainScreen] bounds].size.height;
            coverViewBottomSpaceConstraint.constant = - [[UIScreen mainScreen] bounds].size.height;
            
            [self.view layoutIfNeeded];
        }];
    });
    
    // If the textfield is visible
    if ((nameViewLeadingSpaceConstraint.constant == 0) && (![[nameTextField text] isEqualToString:@""]))
    {
        [currentBook setBookLastCheckedOut:[NSDate date]];
        [currentBook setBookLastCheckedOutBy:[nameTextField text]];
        [currentBook setBookAvailability:0];
        
        [self checkIfBookExistsWithName:[nameTextField text]];
        
        [self bookCheckOutHandler];
        [delegate bookCheckoutWithBook:currentBook andName:[nameTextField text]];
        
        // Now the book can be checked out
        [checkoutButton setTitle:@"Check In" forState:UIControlStateNormal];
        
        // Updating UI
        [nameTextField setText:@""];
        [namePickerView reloadAllComponents];
    }
    
    // If the picker view is visible
    if (nameViewLeadingSpaceConstraint.constant != 0)
    {
        NSString *name = [nameList objectAtIndex:[namePickerView selectedRowInComponent:0]];
        
        [currentBook setBookLastCheckedOut:[NSDate date]];
        [currentBook setBookLastCheckedOutBy:name];
        [currentBook setBookAvailability:0];
        
        [self checkIfBookExistsWithName:name];
        
        [self bookCheckOutHandler];
        [delegate bookCheckoutWithBook:currentBook andName:name];
        
        // Now the book can be checked out
        [checkoutButton setTitle:@"Check In" forState:UIControlStateNormal];
        
        // Updating UI
        [nameTextField setText:@""];
        [namePickerView reloadAllComponents];
    }

}

// Handles the social medias
- (IBAction)shareButtonPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share With"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Facebook", @"Twitter", nil];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}






#pragma mark - PickerView Data Source and Delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [nameList count];
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [nameList objectAtIndex:row];
}








#pragma mark - ActionSheet Delegate

// Handles Facebook and Twitter
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

// When end edditing, lower the keyboard
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^{
        checkoutViewTopSpaceConstraint.constant = checkoutViewTopSpaceContraintConstant;
        
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}

// When the keyboard rises, rise the view
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
