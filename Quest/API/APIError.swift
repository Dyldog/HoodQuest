//
//  APIError.swift
//  Quest
//
//  Created by Dylan Elliott on 21/5/2024.
//

import Foundation

enum APIError: Error, LocalizedError {
	case requestError
	case serverError
	case noResponse
	case responseNotString
	case couldntDecode(DecodingError)
	case unknown
	
	var errorDescription: String? {
		switch self {
		case .requestError: "Request error"
		case .serverError: "Server error"
		case .noResponse: "No response data"
		case .responseNotString: "Response data was not a string"
		case let .couldntDecode(error): "Coudln't decode: \(error.localizedDescription)"
		case .unknown: "Unknown error"
		}
	}
	
	init(error: Error) {
		switch error {
		case let error as URLError: self.init(urlError: error)
		case let error as DecodingError: self.init(decodingError: error)
		case let error as APIError: self = error
		default: self = .unknown
		}
	}
}

extension Error {
	var asAPIError: APIError { .init(error: self) }
}

extension APIError {
	init(decodingError: DecodingError) {
		self = .couldntDecode(decodingError)
	}
}

extension APIError {
	init(urlError: URLError) {
		switch urlError.code.rawValue {
		case 400 ..< 500: self = .requestError
		case 500 ..< 600: self = .serverError
		default: self = .unknown
		}
	}
}
