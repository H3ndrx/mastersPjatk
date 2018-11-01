//
//  TagController.swift
//  gps-server
//
//  Created by Gabriel on 06.05.2018.
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectCRUD

final class TagController: BasicController {
	private static let name: String = "tag"
	var routes: [Route] {
		return [Route(method: .get, uri: "\(BasicController.apiRoute)/\(TagController.name)/tags", handler: self.tags),
				Route(method: .post, uri: "\(BasicController.apiRoute)/\(TagController.name)/beaconDetected", handler: self.addTag),
				Route(method: .post, uri: "\(BasicController.apiRoute)/\(TagController.name)/{tagId}/updateLocation", handler: self.updateLocationForTag),
				Route(method: .get, uri: "\(BasicController.apiRoute)/\(TagController.name)/{tagId}/locations", handler: self.locationsForTag),
				Route(method: .get, uri: "\(BasicController.apiRoute)/\(TagController.name)/{tagId}/location", handler: self.locationForTag)]
	}
	
	private func tags(request: HTTPRequest, response: HTTPResponse) {
		tagService.getAllTags(with: response)
	}
	
	private func addTag(request: HTTPRequest, response: HTTPResponse) {
		tagService.addTag(with: request, response: response)
	}
	
	private func updateLocationForTag(request: HTTPRequest, response: HTTPResponse) {
		tagService.updateLocationForTag(with: request, response: response)
	}
	
	private func locationsForTag(request: HTTPRequest, response: HTTPResponse) {
		tagService.locationsForTag(with: request, response: response)
	}
	
	private func locationForTag(request: HTTPRequest, response: HTTPResponse) {
		tagService.locationForTag(with: request, response: response)
	}
}
