package  {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import pl.randori.air.nativeextensions.ios.MailExtension;
	import pl.randori.air.nativeextensions.ios.MailExtensionEvent;
	
	
	public class ANEMessagingExample extends Sprite {
		
		private var Messaging:MailExtension;
		private var button:Sprite;
		
		[Embed(source="assets/button.png")]
		private static const ButtonAsset:Class;
		
		[Embed(source="assets/logo.png")]
		private static const LogoAsset:Class;
		
		//retina iPhones and iPad
		private var contentScale:Number = 1.0;
		private var button_mc:Sprite;
		private var header_mc:Bitmap;
		private var logo_mc:Bitmap;

		
		public function ANEMessagingExample() {			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onAdded(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			stage.addEventListener(Event.RESIZE, onResize);
			
			Messaging = new MailExtension();
			Messaging.addEventListener(MailExtensionEvent.MAIL_COMPOSER_EVENT, onMailEvent);

			
			if (stage.stageWidth <= 320.0)
				contentScale = 0.5;
			
			this.button_mc = new Sprite();
			this.button_mc.addChild(new Bitmap(getScaledBitmap((new ButtonAsset() as Bitmap).bitmapData, contentScale)));
			addChild(this.button_mc);
			this.logo_mc = new Bitmap(getScaledBitmap((new LogoAsset() as Bitmap).bitmapData, contentScale));
			addChild(logo_mc);
			
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			button_mc.addEventListener(TouchEvent.TOUCH_TAP, onButtonTap);			
			
			onResize();
		}

		//Synchronous write
		public  function writeStringToFile(string:String, fname:String):void
		{
			var file:File = File.documentsDirectory.resolvePath(fname);
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTF(string);
			fileStream.close();
		}
		
		private function onButtonTap(e:TouchEvent):void {
			writeStringToFile('Yabba dabba doo', 'Example file.dat');
			var fileToAttach:File = File.documentsDirectory.resolvePath('Example file.dat');

			Messaging.sendMail("Hello", "<html><body><p>Hi,</p></br><p>I just want to let you know that this mail has been sent from iOS Adobe AIR app using in-app native mail composer!</br>Visit <a href=\"http://flashsimulations.com\">flashsimulations.com</a> to find out more.</p></br></br>Have a nice day.</body></html>", 
				"bob@smith.com",
				"james.logan@marvel.com",
				"a.einstein@area51.com", [fileToAttach.nativePath+"|"+"text/xml"+"|"+"AttachmentFile.txt"]);								
		}
		
		protected function onMailEvent(e:MailExtensionEvent):void {
			trace('\nReceived mail event: '+e.composeResult);	
		}
		
		private function getScaledBitmap(bitmapData:BitmapData, destScale:Number = 1.0):BitmapData {
			if (destScale == 1.0)
				return bitmapData;
			
			var m:Matrix = new Matrix();
			m.scale(destScale, destScale);
			
			var result:BitmapData = new BitmapData(destScale*bitmapData.width, destScale*bitmapData.height, true, 0x00000000);
			result.draw(bitmapData.clone(), m, null, null, null, true);
			return result;
		}
		
		
		private function onResize(e:Event = null):void
		{
			button_mc.x = (stage.stageWidth-button_mc.width) >> 1;
			button_mc.y = (stage.stageHeight-button_mc.height) >> 1;
			
			logo_mc.x = (stage.stageWidth-logo_mc.width) - 20*contentScale;
			logo_mc.y = (stage.stageHeight-logo_mc.height) - 20*contentScale;
		}
	}
	
}
