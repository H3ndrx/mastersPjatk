import Foundation
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

final class BasicController {
	var routes: [Route] {
		return [Route(method: .get, uri: "/all", handler: all)]
	}
	
	func all(request: HTTPRequest, response: HTTPResponse) {
		do {
			let json = try AcronymAPI.test()
			response.setBody(string: json)
				.setHeader(.contentType, value: "application/json")
				.completed()
		} catch {
			response.setBody(string: "Error handling request: \(error)")
				.completed(status: .internalServerError)
		}
	}
}
