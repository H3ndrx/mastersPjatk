import StORM
import PostgresStORM

typealias JSON = [String: Any]

class Acronym: PostgresStORM {
	var id: Int = 0
	var short: String = ""
	var long: String = ""
	
	var dictionary: JSON {
		return [ "id": self.id,
				 "short": self.short,
				 "long": self.long ]
	}
	
	override open func table() -> String {
		return "acronyms"
	}
	
	override func to(_ this: StORMRow) {
		self.id = this.data["id"] as? Int ?? 0
		self.short = this.data["short"] as? String ?? ""
		self.long = this.data["long"] as? String ?? ""
	}
	
	func rows() -> [Acronym] {
		var rows: [Acronym] = [Acronym]()
		for i in 0..<self.results.rows.count {
			let row: Acronym = Acronym()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}
	
	static func getAll() throws -> [Acronym] {
		let getObj = Acronym()
		try getObj.findAll()
		return getObj.rows()
	}
}
