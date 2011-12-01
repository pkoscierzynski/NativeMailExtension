//
//  MailComposerHelper.m
//  NativeMail iOS extension for Adobe AIR
//
//  Created by Piotr Kościerzyński on 11-11-28.
//  Copyright (c) 2011 Randori. All rights reserved.
//

#import "MailComposerHelper.h"

@implementation MailComposerHelper

static NSString *attachmentPropertySeparator = @"|";
static NSString *attachmentsSeparator = @"----";
//Event name
static  NSString *event_name = @"MAIL_COMPOSER_EVENT";


-(void) sendMailWithSubject:(NSString *)subject 
               toRecipients:(NSString *)toRecipients 
               ccRecipients:(NSString *)ccRecipients 
              bccRecipients:(NSString *)bccRecipients 
                messageBody:(NSString *)messageBody 
            attachmentsData:(NSString *)attachmentsData
{
    
    FREDispatchStatusEventAsync(context, (uint8_t*)[event_name UTF8String], (uint8_t*)[@"WILL_SHOW_MAIL_COMPOSER" UTF8String]);
    

    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
    
	[picker setSubject: subject];    
	[picker setMessageBody:messageBody isHTML:YES];
    
    if ([toRecipients rangeOfString:@"@"].location != NSNotFound)
        [picker setToRecipients:[toRecipients componentsSeparatedByString:@","]];
    
    if ([ccRecipients rangeOfString:@"@"].location != NSNotFound)
        [picker setCcRecipients:[ccRecipients componentsSeparatedByString:@","]];
    
    if ([bccRecipients rangeOfString:@"@"].location != NSNotFound)
        [picker setBccRecipients:[bccRecipients componentsSeparatedByString:@","]];
    
    
    //Add attachments (if any)
    if (!attachmentsData) {
        //No attachments found
    }
    else {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath;
        
        NSArray *attachmentProperties;
        NSString *fileName;
        NSString *fileExtension;
        NSString *fileSearchSource;
        NSString *fileMimeType;
        NSString *fileAttachName;
        
        NSArray *attachments = [attachmentsData componentsSeparatedByString:attachmentsSeparator];

        for (NSString *attachmentEntry in attachments) {
        
            attachmentProperties = [attachmentEntry componentsSeparatedByString:attachmentPropertySeparator];
            fileName = [[[attachmentProperties objectAtIndex:0] componentsSeparatedByString:@"."] objectAtIndex:0];
            fileExtension = [[[attachmentProperties objectAtIndex:0] componentsSeparatedByString:@"."] objectAtIndex:1];
            fileSearchSource = [(NSString *)[attachmentProperties objectAtIndex:1] lowercaseString];//bundle or documents
            fileMimeType = [attachmentProperties objectAtIndex:2];//mime type of file
            fileAttachName = [attachmentProperties objectAtIndex:3];//how to name the file
            
            //search for file in app bundle
            if ([fileSearchSource isEqualToString:@"bundle"]) {
                filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileExtension];                
            }
            else
            //search for file in Documents
            if ([fileSearchSource isEqualToString:@"documents"]) {
                filePath = [documentsDirectory stringByAppendingPathComponent:(NSString *)[attachmentProperties objectAtIndex:0]];            
            }
            else {
                //ERROR - ignoring
                continue;
            }
        
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
                NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        
                if (fileData) {
                    [picker addAttachmentData: fileData mimeType:fileMimeType fileName:fileAttachName];            
                }
        
                [fileData release];
        
            }
        }
    }
    
    
    //show mail composer
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:picker animated:YES];

	[picker release];
}

// Dismisses the email composition interface when users tap Cancel or Send.
-(void) mailComposeController: (MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error
{	
    NSString *event_info = @"";
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
            event_info = @"MAIL_CANCELED";
			break;
		case MFMailComposeResultSaved:
            event_info = @"MAIL_SAVED";
			break;
		case MFMailComposeResultSent:
            event_info = @"MAIL_SENT";
			break;
		case MFMailComposeResultFailed:
            event_info = @"MAIL_FAILED";
			break;
		default:
            event_info = @"MAIL_UNKNOWN";
            break;
	}
    
    FREDispatchStatusEventAsync(context, (uint8_t*)[event_name UTF8String], (uint8_t*)[event_info UTF8String]);
    FREDispatchStatusEventAsync(context, (uint8_t*)[event_name UTF8String], (uint8_t*)[@"WILL_HIDE_MAIL_COMPOSER" UTF8String]);
	
    context = nil;

    //hide mail composer
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissModalViewControllerAnimated:YES];
}

-(void)setContext:(FREContext)ctx {
    context = ctx;
}


@end
