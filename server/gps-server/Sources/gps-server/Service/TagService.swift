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
		self.returnJSON(with: allTags.json, response: response)
	}
	
	func addTag(with request: HTTPRequest, response: HTTPResponse) {
		do {
			guard let json: String = request.postBodyString,
				let dict: JSON = try json.jsonDecode() as? JSON,
				let _: String = dict["id"] as? String,
				let _: Int = dict["major"] as? Int,
				let _: Int = dict["minor"] as? Int else {
					response.completed(status: .badRequest)
					return
			}
			let data: Data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
			let decoder: JSONDecoder = JSONDecoder()
			let tag: Tag = try decoder.decode(Tag.self, from: data)
			self.db.add(tag: tag)
			response.completed(status: .created)
		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
		}
	}
	
	func updateLocationForTag(with request: HTTPRequest, response: HTTPResponse) {
		do {
			guard let json: String = request.postBodyString,
				let dict: JSON = try json.jsonDecode() as? JSON,
				let tagId: String = request.urlVariables["tagId"] else {
					response.completed(status: .badRequest)
					return
			}
			let data: Data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
			let decoder: JSONDecoder = JSONDecoder()
			let location: Location = try decoder.decode(Location.self, from: data)
			self.db.add(location: location, for: tagId)
			response.completed(status: .created)
			print("Added location for tag: \(tagId)")
		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
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
