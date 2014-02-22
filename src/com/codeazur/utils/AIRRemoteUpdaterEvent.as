/*
 * Copyright (C) 2007 Claus Wahlers
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 */

package com.codeazur.utils
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class AIRRemoteUpdaterEvent extends Event
	{
		public var file:File;
		
		public static const VERSION_CHECK:String = "versionCheck";
		public static const UPDATE:String = "update";

		public function AIRRemoteUpdaterEvent(type:String, file:File = null, bubbles:Boolean = false, cancelable:Boolean = true) {
			this.file = file;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event {
			return new AIRRemoteUpdaterEvent(type, file, bubbles, cancelable);
		}
		
		override public function toString():String {
			return "[AIRRemoteUpdaterEvent]";
		}
	}
}