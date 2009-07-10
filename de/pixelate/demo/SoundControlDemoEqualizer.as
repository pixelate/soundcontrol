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

package de.pixelate.demo
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
		
	public class SoundControlDemoEqualizer extends Sprite
	{
		private const COLORS: Array = new Array(0x00FFFF, 0xFF0000);
		
		private var _bytes: ByteArray;
		private var _rect: Rectangle;
		
		public function SoundControlDemoEqualizer()
		{
			_bytes = new ByteArray();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function onEnterFrame(event: Event):void
		{
			SoundMixer.computeSpectrum(_bytes, false, 0);
						
			graphics.clear();
		
			for(var j:uint = 0; j < 2; j++)
			{
				for(var i:uint = 0; i < 32; i++)
				{
					var value: Number = _bytes.readFloat()*300;
					
					var xPos: Number = i/32 * 400;
					var yPos: Number = value + 540 / 2;
					var w: Number = 10;
					var h: Number = value;
					
					graphics.beginFill(COLORS[j], 0.5);
					graphics.drawRect(xPos, yPos, w, h);
					graphics.endFill();
				}							
			}
		}
	}
}
