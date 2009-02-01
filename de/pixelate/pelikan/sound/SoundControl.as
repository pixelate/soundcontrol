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

package de.pixelate.pelikan.sound
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound; 
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
		
	public class SoundControl extends EventDispatcher
	{		
		private var _dictionary: Dictionary;
		private var _xmlData: XML;
		private var _xmlConfigLoader: URLLoader;
		private var _soundsToLoad: int = 0;
		private var _soundsLoaded: int = 0;
		private var _embedSounds: Boolean = false;
		
		public function SoundControl():void
		{
			_dictionary = new Dictionary();			
		}

		public function loadXMLConfig(url: String):void
		{
			_xmlConfigLoader = new URLLoader();
			_xmlConfigLoader.addEventListener(Event.COMPLETE, onXMLConfigLoaded);
			_xmlConfigLoader.load( new URLRequest(url) );			
		}

		public function setXMLConfig(xml: XML):void
		{
			_xmlData = xml;
			parseXML();
		}

		public function playSound(id: String):void
		{
			if(_dictionary[id] == null) {
				throw new Error("Sound with id \"" + id + "\" does not exist.");
			}
			
			var sound: SoundObject = SoundObject(_dictionary[id]);
			sound.play();
		}

		private function parseXML():void
		{	
			_soundsToLoad = _xmlData.sound.length();

			if(_xmlData.@embedSounds == "true")
			{
				_embedSounds = true;
			}
			else
			{
				_embedSounds = false;
			}

			for each (var sound:XML in _xmlData.sound)
			{
				registerSound(sound);				
			}
		}

		private function registerSound(soundData: XML):void
		{
			var soundObject: SoundObject = new SoundObject(soundData, _embedSounds);

			var soundId: String = soundObject.id;			
			_dictionary[soundId] = soundObject;

			soundObject.addEventListener(Event.COMPLETE, onSoundLoaded);
			soundObject.load();
		}

		private function onXMLConfigLoaded(event: Event):void
		{			
			_xmlConfigLoader.removeEventListener(Event.COMPLETE, onXMLConfigLoaded);

			_xmlData = new XML(event.target.data);
			parseXML();
		}

		private function onSoundLoaded(event: Event):void
		{
			_soundsLoaded++;

			if(_soundsLoaded == _soundsToLoad)
			{
				dispatchEvent( new Event(Event.INIT) );
			}
		}
	}
}