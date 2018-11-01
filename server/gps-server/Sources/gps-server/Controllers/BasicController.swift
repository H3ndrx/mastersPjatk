//
//  ControllerProtocol.swift
//  gps-server
//
//  Created by Gabriel on 06.05.2018.
//

import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

class BasicController {
	static let apiRoute: String = "/api/v1"
	func returnJSON(with body: JSONConvertible, response: HTTPResponse) {
		do {
			try response.setBody(json: body)
				.setHeader(.contentType, value: "application/json")
				.completed()
		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
		}
	}
	
	func returnJSONMessage(with message: String, response: HTTPResponse) {
		returnJSON(with: ["message": message], response: response)
	}
}
