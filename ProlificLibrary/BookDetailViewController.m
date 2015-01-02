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

@implementation BookDetailViewController

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

@synthesize nameTextFieldWidthConstraint;
@synthesize nameTextFieldLeadingSpaceConstraint;
@synthesize pickerWidthConstraint;

@synthesize nameViewWidthConstraint;
@synthesize nameViewLeadingSpaceConstraint;

- (void)viewdidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [bookTitleLabel setText:[currentBook bookTitle]];
    
    [bookAuthorLabel setText:[currentBook bookAuthor]];
    
    // Book Publisher Label
    // Handling the case there is no publisher
    NSString *publisher = [currentBook bookPublisher];
    if ([publisher isEqualToString:@""])
        publisher = @"N/A";
        
    [bookPublisherLabel setText:[NSString stringWithFormat:@"Publisher: %@", publisher]];
    
    [bookCategoriesLabel setText:[NSString stringWithFormat:@"Tags: %@", [currentBook bookCategories]]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy HH:mm"];
    
    // Book Check Out Label
    // Handling the case where the book was never checked out before
    NSString *formattedDate = @"";
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
    
    nameViewLeadingSpaceConstraint.constant = -[[UIScreen mainScreen] bounds].size.width;
    
    return [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

}





#pragma mark - Gesture recognizer

- (void)swipe:(UISwipeGestureRecognizer*)gestureRecognizer
{
    float space = 0;
    
    if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"right");
        space = 0;
    }
    if ([gestureRecognizer direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"left");
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







#pragma mark - ActionSheet

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

@end
