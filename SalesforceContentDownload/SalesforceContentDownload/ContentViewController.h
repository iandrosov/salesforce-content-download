//
//  ContentViewController.h
//  SalesforceContentDownload
//
//  Created by Igor Androsov on 12/28/13.
//  Copyright (c) 2013 Igor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SFRestAPI.h"
#import "SFApplication.h"

@interface ContentViewController : UIViewController <UIDocumentInteractionControllerDelegate, SFRestDelegate>
{
    
    UIDocumentInteractionController* docController;
    NSString *contentId;
    NSString *fileType;
}

@property(nonatomic,strong)NSString *contentId;
@property(nonatomic,strong)NSString *fileType;
@property(nonatomic,retain)UIDocumentInteractionController *docController;

- (id)initWithContentId:(NSString *)documentId type:(NSString*)type;

@end
