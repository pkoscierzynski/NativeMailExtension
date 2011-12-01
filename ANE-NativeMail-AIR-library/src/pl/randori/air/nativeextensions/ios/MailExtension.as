package pl.randori.air.nativeextensions.ios
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;

	
	/**
	 * An iOS native extension for Adobe AIR 3.1 for sending mail.
	 * Implements MFMailComposeViewController in iOS
	 * 
	 * @author Piotr Kościerzyński, piotr@flashsimulations.com
	 * www.flashsimulations.com
	 * www.randori.pl
	 * 
	 * */
	public class MailExtension extends EventDispatcher
	{
		
		protected var extensionContext:ExtensionContext;
		
		private static const EXTENSION_ID : String = "pl.randori.air.nativeextensions.ios.MailExtension";
		
		
		public function MailExtension(target:IEventDispatcher=null)
		{
			super(target);
			extensionContext = ExtensionContext.createExtensionContext( EXTENSION_ID, null);
		}

		
		/**
		 * @param subject Mail subject
		 * @param messageBody Mail body (can include HTML)
		 * @param toRecipients To: recipients in format: "mail@example.com,mail2@example.com"
		 * @param ccRecipients Cc: recipients in format: "mail@example.com,mail2@example.com"
		 * @param bccRecipients Bcc: recipients in format: "mail@example.com,mail2@example.com"
		 * @param attachmentsData Attachments in format: ['filename|bundle|mimetype|name of file to display in attachment']
		 * example: ["Default.png|bundle|image/png|Application splash screen.png","Example file.dat|documents|text/xml|A file saved in Adobe AIR iOS app.txt"]
		 */
		public function sendMail(subject:String, messageBody:String, toRecipients:String,
								ccRecipients:String = '', bccRecipients:String = '', attachmentsData:Array = null):void {
			
			extensionContext.addEventListener( StatusEvent.STATUS, onStatusEvent);
			extensionContext.call( "sendMailWithOptions", subject, messageBody, toRecipients,
									ccRecipients, bccRecipients, attachmentsData);
		}
		
		/**
		 * @private
		 * Handle mail compose result. 
		 * When the native mail composer finished an result event will be dispatched.
		 * Event will contain the result information.
		 *
		 */		
		private function onStatusEvent( event : StatusEvent ) : void
		{
			if( event.code == MailExtensionEvent.MAIL_COMPOSER_EVENT)
			{
				dispatchEvent( new MailExtensionEvent(event.code, event.level ));
			}
		}
		
		/**
		 * Can the in-app mail composer be invoked?
		 */		
		public function isMailComposerAvailable() : Boolean
		{
			return extensionContext.call( "isMailComposerAvailable") as Boolean;			
		}
		
		
		/**
		 * Clean up
		 */	
		public function dispose():void {
			extensionContext.removeEventListener( StatusEvent.STATUS, onStatusEvent );
			extensionContext.dispose();
		}
		
		
	}
}