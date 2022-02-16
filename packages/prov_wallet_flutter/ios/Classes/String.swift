//
// String.swift
//
// Created by jljdavidson on 4/7/17
// Copyright (c) Copper Creek Software, LLC. All rights reserved.
//

import Foundation

extension String {
	static func className(_ aClass: AnyClass) -> String {
		return NSStringFromClass(aClass).components(separatedBy: ".").last!
	}

	func substring(_ from: Int) -> String {
		return self.substring(from: self.index(self.startIndex, offsetBy: from))
	}

	var length: Int {
		return self.count
	}
}
