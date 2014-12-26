//
//  AddBookViewController.m
//  ProlificLibrary
//
//  Created by Julien Chene on /26/1214.
//  Copyright (c) 2014 JulienChene. All rights reserved.
//

#import "AddBookViewController.h"

@implementation AddBookViewController

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return true;
}

@end
