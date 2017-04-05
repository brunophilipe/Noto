//
//  FileWatcher.swift
//  Noto
//
//  Created by Bruno Philipe on 26/2/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
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
