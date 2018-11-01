//
//  DBMemory.swift
//  gps-server
//
//  Created by Gabriel Zolnierczuk on 29/10/2018.
//

import Foundation

final class DBMemory {
	var tags: [Tag] = []
	var tagLocations: [String: [Location]] = [:]
	
	init() {
		self.tags = []
		self.tagLocations = [:]
	}
	
	func add(tag: Tag) {
		guard !self.tags.contains(tag) else { return }
		self.tags.append(tag)
	}
	
	func add(location: Location, for tagId: String) {
		if let currentLocations: [Location] = self.tagLocations[tagId] {
			let newLocations: [Location] = currentLocations + [location]
			self.tagLocations[tagId] = newLocations
		} else {
			self.tagLocations[tagId] = [location]
		}
	}
	
	func locations(for tagId: String) -> [Location]? {
		return self.tagLocations[tagId]
	}
	
	func tag(with id: String) -> Tag? {
		return self.tags.first(where: { $0.id == id })
	}
}
