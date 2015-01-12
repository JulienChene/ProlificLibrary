//
//  AddBookViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "AddBookViewController.h"

@implementation AddBookViewController

@synthesize delegate;
@synthesize currentID;

@synthesize bookAuthorTextField;
@synthesize bookTitleTextField;
@synthesize bookPublisherTextField;
@synthesize bookCategoriesTextField;

@synthesize addBookButton;

// TODO : Add ID (URL) and AFNetworking

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isTextFieldNotEmpty = 0;
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addBookButtonPressed:(id)sender
{
    currentID++;
    Book *newBook = [[Book alloc] initWithAuthor:[bookAuthorTextField text]
                                   andCategories:[bookCategoriesTextField text]
                                  andLastCheckIn:nil
                                 andLastCheckOut:nil
                               andLastCheckOutBy:@""
                                    andPublisher:[bookPublisherTextField text]
                                        andTitle:[bookTitleTextField text]
                                          andURL:[NSString stringWithFormat:@"/books/%d", currentID]
                                 andAvailability:(-1)
                                           andID:currentID];
    
    [self.delegate addBookWithBook:newBook];
    
    // Clears all textfields
    [bookTitleTextField setText:@""];
    [bookAuthorTextField setText:@""];
    [bookPublisherTextField setText:@""];
    [bookCategoriesTextField setText:@""];
}





#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@""] && [[textField text] length] == 1)
    {
        if (![bookPublisherTextField isFirstResponder])
        {
            [addBookButton setEnabled:NO];
            isTextFieldNotEmpty -= 1;
            
            return YES;
        }
    }
 
    if (![bookPublisherTextField isFirstResponder] && [[textField text] length] == 0)
    {
        isTextFieldNotEmpty += 1;
        if (isTextFieldNotEmpty >= 3)
            [addBookButton setEnabled:YES];
    }

    return YES;
}

@end
