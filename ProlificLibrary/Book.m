//
//  Book.m
//  ProlificLibrary
//
//  Created by Julien Chene on /21/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "Book.h"

#define kBookAuthor         @"author"
#define kBookCategories     @"categories"
#define kBookLastCheckIn    @"lastCheckIn"
#define kBookLastCheckOut   @"lastCheckOut"
#define kBookLastCheckOutBy @"lastCheckOutBy"
#define kBookPublisher      @"publisher"
#define kBookTitle          @"title"
#define kBookURL            @"url"
#define kBookAvailability   @"availability"
#define kBookID             @"ID"

@implementation Book

@synthesize bookAuthor;
@synthesize bookCategories;
@synthesize bookLastCheckIn;
@synthesize bookLastCheckedOut;
@synthesize bookLastCheckedOutBy;
@synthesize bookPublisher;
@synthesize bookTitle;
@synthesize bookURL;
@synthesize bookAvailability;
@synthesize bookID;

- (id)initWithAuthor:(NSString*) author
       andCategories:(NSString*) categories
      andLastCheckIn:(NSDate*) lastCheckIn
     andLastCheckOut:(NSDate*) lastCheckOut
   andLastCheckOutBy:(NSString*) lastCheckOutBy
        andPublisher:(NSString*) publisher
            andTitle:(NSString*) title
              andURL:(NSString*) URL
     andAvailability:(int) availability
               andID:(int) ID
{
    self = [super init];
    
    if (self)
    {
        [self setBookAuthor:author];
        [self setBookCategories:categories];
        [self setBookPublisher:publisher];
        [self setBookLastCheckIn:lastCheckIn];
        [self setBookLastCheckedOut:lastCheckOut];
        [self setBookLastCheckedOutBy:lastCheckOutBy];
        [self setBookTitle:title];
        [self setBookURL:URL];
        [self setBookAvailability:availability];
        [self setBookID:ID];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSString *author = [aDecoder decodeObjectForKey:kBookAuthor];
    NSString *categories = [aDecoder decodeObjectForKey:kBookCategories];
    NSDate *lastCheckIn = [aDecoder decodeObjectForKey:kBookLastCheckIn];
    NSDate *lastCheckOut = [aDecoder decodeObjectForKey:kBookLastCheckOut];
    NSString *lastCheckOutBy = [aDecoder decodeObjectForKey:kBookLastCheckOutBy];
    NSString *publisher = [aDecoder decodeObjectForKey:kBookPublisher];
    NSString *title = [aDecoder decodeObjectForKey:kBookTitle];
    NSString *url = [aDecoder decodeObjectForKey:kBookURL];
    int availability = [aDecoder decodeIntForKey:kBookAvailability];
    int ID = [aDecoder decodeIntForKey:kBookID];
    
    return [self initWithAuthor:author
                  andCategories:categories
                 andLastCheckIn:lastCheckIn
                andLastCheckOut:lastCheckOut
              andLastCheckOutBy:lastCheckOutBy
                   andPublisher:publisher
                       andTitle:title
                         andURL:url
                andAvailability:availability
                          andID:ID];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:bookAuthor forKey:kBookAuthor];
    [aCoder encodeObject:bookCategories forKey:kBookCategories];
    [aCoder encodeObject:bookLastCheckIn forKey:kBookLastCheckIn];
    [aCoder encodeObject:bookLastCheckedOut forKey:kBookLastCheckOut];
    [aCoder encodeObject:bookLastCheckedOutBy forKey:kBookLastCheckOutBy];
    [aCoder encodeObject:bookPublisher forKey:kBookPublisher];
    [aCoder encodeObject:bookTitle forKey:kBookTitle];
    [aCoder encodeObject:bookURL forKey:kBookURL];
    [aCoder encodeInt:bookAvailability forKey:kBookAvailability];
    [aCoder encodeInt:bookID forKey:kBookID];
}


@end
