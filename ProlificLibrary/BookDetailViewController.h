//
//  BookDetailViewController.h
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface BookDetailViewController : UIViewController

@property (strong, nonatomic) Book  *currentBook;

@property (strong, nonatomic) IBOutlet UILabel  *bookTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel  *bookAuthorLabel;
@property (strong, nonatomic) IBOutlet UILabel  *bookPublisherLabel;
@property (strong, nonatomic) IBOutlet UILabel  *bookCategoriesLabel;
@property (strong, nonatomic) IBOutlet UILabel  *bookCheckOutLabel;
@property (strong, nonatomic) IBOutlet UILabel  *daysToGoLabel;

@property (strong, nonatomic) IBOutlet UISlider *bookCheckOutSlider;

@end
