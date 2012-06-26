/*
 Adobe AIR Native Extension for iOS (In-app mail composer)
 .................................................
 
 author: Piotr Kościerzyński, @pkoscierzynski
 http://flashsimulations.com
 http://randori.pl
 
 Copyright (c) 2012 Piotr Koscierzynski
 All rights reserved.
 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
    
   
	MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
	mailComposer.mailComposeDelegate = self;
    
    if (subject != nil)
        [mailComposer setSubject: subject]; 
    
    if (messageBody != nil)
        [mailComposer setMessageBody:messageBody isHTML:YES];
    
    if (toRecipients != nil && [toRecipients rangeOfString:@"@"].location != NSNotFound)
        [mailComposer setToRecipients:[toRecipients componentsSeparatedByString:@","]];
    
    if (ccRecipients != nil && [ccRecipients rangeOfString:@"@"].location != NSNotFound)
        [mailComposer setCcRecipients:[ccRecipients componentsSeparatedByString:@","]];
    
    if (bccRecipients != nil && [bccRecipients rangeOfString:@"@"].location != NSNotFound)
        [mailComposer setBccRecipients:[bccRecipients componentsSeparatedByString:@","]];
    
    
    
    //Add attachments (if any)
    if (attachmentsData) {      
      
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
                    [mailComposer addAttachmentData: fileData mimeType:fileMimeType fileName:fileAttachName];            
                }
        
                [fileData release];
        
            }
        }
    }
    
        
    //show mail composer
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentModalViewController:mailComposer animated:YES];
   
	[mailComposer release];

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
