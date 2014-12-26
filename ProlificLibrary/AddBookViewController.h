//
//  AddBookViewController.h
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@protocol AddBookViewControllerDelegate <NSObject>

- (void)addBookWithBook:(Book*)book;

@end

@interface AddBookViewController : UIViewController <UITextFieldDelegate>
{
    int isTextFieldNotEmpty;
}

@property (assign, nonatomic) id<AddBookViewControllerDelegate> delegate;
@property (assign, nonatomic) int                               currentID;

@property (strong, nonatomic) IBOutlet UITextField      *bookAuthorTextField;
@property (strong, nonatomic) IBOutlet UITextField      *bookTitleTextField;
@property (strong, nonatomic) IBOutlet UITextField      *bookPublisherTextField;
@property (strong, nonatomic) IBOutlet UITextField      *bookCategoriesTextField;

@property (strong, nonatomic) IBOutlet UIButton         *addBookButton;

@end
