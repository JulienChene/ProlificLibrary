//
//  Book.m
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "Book.h"

@implementation Book

@synthesize bookAuthor;
@synthesize bookCategories;
@synthesize bookLastCheckIn;
@synthesize bookLastCheckedOut;
@synthesize bookLastCheckedOutBy;
@synthesize bookPublisher;
@synthesize bookTitle;
@synthesize bookURL;

- (id)initWithAuthor:(NSString*) author
       andCategories:(NSString*) categories
     andLastCheckOut:(NSDate*) lastCheckOut
   andLastCheckOutBy:(NSString*) lastCheckOutBy
        andPublisher:(NSString*) publisher
            andTitle:(NSString*) title
              andURL:(NSString*) URL
{
    self = [super init];
    
    if (self)
    {
        [self setBookAuthor:author];
        [self setBookCategories:categories];
        [self setBookLastCheckIn:nil];
        [self setBookLastCheckedOut:lastCheckOut];
        [self setBookLastCheckedOutBy:lastCheckOutBy];
        [self setBookPublisher:publisher];
        [self setBookTitle:title];
        [self setBookURL:URL];
    }
    
    return self;
}

@end
