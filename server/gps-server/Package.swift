// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "gps-server",
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", "3.0.0"..<"4.0.0"),
		.package(url: "https://github.com/IBM-Swift/Configuration.git", from: "3.0.1"),
		.package(url: "https://github.com/PerfectlySoft/Perfect-CRUD.git", .branch("master")),
		.package(url: "https://github.com/PerfectlySoft/Perfect-PostgreSQL.git", "3.0.0"..<"4.0.0")
	],
	targets: [
		.target(name: "gps-server", dependencies: ["PerfectHTTPServer", "Configuration", "PerfectCRUD", "PerfectPostgreSQL"])
	]
)
