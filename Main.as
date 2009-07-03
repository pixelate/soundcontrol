/**
 * SoundControl
 * A better workflow for developers and sound designers in AS3 projects
 * Copyright (c) 2009 Andreas Zecher, http://www.pixelate.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

package
{	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.display.Sprite;
	import flash.utils.Timer;
	import de.pixelate.pelikan.sound.SoundControl;

	[SWF( backgroundColor='0x000000', frameRate='1000', width='400', height='540')]

	public class Main extends Sprite
	{	
		private var _soundControl: SoundControl;

		public function Main()
		{			
			_soundControl = new SoundControl();
			_soundControl.addEventListener(Event.INIT, onSoundControlInit);

			// When embedded in HTML, set basePath to the folder of your main SWF
			// _soundControl.basePath = "swfs/";

			// Load external XML config file
			_soundControl.loadXMLConfig("xml/soundConfig.xml");

			// Or use embedded config XML
			// _soundControl.xmlConfig = xml;
		}

		private function onSoundControlInit(event: Event):void
		{
			var timer: Timer = new Timer(10000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
			
			_soundControl.playSound("HelloWorld");
			_soundControl.fadeInSound("Loop");
		}
		
		private function onTimerComplete(event: TimerEvent):void
		{
			_soundControl.fadeOutSound("Loop");			
		}
	}
}