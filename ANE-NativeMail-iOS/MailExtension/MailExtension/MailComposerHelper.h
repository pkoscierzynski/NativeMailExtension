//
//  MailComposerHelper.h
//  NativeMail iOS extension for Adobe AIR
//
//  Created by Piotr Kościerzyński on 11-11-28.
//  Copyright (c) 2011 Randori. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FlashRuntimeExtensions.h"

@interface MailComposerHelper : NSObject<MFMailComposeViewControllerDelegate> {
	FREContext context;
}

-(void) sendMailWithSubject:(NSString *)subject 
               toRecipients:(NSString *)toRecipients 
               ccRecipients:(NSString *)ccRecipients 
              bccRecipients:(NSString *)bccRecipients 
                messageBody:(NSString *)messageBody 
            attachmentsData:(NSString *)attachmentsData;

-(void)setContext:(FREContext)ctx;

@end
