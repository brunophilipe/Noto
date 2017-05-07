//
//  FileWatcher.swift
//  Noto
//
//  Created by Bruno Philipe on 26/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//  
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

class FileWatcher
{
	init?(url: NSURL)
	{
		let fileDescriptor = open(url.fileSystemRepresentation, O_EVTONLY)

		if fileDescriptor < 0
		{
			return nil
		}

		// Create a new kernel queue
		let kernelQueue = kqueue()

		if kernelQueue < 0
		{
			close(fileDescriptor)
			return nil
		}

		// Setup kernel event to watch
		var eventToWatch = kevent()
		eventToWatch.ident  = UInt(fileDescriptor)
		eventToWatch.filter = Int16(EVFILT_VNODE)
		eventToWatch.flags  = UInt16(EV_ADD-|-EV_CLEAR)
		eventToWatch.fflags = UInt32(NOTE_WRITE)
		eventToWatch.data   = 0
		eventToWatch.udata  = nil

	}
}

infix operator -|-

func -|-(lho: Int32, rho: Int32) -> Int32
{
	var finalVal = Int32(0)

	finalVal |= lho
	finalVal |= rho

	return finalVal
}
