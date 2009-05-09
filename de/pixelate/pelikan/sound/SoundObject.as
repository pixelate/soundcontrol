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
	import flash.media.SoundChannel; 
	import flash.media.SoundTransform; 
	import flash.net.URLRequest;
		
	public class SoundObject extends EventDispatcher
	{		
		private var _sound: Sound;
		private var _soundChannel: SoundChannel;
		private var _soundTransform: SoundTransform;
		private var _id: String;
		private var _file: String;
		private var _volume: Number;
		private var _pan: Number;
		private var _startTime: int;
		private var _loops: int;
		private var _embed: Boolean;
				
		public function SoundObject(soundData: XML, embed: Boolean):void
		{
			_id = soundData.id;
			_file = soundData.file;
			_volume = soundData.volume;
			_pan = soundData.pan;
			_startTime = soundData.startTime;
			_loops = soundData.loops;				
			_embed = embed;

			_soundTransform = new SoundTransform(_volume, _pan);
		}

		public function load(basePath: String):void
		{
			if(_embed)
			{				
				_sound = new EmbeddedSounds[_id]() as Sound; 				
				dispatchEvent( new Event(Event.COMPLETE) );
			}
			else
			{
				var request: URLRequest = new URLRequest(basePath + _file);
				_sound = new Sound(request);
				_sound.addEventListener(Event.COMPLETE, onSoundLoaded);								
			}			
		}

		public function play():void
		{
			_soundChannel = _sound.play(_startTime, _loops, _soundTransform);
		}

		public function stop():void
		{
			_soundChannel.stop();
		}

		public function get id():String
		{
			return _id;
		}
		
		private function onSoundLoaded(event: Event):void
		{
			_sound.removeEventListener(Event.COMPLETE, onSoundLoaded);
			dispatchEvent( new Event(Event.COMPLETE) );
		}
	}
}