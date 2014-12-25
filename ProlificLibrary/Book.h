//
//  Book.h
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Book : UIViewController

@property (strong, nonatomic) NSString  *bookAuthor;
@property (strong, nonatomic) NSString  *bookCategories;
@property (assign, nonatomic) NSDate    *bookLastCheckIn;
@property (strong, nonatomic) NSDate    *bookLastCheckedOut;
@property (strong, nonatomic) NSString  *bookLastCheckedOutBy;
@property (strong, nonatomic) NSString  *bookPublisher;
@property (strong, nonatomic) NSString  *bookTitle;
@property (strong, nonatomic) NSString  *bookURL;

- (id)initWithAuthor:(NSString*) author
       andCategories:(NSString*) categories
     andLastCheckOut:(NSDate*) lastCheckOut
   andLastCheckOutBy:(NSString*) lastCheckOutBy
        andPublisher:(NSString*) publisher
            andTitle:(NSString*) title
              andURL:(NSString*) URL;

@end
