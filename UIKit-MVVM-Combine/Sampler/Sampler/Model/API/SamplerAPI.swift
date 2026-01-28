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
    
    func request<R>(_ request: R, result: ((Result<R.Response, APIError>) -> Void)?) where R : APIRequestContract {
        // 1. URL Construction (Renamed variable to avoid shadowing)
        guard var components = URLComponents(string: baseUrl + request.path) else {
            assertionFailure("url for api request was not formatted correctly")
            result?(.failure(.serverError))
            return
        }
        
        components.queryItems = request.parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }.sorted { $0.name < $1.name }
        
        guard let url = components.url else {
            assertionFailure("url for api request was not formatted correctly")
            result?(.failure(.serverError))
            return
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
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                urlRequest.httpBody = jsonData
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                assertionFailure("body for api request was not formatted correctly")
                result?(.failure(.requestError))
                return
            }
        }
        
        // 3. Network Execution
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            // Check for fundamental networking errors (e.g., offline)
            if let error = error as? URLError {
                if error.code == .notConnectedToInternet || error.code == .timedOut {
                    result?(.failure(.lostConnection))
                } else {
                    result?(.failure(.serverError))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                result?(.failure(.serverError))
                return
            }
            
            // 4. Status Code Handling (Using Switch to prevent multiple callbacks)
            switch httpResponse.statusCode {
            case 200...299:
                // Success range, proceed to decoding
                break
            case 400:
                result?(.failure(.requestError))
                return
            case 401:
                result?(.failure(.authentification))
                return
            default:
                result?(.failure(.serverError))
                return
            }
            
            // 5. Data Unwrapping
            guard let data = data else {
                result?(.failure(.serverError))
                return
            }
            
            // 6. Decoding
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(R.Response.self, from: data)
                result?(.success(decodedData))
            } catch {
                result?(.failure(.serverError))
            }
        }
        task.resume()
    }
}
