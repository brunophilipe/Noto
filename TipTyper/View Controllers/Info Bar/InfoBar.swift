//
//  InfoBar.swift
//  TipTyper
//
//  Created by Bruno Philipe on 5/3/17.
//  Copyright © 2017 Bruno Philipe. All rights reserved.
//

import Foundation

protocol InfoBar: class
{
	func setLinesCount(_: String)
	func setWordsCount(_: String)
	func setCharactersCount(_: String)
	func setEncoding(_: String)
}
