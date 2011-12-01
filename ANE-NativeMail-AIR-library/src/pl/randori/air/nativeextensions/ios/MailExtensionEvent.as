package pl.randori.air.nativeextensions.ios
{
	import flash.events.Event;
	
	/**
	 * @author Piotr Kościerzyński, piotr@flashsimulations.com
	 * www.flashsimulations.com
	 * www.randori.pl
	 * 
	 * */
	public class MailExtensionEvent extends Event
	{
		
		public static const MAIL_COMPOSER_EVENT : String = "MAIL_COMPOSER_EVENT";

		public static const MAIL_RESULT_CANCELED      : String = "MAIL_CANCELED";
		public static const MAIL_RESULT_SAVED 	      : String = "MAIL_SAVED";
		public static const MAIL_RESULT_SENT          : String = "MAIL_SENT";
		public static const MAIL_RESULT_FAILED        : String = "MAIL_FAILED";
		public static const MAIL_RESULT_UNKNOWN       : String = "MAIL_UNKNOWN";

		
		public static const WILL_SHOW_MAIL_COMPOSER       	  : String = "WILL_SHOW_MAIL_COMPOSER";
		public static const WILL_HIDE_MAIL_COMPOSER       	  : String = "WILL_HIDE_MAIL_COMPOSER";
		public static const MAIL_COMPOSER_NOT_AVAILABLE       : String = "MAIL_COMPOSER_NOT_AVAILABLE";
		
		
		private var _composeResult : String;
		
		public function MailExtensionEvent(type:String, resultType:String = '', bubbles:Boolean=false, cancelable:Boolean=false)
		{
			
			if (resultType != '')
				_composeResult = resultType;
			
			super(type, bubbles, cancelable);
		}

		public function get composeResult():String
		{
			return _composeResult;
		}

		public function set composeResult(value:String):void
		{
			_composeResult = value;
		}

	}
}