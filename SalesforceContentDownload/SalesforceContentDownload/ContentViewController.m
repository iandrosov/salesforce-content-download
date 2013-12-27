//
//  ContentViewController.m
//  SalesforceContentDownload
//
//  Created by Igor Androsov on 12/28/13.
//  Copyright (c) 2013 Igor. All rights reserved.
//

#import "ContentViewController.h"

@interface ContentViewController ()

@end

@implementation ContentViewController

@synthesize docController;
@synthesize contentId;
@synthesize fileType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContentId:(NSString *)documentId type:(NSString*)type
{
    self = [super initWithNibName:@"ContentViewController" bundle:nil];
    if (self) {
        // Initialize Documet ID to view
        contentId = documentId;
        fileType = [type lowercaseString];
        // Call REST request to get file data
        [self requestContentFile:documentId];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Use REST Chatter API download chatter files
// This method can download other content files as long as document is shared for this user
- (void)requestContentFile:(NSString*)docId {
    
    SFRestRequest* chatterFileRequest = [[SFRestRequest alloc] init];
    chatterFileRequest.endpoint = @"/services/data/v29.0";
    chatterFileRequest.path = [NSString stringWithFormat:@"/chatter/files/%@/content",docId];
    chatterFileRequest.method = SFRestMethodGET;
    [[SFRestAPI sharedInstance] send:chatterFileRequest delegate:self];
    
}


#pragma mark - SFRestAPIDelegate

- (void)request:(SFRestRequest *)request didLoadResponse:(id)jsonResponse {
    NSLog(@"Request path %@",request.path);
    // Before doing processing we ensure that this response came from our request
    // for file content. We get contenet data and write it to local store
    NSString *request_path = [request.path substringWithRange:NSMakeRange(0, 15)];
    if([request_path isEqualToString:@"/chatter/files/"]){
        NSData *data = jsonResponse;
        NSArray *parts = [request.path componentsSeparatedByString:@"/"];
        NSString *fileId = [parts objectAtIndex:3]; // get file ID at index 2
        NSString *contentFile = [self getFilePath:fileId type:fileType];
        NSURL* destFile = [NSURL fileURLWithPath:contentFile];
        //@"/Users/appirio/Library/Application Support/iPhone Simulator/7.0.3/Applications/25F91F63-77B3-405F-8FA2-EB76EE13DDC2/Documents/photo/rest_file.png"];
        
        if (![[NSFileManager defaultManager] createFileAtPath:[destFile path] contents:nil attributes:nil]) {
            NSLog(@"Unable to create file %@", [destFile path]);
        }else{
            // Save works for small files undermaind how it goes for MB size files REST returns full data
            NSFileHandle* destFileHandle = [NSFileHandle fileHandleForWritingAtPath:[destFile path]];
            [destFileHandle writeData:data];
            [destFileHandle closeFile];
            
            // Open Document Preview
            [self previewContent:destFile];
        }
    }

}


- (void)request:(SFRestRequest*)request didFailLoadWithError:(NSError*)error {
    NSLog(@"request:didFailLoadWithError: %@", error);
    //add your failed error handling here
}

- (void)requestDidCancelLoad:(SFRestRequest *)request {
    NSLog(@"requestDidCancelLoad: %@", request);
    //add your failed error handling here
}

- (void)requestDidTimeout:(SFRestRequest *)request {
    NSLog(@"requestDidTimeout: %@", request);
    //add your failed error handling here
}


#pragma mark - Utility helper methods

- (void)previewContent:(NSURL*)fileURL {
    
    /// Open the document in document view controller
    docController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    if (!docController) {
        NSLog(@"Selected a file with estension not supported for visualization");
        return;
    }
    docController.delegate = self;
    if(![docController presentPreviewAnimated:YES]){
        NSLog(@"ERROR in presenting preview");
    }
}

- (NSString*)getFilePath:(NSString*)fileId type:(NSString*)type{
    // Create phot file name local
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", fileId,type];
    NSLog(@"Full File Name: %@", fileName);
    NSString *documentDirPath = [self getContentDirectoryName];
    NSString *filePath = [documentDirPath stringByAppendingPathComponent:fileName];
    NSLog(@"Located Full File Path: %@", filePath);
    
    return filePath;
}

- (NSString*)getContentDirectoryName {
    return [self localDocumentFilePath:@"content"];
}

// Get local directory where to store a file, ensure directory exists or create it
- (NSString*)localDocumentFilePath:(NSString*)dir {
    // Create folder if not exist
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    NSString *dataPath = [documentDirPath stringByAppendingPathComponent:dir];
    if (![fileManager fileExistsAtPath:dataPath]){
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    // folder section
    return dataPath;
}

@end
