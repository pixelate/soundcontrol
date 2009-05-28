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
	import flash.events.TimerEvent;
	import flash.media.Sound; 
	import flash.media.SoundChannel; 
	import flash.media.SoundTransform; 
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import nl.demonsters.debugger.MonsterDebugger;
		
	public class SoundObject extends EventDispatcher
	{		
		private const FADE_TIMER_RATE: int = 50;
		private const DEFAULT_FADE_SPEED: Number = 0.01;
		
		private var _sound: Sound;
		private var _soundChannel: SoundChannel;
		private var _id: String;
		private var _file: String;
		private var _defaultVolume: Number;
		private var _defaultPan: Number;
		private var _currentVolume: Number;
		private var _currentPan: Number;
		private var _startTime: int;
		private var _loops: int;
		private var _embed: Boolean;
		private var _fadeInSpeed: Number;
		private var _fadeOutSpeed: Number;
		private var _fadeTimer: Timer;
		private var _fadeType: FadeType;
				
		public function SoundObject(soundData: XML, embed: Boolean):void
		{
			_id = soundData.id;
			_file = soundData.file;
			_defaultVolume = soundData.volume;
			_defaultPan = soundData.pan;
			_currentVolume = soundData.volume;
			_currentPan = soundData.pan;
			_startTime = soundData.startTime;
			_loops = soundData.loops;
			_fadeInSpeed = soundData.fadeInSpeed || DEFAULT_FADE_SPEED;				
			_fadeOutSpeed = soundData.fadeOutSpeed || DEFAULT_FADE_SPEED;				
			_embed = embed;
			_fadeType = FadeType.None;
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
			var transform: SoundTransform = new SoundTransform(_currentVolume, _currentPan);
			_soundChannel = _sound.play(_startTime, _loops, transform);
		}

		public function stop():void
		{
			_soundChannel.stop();
		}
		
		public function fadeIn():void
		{
			_currentVolume = 0;
			_fadeType = FadeType.In;
			startFade();							
			play();
		}

		public function fadeOut():void
		{
			_fadeType = FadeType.Out;
			startFade();							
		}

		public function get id():String
		{
			return _id;
		}

        private function setVolume(volume: Number):void
		{
            var transform: SoundTransform = _soundChannel.soundTransform;
            transform.volume = volume;
            _soundChannel.soundTransform = transform;
        }

     	private function setPan(pan: Number):void
		{
            var transform: SoundTransform = _soundChannel.soundTransform;
            transform.pan = pan;
            _soundChannel.soundTransform = transform;
        }

		private function startFade():void
		{
			if(!_fadeTimer)
			{
				_fadeTimer = new Timer(FADE_TIMER_RATE);
				_fadeTimer.addEventListener(TimerEvent.TIMER, onFadeTimer);
				_fadeTimer.start();				
			}
		}

		private function stopFade():void
		{
			_fadeTimer.stop();
			_fadeTimer.removeEventListener(TimerEvent.TIMER, onFadeTimer);
			_fadeTimer = null;
			_fadeType = FadeType.None;
		}

		private function onSoundLoaded(event: Event):void
		{
			_sound.removeEventListener(Event.COMPLETE, onSoundLoaded);
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		private function onFadeTimer(event: TimerEvent):void
		{
			if(_fadeType == FadeType.In)
			{
				_currentVolume += _fadeInSpeed;

				if(_currentVolume >= _defaultVolume)
				{
					_currentVolume = _defaultVolume;
					stopFade();
				}				
			}
			else if(_fadeType == FadeType.Out)
			{
				_currentVolume -= _fadeOutSpeed;

				if(_currentVolume <= 0)
				{
					_currentVolume = 0;
					stopFade();
					_soundChannel.stop();
				}				
			}
			
			MonsterDebugger.trace(this, _currentVolume);

			setVolume(_currentVolume);
		}
	}
}