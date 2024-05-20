//
//  Database.swift
//  Quest
//
//  Created by Dylan Elliott on 20/5/2024.
//

import Foundation
import GRDB
import Combine

class Database {
	private let dbWriter: DatabaseWriter
	private(set) var visitsUpdated: AnyPublisher<Void, Never>!
	
	init() throws {
		self.dbWriter = try Self.createDB()
		
		try! self.migrator.migrate(self.dbWriter)
		
		self.visitsUpdated = ValueObservation.tracking { db in
			try Visit.fetchAll(db)
		}
		.shared(in: dbWriter)
		.publisher()
		.print()
		.map { _ in () }
		.replaceError(with: ())
		.eraseToAnyPublisher()
	}
	
	private static func createDB() throws -> DatabaseWriter {
		let fileManager = FileManager()
		let folderURL = try fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent("database", isDirectory: true)
		try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
		let dbURL = folderURL.appendingPathComponent("db.sqlite")

		try! fileManager.removeItem(at: dbURL)

		let dbPool = try DatabasePool(path: dbURL.path)
		return dbPool
	}
	
	func createVisit(_ visit: Visit) async {
		do {
			try await dbWriter.write { db in
				try visit.insert(db)
			}
		} catch {
			print(error)
		}
	}
	
	func deleteVisit(_ visit: Visit) async {
		do {
			try await dbWriter.write { db in
				_ = try visit.delete(db)
			}
		} catch {
			print(error)
		}
	}
	
	func visit(for id: Int) -> Visit? {
		do {
			return try dbWriter.read { db in
				return try Visit.fetchOne(db, id: id)
			}
		} catch {
			print(error)
			return nil
		}
	}
}
