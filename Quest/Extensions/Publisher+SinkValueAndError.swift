//
//  Publisher+SinkValueAndError.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Combine

extension Publisher {
	func sink(_ value: @escaping (Output) -> Void, error: @escaping (Failure) -> Void) -> Cancellable {
		self.sink { completion in
			switch completion {
			case let .failure(errorValue): error(errorValue)
			case .finished: break
			}
		} receiveValue: {
			value($0)
		}

	}
}
