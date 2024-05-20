//
//  Database+Migrator.swift
//  Quest
//
//  Created by Dylan Elliott on 20/5/2024.
//

import Foundation
import GRDB

extension Database {
	var migrator: DatabaseMigrator {
		var migrator = DatabaseMigrator()
		
#if DEBUG
		migrator.eraseDatabaseOnSchemaChange = true
#endif
		
		migrator.registerMigration("Create Visits", foreignKeyChecks: .immediate) { db in
			try db.create(table: "visit") { t in
				t.primaryKey("id", .integer)
			}
		}

		return migrator
	}
}
