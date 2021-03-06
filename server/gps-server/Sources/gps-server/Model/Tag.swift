//
//  Tag.swift
//  Pawscout
//
//  Created by Gabriel Zolnierczuk on 16.02.2018.
//  Copyright © 2018 Pawscout. All rights reserved.
//

import Foundation

struct Tag: Codable {
	let id: String
	let major: Int
	let minor: Int
	var locations: [Location]?
	
	init(major: Int, minor: Int) {
		self.id = "\(major).\(minor)"
		self.major = major
		self.minor = minor
		self.locations = nil
	}
}

extension Tag: JSONable {
	var json: JSON {
		var returnValue: JSON = ["tagId": self.id]
		if let locations: [Location] = self.locations {
			returnValue["location"] = locations.json
		}
		return returnValue
	}
}

extension Tag: Equatable {
	static private func ==(lhs: Tag, rhs: Tag) -> Bool {
		return lhs.id == rhs.id
	}
}
