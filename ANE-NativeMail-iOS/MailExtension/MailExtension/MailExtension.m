//
//  MailExtension.m
//  MailExtension
//
//  Created by Piotr Kościerzyński on 11-11-29.
//  Copyright (c) 2011 Randori. All rights reserved.
//

#import "MailExtension.h"


@implementation MailExtension

static NSString *attachmentsSeparator = @"----";
static NSString *event_name = @"MAIL_COMPOSER_EVENT";

FREContext g_ctx;
MailComposerHelper *mailComposerHelper;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

int canSendMail(void) {

    BOOL result = NO;
    
    //On pre iOS 3.0 devices MFMailComposeViewController does not exists
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail]) {
            result = YES;
		}
		else {
            result = NO;
        }
	}
    //this will never happen since Adobe AIR requires at least iOS 4.0
	else {
        result = NO;
	}
    return (int)result;
}

//Can we invoke in-app mail ?
FREObject PKIsMailComposerAvailable(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    BOOL ret = canSendMail();
	FREObject retVal;
    
    FRENewObjectFromBool(ret, &retVal);
	return retVal;    
}

//Send mail
FREObject PKSendMailWithOptions(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[] )
{
    BOOL ret = canSendMail();
    
    if (!ret) {
        FREDispatchStatusEventAsync(ctx, (uint8_t*)[event_name UTF8String], (uint8_t*)[@"MAIL_COMPOSER_NOT_AVAILABLE" UTF8String]);
        return NULL;
    }
    
    //Subject
    uint32_t subjectLength;
    const uint8_t *subjectCString;
    //To Recipients
    uint32_t toRecipientsLength;
    const uint8_t *toRecipientsCString;
    //CC Recipients
    uint32_t ccRecipientsLength;
    const uint8_t *ccRecipientsCString;
    //Bcc Recipients
    uint32_t bccRecipientsLength;
    const uint8_t *bccRecipientsCString;
    //Message Body
    uint32_t messageBodyLength;
    const uint8_t *messageBodyCString;
    
    NSMutableString *attachmentsString;

    NSString *subjectString;
    NSString *toRecipientsString;
    NSString *ccRecipientsString;
    NSString *bccRecipientsString;
    NSString *messageBodyString;
    
    //Create NSStrings from CStrings
    //Turn our actionscrpt code into native code.
    if (FRE_OK == FREGetObjectAsUTF8(argv[0], &subjectLength, &subjectCString)) {
        subjectString = [NSString stringWithUTF8String:(char*)subjectCString];
    }
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[1], &messageBodyLength, &messageBodyCString)) {
        messageBodyString = [NSString stringWithUTF8String:(char*)messageBodyCString];
    }
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[2], &toRecipientsLength, &toRecipientsCString)) {
        toRecipientsString = [NSString stringWithUTF8String:(char*)toRecipientsCString];
    }
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[3], &ccRecipientsLength, &ccRecipientsCString)) {
        ccRecipientsString = [NSString stringWithUTF8String:(char*)ccRecipientsCString];
    }
    
    if (FRE_OK == FREGetObjectAsUTF8(argv[4], &bccRecipientsLength, &bccRecipientsCString)) {
        bccRecipientsString = [NSString stringWithUTF8String:(char*)bccRecipientsCString];
    }
    
    //argv[5] is a an array containing strings
    //["Default.png|bundle|image/png|Application splash screen.png","Example file.dat|documents|text/xml|A file saved in Adobe AIR iOS app.txt"]
    uint32_t attachmentsArrayLength;
    
    BOOL validAttachmentsData = YES;
    if (FRE_OK != FREGetArrayLength(argv[5], &attachmentsArrayLength)) {
        //No valid array of attachments provided.
        validAttachmentsData = NO;
    }
    
    //parse attachments array
    if (validAttachmentsData) {
        attachmentsString = [[NSMutableString alloc ] init];

        uint32_t attachmentEntryLength;
        const uint8_t *attachmentEntryCString;
    
        //convert attachments array to string
        for (int i = 0; i < attachmentsArrayLength; i++) {
            FREObject arrayElement;
            FREGetArrayElementAt(argv[5], i, &arrayElement);
            FREGetObjectAsUTF8(arrayElement, &attachmentEntryLength, &attachmentEntryCString);
        
            [attachmentsString appendString:[NSString stringWithUTF8String:(char*)attachmentEntryCString]];
        
            if (i<attachmentsArrayLength-1)
                [attachmentsString appendString:attachmentsSeparator];
        }
    }//end attachments parsing
    
    
    if (mailComposerHelper) {
	}
    else {
        mailComposerHelper = [[MailComposerHelper alloc] init];
    }
    
    [mailComposerHelper setContext:ctx];
    [mailComposerHelper sendMailWithSubject:subjectString 
                               toRecipients:toRecipientsString 
                               ccRecipients:ccRecipientsString
                              bccRecipients:bccRecipientsString 
                                messageBody:messageBodyString 
                            attachmentsData:attachmentsString];
    
    
    [attachmentsString release];
    
    return NULL;    
}


//------------------------------------
//
// Required Methods.
//
//------------------------------------

// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    //we expose two methods to ActionScript
	*numFunctionsToTest = 2;
    
	FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * 2);
	func[0].name = (const uint8_t*) "sendMailWithOptions";
	func[0].functionData = NULL;
    func[0].function = &PKSendMailWithOptions;
    
    func[1].name = (const uint8_t*) "isMailComposerAvailable";
	func[1].functionData = NULL;
    func[1].function = &PKIsMailComposerAvailable;
    
	*functionsToSet = func;
	
	g_ctx = ctx;
}

// ContextFinalizer()
//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// ContextFinalizer().

void ContextFinalizer(FREContext ctx) {
    
    NSLog(@"Entering ContextFinalizer()");
    
	[mailComposerHelper setContext:NULL];
	[mailComposerHelper release];
	mailComposerHelper = nil;

    NSLog(@"Exiting ContextFinalizer()");
    
	return;
}

// ExtInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.
void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, 
                    FREContextFinalizer* ctxFinalizerToSet) {
    
    NSLog(@"Entering ExtInitializer()");
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;
    
    NSLog(@"Exiting ExtInitializer()");
}

// ExtFinalizer()
//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.
void ExtFinalizer(void* extData) {
    
    NSLog(@"Entering ExtFinalizer()");

    NSLog(@"Exiting ExtFinalizer()");
    return;
}

@end
