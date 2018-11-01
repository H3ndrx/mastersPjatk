import Foundation

final class AcronymAPI {
	static func acronymsToJSON(_ acronyms: [Acronym]) -> [JSON] {
		var array: [JSON] = []
		for row in acronyms {
			array.append(row.dictionary)
		}
		return array
	}
	
	static func allAsDictionary() throws -> [JSON] {
		let acronyms: [Acronym] = try Acronym.getAll()
		return self.acronymsToJSON(acronyms)
	}
	
	static func all() throws -> String {
		return try self.allAsDictionary().jsonEncodedString()
	}
	
	static func test() throws -> String {
		return try self.all()
	}
}
