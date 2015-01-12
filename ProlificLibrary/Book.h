//
//  Book.h
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Book : UIViewController <NSCoding>

@property (strong, nonatomic) NSString  *bookAuthor;
@property (strong, nonatomic) NSString  *bookCategories;
@property (strong, nonatomic) NSDate    *bookLastCheckIn;
@property (strong, nonatomic) NSDate    *bookLastCheckedOut;
@property (strong, nonatomic) NSString  *bookLastCheckedOutBy;
@property (strong, nonatomic) NSString  *bookPublisher;
@property (strong, nonatomic) NSString  *bookTitle;
@property (strong, nonatomic) NSString  *bookURL;
@property (assign, nonatomic) int       bookAvailability;
@property (assign, nonatomic) int       bookID;

- (id)initWithAuthor:(NSString*) author
       andCategories:(NSString*) categories
      andLastCheckIn:(NSDate*) lastCheckIn
     andLastCheckOut:(NSDate*) lastCheckOut
   andLastCheckOutBy:(NSString*) lastCheckOutBy
        andPublisher:(NSString*) publisher
            andTitle:(NSString*) title
              andURL:(NSString*) URL
     andAvailability:(int) availability
               andID:(int) ID;

@end
