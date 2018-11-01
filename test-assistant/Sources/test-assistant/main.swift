import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import PostgresStORM

PostgresConnector.host = "localhost"
PostgresConnector.username = "perfect"
PostgresConnector.password = "perfect"
PostgresConnector.database = "perfect_testing"
PostgresConnector.port = 5432

let setupObj = Acronym()
try? setupObj.setup()

let server: HTTPServer = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

var routes: Routes = Routes()
routes.add(method: .get, uri: "/") { (request: HTTPRequest, response: HTTPResponse) in
	response.setBody(string: "Hello, perfect!")
		.completed()
}

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

routes.add(method: .get, uri: "/hello") { (request, response) in
	returnJSONMessage(with: "Hello, JSON", response: response)
}

routes.add(method: .get, uri: "/beers/{num_beers}") { (request, response) in
	guard let numBeerString: String = request.urlVariables["num_beers"],
		let numBeer: Int = Int(numBeerString) else {
			response.completed(status: .badRequest)
			return
	}
	returnJSONMessage(with: "you requested \(numBeer) beers right now", response: response)
}

routes.add(method: .post, uri: "post") { (request, response) in
	guard let name: String = request.param(name: "name") else {
		response.completed(status: .badRequest)
		return
	}
	returnJSONMessage(with: "Hello, \(name)", response: response)
}

func new(request: HTTPRequest, response: HTTPResponse) {
	do {
		guard let json: String = request.postBodyString,
			let dict: [String: String] = try json.jsonDecode() as? [String: String],
			let short: String = dict["short"],
			let long: String = dict["long"] else {
				response.completed(status: .badRequest)
				return
		}
		
		let acronym: Acronym = Acronym()
		acronym.short = short
		acronym.long = long
		try acronym.save { id in
			acronym.id = id as! Int
		}
		returnJSON(with: acronym.dictionary, response: response)
	} catch {
		response.setBody(string: "Error handling request: \(error)")
			.completed(status: .internalServerError)
	}
}

func first(request: HTTPRequest, response: HTTPResponse) {
	do {
		let getObj = Acronym()
		
		let cursor = StORMCursor(limit: 1, offset: 0)
		try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
		
		if let acronym: Acronym = getObj.rows().first {
			returnJSON(with: acronym.dictionary, response: response)
		} else {
			returnJSON(with: [], response: response)
		}
	} catch {
		response.setBody(string: "Error handling request: \(error)")
			.completed(status: .internalServerError)
	}
}

func afks(request: HTTPRequest, response: HTTPResponse) {
	do {
		let getObj = Acronym()
		
		var findObject: JSON = [:]
		findObject["short"] = "AFK"
		
		try getObj.find(findObject)
		
		var acronyms: [JSON] = []
		for row in getObj.rows() {
			acronyms.append(row.dictionary)
		}
		returnJSON(with: acronyms, response: response)
	} catch {
		response.setBody(string: "Error handling request: \(error)")
			.completed(status: .internalServerError)
	}
}

func nonAfk(request: HTTPRequest, response: HTTPResponse) {
	do {
		let getObj = Acronym()
		
		try getObj.select(whereclause: "short != $1", params: ["AFK"], orderby: ["id"])
		
		var acronyms: [JSON] = []
		for row in getObj.rows() {
			acronyms.append(row.dictionary)
		}
		returnJSON(with: acronyms, response: response)
	} catch {
		response.setBody(string: "Error handling request: \(error)")
			.completed(status: .internalServerError)
	}
}

func update(request: HTTPRequest, response: HTTPResponse) {
	do {
		guard let json: String = request.postBodyString,
			let dict: [String: String] = try json.jsonDecode() as? [String: String],
			let short: String = dict["short"],
			let long: String = dict["long"] else {
				response.completed(status: .badRequest)
				return
		}
		let getObj = Acronym()
		let cursor = StORMCursor(limit: 1, offset: 0)
		try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
		
		guard let acronym: Acronym = getObj.rows().first else {
			response.completed(status: .badRequest)
			return
		}
		
		acronym.short = short
		acronym.long = long
		try acronym.save()
		
		returnJSON(with: acronym.dictionary, response: response)
	} catch {
		response.setBody(string: "Error handling request: \(error)")
			.completed(status: .internalServerError)
	}
}

func deleteFirst(request: HTTPRequest, response: HTTPResponse) {
	do {
		let getObj = Acronym()
		
		let cursor = StORMCursor(limit: 1, offset: 0)
		try getObj.select(whereclause: "true", params: [], orderby: [], cursor: cursor)
		
		guard let acronym: Acronym = getObj.rows().first else {
			response.completed(status: .badRequest)
			return
		}
		
		try acronym.delete()
		
		returnJSON(with: acronym.dictionary, response: response)
	} catch {
		response.setBody(string: "Error handling request: \(error)")
			.completed(status: .internalServerError)
	}
}

routes.add(method: .get, uri: "/first", handler: first)
routes.add(method: .get, uri: "/afks", handler: afks)
routes.add(method: .get, uri: "/non-afks", handler: nonAfk)
routes.add(method: .post, uri: "/new", handler: new)
routes.add(method: .post, uri: "/update", handler: update)
routes.add(method: .delete, uri: "/deleteFirst", handler: deleteFirst)

server.addRoutes(routes)

let basicController = BasicController()
server.addRoutes(Routes(basicController.routes))

do {
	try server.start()
} catch PerfectError.networkError(let error, let msg) {
	print("Network error thrown \(error) \(msg)")
}
