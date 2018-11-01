//
//  Configuration.swift
//  gps-server
//
//  Created by Gabriel on 06.05.2018.
//

import PerfectCRUD
import PerfectPostgreSQL

class Configuration {
	let database: Database<PostgresDatabaseConfiguration>
	init() {
		do {
		let db = Database(configuration:
			try PostgresDatabaseConfiguration(database: "gps_server", host: "localhost", port: 5432, username: "gpsserver", password: "gpsserver"))
		self.database = db
		} catch {
			fatalError("Couldnt initialize database")
		}
	}
	
	func resolve() throws {
		do {
			// Create the table if it hasn't been done already.
			// Table creates are recursive by default.
			try self.database.create(Tag.self, policy: .reconcileTable)
			
			let locationsTable = self.database.table(Location.self)
			
			// Add an index for personId, if it does not already exist.
//			try locationsTable.index(\.tagId)
		} catch {
			throw error
		}
	}
}
