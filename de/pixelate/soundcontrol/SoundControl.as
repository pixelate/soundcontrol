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

package de.pixelate.soundcontrol
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound; 
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
		
	public class SoundControl extends EventDispatcher
	{		
		public static const VERSION: String = "1.0.5";
		
		private var _dictionary: Dictionary;
		private var _xmlConfig: XML;
		private var _xmlConfigLoader: URLLoader;
		private var _soundsToLoad: int = 0;
		private var _soundsLoaded: int = 0;
		private var _embedSounds: Boolean = false;
		private var _basePath: String = "";
		
		public function SoundControl():void
		{
			_dictionary = new Dictionary();			
		}

		public function set basePath(path: String):void
		{
			_basePath = path;
		}

		public function get basePath():String
		{
			return _basePath;
		}

		public function set xmlConfig(xml: XML):void
		{
			_xmlConfig = xml;
			parseXML();
		}

		public function get xmlConfig():XML
		{
			return _xmlConfig;
		}

		public function loadXMLConfig(url: String):void
		{
			_xmlConfigLoader = new URLLoader();
			_xmlConfigLoader.addEventListener(Event.COMPLETE, onXMLConfigLoaded);
			_xmlConfigLoader.load( new URLRequest(_basePath + url) );			
		}

		public function playSound(id: String):void
		{
			var sound: SoundObject = getSound(id);
			if(sound)
			{
				sound.play();				
			}
		}

		public function stopSound(id: String):void
		{
			var sound: SoundObject = getSound(id);
			if(sound)
			{
				sound.stop();				
			}
		}

		public function fadeInSound(id: String):void
		{
			var sound: SoundObject = getSound(id);
			if(sound)
			{
				sound.fadeIn();				
			}
		}

		public function fadeOutSound(id: String):void
		{
			var sound: SoundObject = getSound(id);
			if(sound)
			{
				sound.fadeOut();				
			}
		}
		
		public function fadeOutAndStopSound(id: String):void
		{
			var sound: SoundObject = getSound(id);
			if(sound)
			{
				sound.fadeOutAndStop();				
			}
		}
		
		public function getSound(id: String):SoundObject
		{
			if(_dictionary[id] == null) {
				throw new Error("Sound with id \"" + id + "\" does not exist.");
			}
			
			var sound: SoundObject = SoundObject(_dictionary[id]);
			return sound;
		}
		
		public function registerEventListeners(target:EventDispatcher):void
		{
			target.addEventListener(SoundEvent.PLAY_SOUND, onSoundEvent);
			target.addEventListener(SoundEvent.STOP_SOUND, onSoundEvent);
			target.addEventListener(SoundEvent.FADEIN_SOUND, onSoundEvent);
			target.addEventListener(SoundEvent.FADEOUT_SOUND, onSoundEvent);			
			target.addEventListener(SoundEvent.FADEOUT_AND_STOP_SOUND, onSoundEvent);			
		}
		
		private function parseXML():void
		{	
			_soundsToLoad = _xmlConfig.sound.length();

			if(_xmlConfig.@embedSounds == "true")
			{
				_embedSounds = true;
			}
			else
			{
				_embedSounds = false;
			}

			for each (var sound:XML in _xmlConfig.sound)
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
			soundObject.load(_basePath);
		}
		
		private function onXMLConfigLoaded(event: Event):void
		{			
			_xmlConfigLoader.removeEventListener(Event.COMPLETE, onXMLConfigLoaded);

			_xmlConfig = new XML(event.target.data);
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
		
		private function onSoundEvent(event: SoundEvent):void
		{
			switch(event.type)
			{
				case SoundEvent.PLAY_SOUND:
					playSound(event.soundId);
					break;
				case SoundEvent.STOP_SOUND:
					stopSound(event.soundId);
					break;
				case SoundEvent.FADEIN_SOUND:
					fadeInSound(event.soundId);
					break;
				case SoundEvent.FADEOUT_SOUND:
					fadeOutSound(event.soundId);
					break;
				case SoundEvent.FADEOUT_AND_STOP_SOUND:
					fadeOutAndStopSound(event.soundId);
					break;
			}
		}		
	}
}