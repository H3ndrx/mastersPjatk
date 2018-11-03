import PerfectLib
import PerfectHTTP
import PerfectHTTPServer


//other
//let dbConfiguration: Configuration = Configuration()
let dbMemory: DBMemory = DBMemory()

//controllers
let tagController: TagController = TagController()

//services
let tagService: TagService = TagService()

let server: HTTPServer = HTTPServer()
server.serverPort = 8080
server.documentRoot = "webroot"

server.addRoutes(Routes(tagController.routes))

do {
//	try dbConfiguration.resolve()
	try server.start()
} catch PerfectError.networkError(let error, let msg) {
	print("Network error thrown \(error) \(msg)")
}

