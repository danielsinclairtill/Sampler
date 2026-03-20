//
//  SamplerAPI.swift
//  Sampler
//
//
//

import Foundation

class SamplerAPI: APIContract {
    // See [https://dummyjson.com/docs/recipes#recipes-all](https://dummyjson.com/docs/recipes#recipes-all) for documentation on test API
    let baseUrl = "https://dummyjson.com"
    let imageManager: ImageManagerContract = SamplerAPIImageManager()
    
    func request<R>(_ request: R) async throws -> R.Response where R : RequestAPIContract {
        // 1. URL Construction
        guard var urlComponents = URLComponents(string: baseUrl + request.path) else {
            assertionFailure("url for api request was not formatted correctly")
            throw APIError.serverError
        }
        
        urlComponents.queryItems = request.parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }.sorted { $0.name < $1.name }
        
        guard let url = urlComponents.url else {
            assertionFailure("url for api request was not formatted correctly")
            throw APIError.serverError
        }
        
        // 2. Request Configuration
        var urlRequest = URLRequest(url: url, timeoutInterval: request.timeoutInterval)
        urlRequest.httpMethod = request.method.rawValue.capitalized
        
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = request.body {
            do {
                var data: Data?
                switch body {
                case .encodable(let object):
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .sortedKeys
                    data = try encoder.encode(object)
                case .dictionary(let dict):
                    guard JSONSerialization.isValidJSONObject(dict) else {
                        assertionFailure("body for api request was not formatted correctly")
                        throw APIError.requestError
                    }
                    data = try JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
                }
                urlRequest.httpBody = data
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                assertionFailure("body for api request was not formatted correctly")
                throw APIError.requestError
            }
        }
        
        // 3. Network Execution
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError
            }
            
            // 4. Status Code Handling
            switch httpResponse.statusCode {
            case 200...299:
                // Success - continue to decoding
                break
            case 400:
                throw APIError.requestError
            case 401:
                throw APIError.authentification
            default:
                throw APIError.serverError
            }
            
            // 5. Decoding
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(R.Response.self, from: data)
            } catch {
                // Mapping decoding errors to serverError to match original logic
                throw APIError.serverError
            }
            
        } catch let error as URLError {
            // 6. Network Error Mapping
            if error.code == .notConnectedToInternet || error.code == .timedOut {
                throw APIError.lostConnection
            } else {
                throw APIError.serverError
            }
        } catch let error as APIError {
            // Re-throw known API errors (from status code checks)
            throw error
        } catch {
            // Catch-all for any other unexpected errors
            throw APIError.serverError
        }
    }
}
