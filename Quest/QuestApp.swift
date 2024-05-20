//
//  QuestApp.swift
//  Quest
//
//  Created by Dylan Elliott on 19/5/2024.
//

import SwiftUI

@main
struct QuestApp: App {
	
	let visitManager: VisitManager
	
	init() {
		do {
			let database = try Database()
			visitManager = .init(database: database)
		} catch {
			fatalError(error.localizedDescription)
		}
	}
    var body: some Scene {
        WindowGroup {
			ContentView(viewModel: .init(visitManager: visitManager))
        }
    }
}
