//
//  DBMemory.swift
//  gps-server
//
//  Created by Gabriel Zolnierczuk on 29/10/2018.
//

import Foundation

enum DBError: Error {
	case notFound
}

final class DBMemory {
	var tags: [Tag] = []
	var tagLocations: [String: [LocationFromDevice]] = [:]
	
	init() {
		self.tags = []
		self.tagLocations = [:]
	}
	
	func add(tag: Tag) {
		guard !self.tags.contains(tag) else { return }
		self.tags.append(tag)
	}
	
	func add(location: Location, for tagId: String, fromDeviceId: String) -> Bool {
		guard let tag: Tag = self.tag(with: tagId) else {
			print("Tag doesnt exist")
			return false
		}
		let newLoc: LocationFromDevice = LocationFromDevice(location: location, deviceId: fromDeviceId, tagId: tagId)
		guard let currentLocations: [LocationFromDevice] = self.tagLocations[tag.id] else {
			self.tagLocations[tagId] = [newLoc]
			print("NEW location for tag: \(tagId) from \(fromDeviceId)")
			return true
		}
		var mutableLocations: [LocationFromDevice] = currentLocations
		if let index: Int = currentLocations.firstIndex(where: { $0.deviceId == fromDeviceId }) {
			mutableLocations.remove(at: index)
		}
		mutableLocations.append(newLoc)
		self.tagLocations[tagId] = mutableLocations
		print("UPDATING location for tag: \(tagId) from \(fromDeviceId)")
		return true
	}
	
	func locations(for tagId: String) -> [Location]? {
		return self.tagLocations[tagId]?.compactMap({ $0.location })
	}
	
	func tag(with id: String) -> Tag? {
		return self.tags.first(where: { $0.id == id })
	}
	
	func contains(tag: Tag) -> Bool {
		if self.tag(with: tag.id) != nil {
			return true
		} else {
			return false
		}
	}
}
