//
//  TagService.swift
//  COpenSSL
//
//  Created by Gabriel Zolnierczuk on 29/10/2018.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

final class TagService: Service {
	private let db: DBMemory
	
	override init() {
		self.db = dbMemory
		super.init()
	}
	
	func getAllTags(with response: HTTPResponse) {
		let allTags: [Tag] = self.db.tags
		let array: JSONConvertible = ["data": allTags.json]
		self.returnJSON(with: array, response: response)
	}
	
	func addTagIfNeeded(with request: HTTPRequest, response: HTTPResponse) {
		do {
			guard let json: String = request.postBodyString,
				let dict: JSON = try json.jsonDecode() as? JSON,
				let locationDict: JSON = dict["location"] as? JSON,
				let tagId: String = dict["beaconId"] as? String,
				let deviceId: String = dict["deviceId"] as? String,
				let tag: Tag = self.createTag(with: tagId) else {
					response.completed(status: .badRequest)
					return
			}
			
			if !self.db.contains(tag: tag) {
				self.db.add(tag: tag)
			}
			try self.addLocation(from: locationDict, for: tagId, deviceId: deviceId)
			
			response.completed(status: .created)
			print("Added tag: \(tagId)")
		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
		}
	}
	
	func createTag(with id: String) -> Tag? {
		let idParts: [String] = id.components(separatedBy: ".")
		guard let major: Int = Int(idParts[0]),
			let minor: Int = Int(idParts[1]) else { return nil }
		let tag: Tag = Tag(major: major, minor: minor)
		return tag
	}
	
	func addLocation(from json: JSON, for tagId: String, deviceId: String) throws {
		let data: Data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
		let decoder: JSONDecoder = JSONDecoder()
		let location: Location = try decoder.decode(Location.self, from: data)
		let didAdd: Bool = self.db.add(location: location, for: tagId, fromDeviceId: deviceId)
		if !didAdd {
			throw DBError.notFound
		}
	}
	
	func updateLocationForTag(with request: HTTPRequest, response: HTTPResponse) {
		do {
			guard let json: String = request.postBodyString,
				let dict: JSON = try json.jsonDecode() as? JSON,
				let tagId: String = request.urlVariables["tagId"],
				let deviceId: String = dict["deviceId"] as? String,
				let locationDict: JSON = dict["location"] as? JSON else {
					response.completed(status: .badRequest)
					return
			}
			try self.addLocation(from: locationDict, for: tagId, deviceId: deviceId)
			print("Updated location for tag: \(tagId) from \(deviceId)")
			response.completed(status: .created)
		} catch {
			if error is DBError {
				response.setBody(string: "Error handling request: \(error)")
					.completed(status: .notFound)
			} else {
				response.setBody(string: "Error handling request: \(error)")
					.completed(status: .internalServerError)
			}
		}
	}
	
	func locationsForTag(with request: HTTPRequest, response: HTTPResponse) {
		guard let tagId: String = request.urlVariables["tagId"] else {
			response.completed(status: .badRequest)
			return
		}
		if let locations: [Location] = self.db.locations(for: tagId) {
			self.returnJSON(with: locations.json, response: response)
		} else {
			response.completed(status: .notFound)
		}
	}
	
	func locationForTag(with request: HTTPRequest, response: HTTPResponse) {
		guard let tagId: String = request.urlVariables["tagId"] else {
			response.completed(status: .badRequest)
			return
		}
		guard let location: Location = self.db.locations(for: tagId)?.first else {
			response.completed(status: .notFound)
			return
		}
		//here all logic behind calculating the best location for pet
		self.returnJSON(with: location.json, response: response)
	}
}
