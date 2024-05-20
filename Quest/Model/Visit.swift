//
//  Visit.swift
//  Quest
//
//  Created by Dylan Elliott on 20/5/2024.
//

import Foundation
import GRDB

struct Visit: Identifiable, Codable, FetchableRecord, PersistableRecord {
	let id: Int
}
