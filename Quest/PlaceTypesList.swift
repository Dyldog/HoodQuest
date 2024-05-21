//
//  PlaceTypesList.swift
//  Quest
//
//  Created by Dylan Elliott on 20/5/2024.
//

import SwiftUI
import DylKit

struct PlaceType: Identifiable, Equatable, Codable {
	let id: UUID
	var title: String
	var query: String
	
	func queryString(area: String) -> String {
		query
			.components(separatedBy: "\n\n")
			.map { section in
				section.components(separatedBy: "\n").map { "[\($0)]"}
					.joined()
			}
			.map {
				"nw" + ($0.contains("[name") ? $0 : $0 + "[name~\".+\"]") + "(\(area));"
			}
			.joined(separator: "\n")
	}
}

extension PlaceType {
	static var `default`: [PlaceType] {
		[
			.init(id: .init(), title: "Bars", query: "amenity~\"^(pub|bar|nightclub)$\"")
		]
	}
	
	static var all: [PlaceType] {
		(try? UserDefaults.standard.value(for: DefaultsKeys.placeTypes)) ?? PlaceType.default
	}
}

extension PlaceType {
	static var selected: UUID {
		get {
			(try? UserDefaults.standard.value(for: DefaultsKeys.selectedPlaceType)) ?? PlaceType.all.first!.id
		}
		set {
			try? UserDefaults.standard.set(newValue, for: DefaultsKeys.selectedPlaceType)
		}
	}
}
struct PlaceTypesList: View {
	@State var types: [PlaceType]
	
	init() {
		self.types = PlaceType.all
	}
	
	var body: some View {
		List {
			ForEach($types) { $type in
				row($type)
			}.onDelete { indexes in
				indexes.forEach {
					types.remove(at: $0)
				}
			}
		}
		.navigationTitle("Place Types")
		.toolbar {
			Button {
				types.append(.init(id: .init(), title: "", query: ""))
			} label: {
				Image(systemName: "plus")
			}
		}
		.onChange(of: types) { _, value in
			try? UserDefaults.standard.set(types, for: DefaultsKeys.placeTypes)
		}
	}
	
	private func row(_ type: Binding<PlaceType>) -> some View {
		VStack {
			TextField("Title", text: type.title).bold()
			TextField("Query", text: type.query, axis: .vertical)
		}
	}
}
