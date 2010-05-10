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
	import flash.events.TimerEvent;
	import flash.media.Sound; 
	import flash.media.SoundChannel; 
	import flash.media.SoundTransform; 
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.getTimer;
		
	public class SoundObject extends EventDispatcher
	{		
		private const FADE_TIMER_RATE: int = 50;
		private const DEFAULT_FADE_TIME: Number = 2.0;
		
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
		private var _fadeInDuration: Number;
		private var _fadeOutDuration: Number;
		private var _fadeTimer: Timer;
		private var _fadeType: FadeType;
		private var _isPlaying: Boolean;
		private var _lastMilliseconds: int;
		private var _currentMilliseconds: int;
				
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
			
			if ("fadeInTime" in soundData)
			{
				_fadeInDuration = soundData.fadeInTime * 1000;								
			}
			else
			{
				_fadeInDuration = DEFAULT_FADE_TIME * 1000;												
			}
			
			if ("fadeOutTime" in soundData)
			{
				_fadeOutDuration = soundData.fadeOutTime * 1000;				
			}
			else
			{
				_fadeOutDuration = DEFAULT_FADE_TIME * 1000;				
			}
			
			_embed = embed;
			_fadeType = FadeType.None;
			_isPlaying = false;
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
			if(!_isPlaying || _loops == 0)
			{
				_isPlaying = true;
				var transform: SoundTransform = new SoundTransform(_currentVolume, _currentPan);
				_soundChannel = _sound.play(_startTime, _loops, transform);				
				_soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			}
		}

		public function stop():void
		{
			if(_isPlaying)
			{
				_soundChannel.stop();				
				_isPlaying = false;
			}
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
			if(_isPlaying)
			{
				_fadeType = FadeType.Out;
				startFade();							
			}		
		}

		public function fadeOutAndStop():void
		{
			if(_isPlaying)
			{
				_fadeType = FadeType.OutAndStop;
				startFade();							
			}		
		}

		public function get id():String
		{
			return _id;
		}

		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

        public function set volume(value: Number):void
		{
			_currentVolume = value;
			if(_soundChannel)
			{
	            var transform: SoundTransform = _soundChannel.soundTransform;
	            transform.volume = value;
	            _soundChannel.soundTransform = transform;				
			}
        }

		public function get volume():Number
		{
			if(_soundChannel)
			{
				return _soundChannel.soundTransform.volume;				
			}
			else
			{
				return 0;
			}
		}

     	public function set pan(value: Number):void
		{
			_currentPan = value;
			if(_soundChannel)
			{
	            var transform: SoundTransform = _soundChannel.soundTransform;
	            transform.pan = value;
	            _soundChannel.soundTransform = transform;				
			}
        }

		public function get pan():Number
		{
			if(_soundChannel)
			{
				return _soundChannel.soundTransform.pan;				
			}
			else
			{
				return 0;
			}
		}

		private function startFade():void
		{
			if(!_fadeTimer)
			{
				_fadeTimer = new Timer(FADE_TIMER_RATE);
				_fadeTimer.addEventListener(TimerEvent.TIMER, onFadeTimer);
				_fadeTimer.start();				
				_lastMilliseconds = getTimer();
			}
		}

		private function stopFade():void
		{
			_fadeTimer.stop();
			_fadeTimer.removeEventListener(TimerEvent.TIMER, onFadeTimer);
			_fadeTimer = null;
			_fadeType = FadeType.None;
		}

		private function calculateFadeSpeed(timeDelta: Number, fadeDuration: Number):Number
		{
			return timeDelta * (1.0 / fadeDuration);
		}
		
		private function onSoundLoaded(event: Event):void
		{
			_sound.removeEventListener(Event.COMPLETE, onSoundLoaded);
			dispatchEvent( new Event(Event.COMPLETE) );
		}

		private function onSoundComplete(event: Event):void
		{
			_soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_isPlaying = false;
		}
		
		private function onFadeTimer(event: TimerEvent):void
		{
			_currentMilliseconds = getTimer() - _lastMilliseconds;
			_lastMilliseconds = getTimer();			

			if(_fadeType == FadeType.In)
			{
				_currentVolume += calculateFadeSpeed(_currentMilliseconds, _fadeInDuration);

				if(_currentVolume >= _defaultVolume)
				{
					_currentVolume = _defaultVolume;
					stopFade();
				}				
			}
			else if(_fadeType == FadeType.Out || _fadeType == FadeType.OutAndStop)
			{
				_currentVolume -= calculateFadeSpeed(_currentMilliseconds, _fadeOutDuration);

				if(_currentVolume <= 0)
				{
					_currentVolume = 0;
					stopFade();

					if(_fadeType == FadeType.OutAndStop)
					{
						stop();						
					}
				}				
			}
			
			volume = _currentVolume;			
		}
	}
}