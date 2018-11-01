//
//  extensions.swift
//  gps-server
//
//  Created by Gabriel on 06.05.2018.
//

import Foundation

typealias JSON = [String: Any]

protocol JSONable {
	var json: JSON { get }
}

extension Array where Element: JSONable {
	var json: [JSON] {
		var elements: [JSON] = []
		for element in self {
			elements.append(element.json)
		}
		return elements
	}
}

extension Date {
	var timestamp: Int64 {
		return Int64(self.timeIntervalSince1970 * 1000)
	}
}
