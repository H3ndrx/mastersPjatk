// swift-tools-version:4.0
// Generated automatically by Perfect Assistant
// Date: 2018-05-01 12:44:14 +0000
import PackageDescription

let package = Package(
	name: "server-test",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/PerfectLib.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/SwiftORM/Postgres-StORM.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "test-assistant", dependencies: ["PerfectHTTPServer", "PostgresStORM", "PerfectPostgreSQL"])
	]
)