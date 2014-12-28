//
//  BookDetailViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "BookDetailViewController.h"

@implementation BookDetailViewController

@synthesize currentBook;

@synthesize bookTitleLabel;
@synthesize bookAuthorLabel;
@synthesize bookPublisherLabel;
@synthesize bookCategoriesLabel;
@synthesize bookCheckOutLabel;
@synthesize daysToGoLabel;

@synthesize bookCheckOutSlider;

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
    {
        publisher = @"N/A";
        NSLog(@"lol");
    }
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
    [bookCheckOutSlider setValue:sliderValue];
    
    return [super viewWillAppear:animated];
}

- (IBAction)checkoutButtonPressed:(id)sender
{
    
}

@end
