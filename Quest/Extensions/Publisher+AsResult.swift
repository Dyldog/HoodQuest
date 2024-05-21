//
//  Publisher+AsResult.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation
import Combine

extension Publisher {
	func asResult() -> AnyPublisher<Result<Output, Failure>, Never> {
		self
			.map(Result.success)
			.catch { error in
				Just(.failure(error))
			}
			.eraseToAnyPublisher()
	}
}
