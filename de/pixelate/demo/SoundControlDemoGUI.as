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
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import de.pixelate.soundcontrol.SoundControl;

	public class SoundControlDemoGUI extends Sprite
	{
		private var _infoTextField: TextField;
		private var _equalizer: SoundControlDemoEqualizer;
		
		public function SoundControlDemoGUI()
		{
			var textFormat: TextFormat = new TextFormat();
			textFormat.font = "Verdana";
			textFormat.color = 0xFFFFFF;
			textFormat.size = 9;
			textFormat.leading = 1;
			textFormat.align = TextFormatAlign.CENTER;
			
			_infoTextField = new TextField();
			_infoTextField.defaultTextFormat = textFormat;
			_infoTextField.text = "SoundControl "
								+ SoundControl.VERSION + "\n"
								+ "by Andreas Zecher" + "\n"
								+ "www.pixelate.de";
			_infoTextField.width = 400;
			_infoTextField.y = 480;
			addChild(_infoTextField);
			
			_equalizer = new SoundControlDemoEqualizer();
			addChild(_equalizer);
		}
	}
}