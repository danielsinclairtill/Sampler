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
    private let urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func request<R>(_ request: R, result: ((Result<R.Response, APIError>) -> Void)?) where R : RequestAPIContract {
        func completion(_ finalResult: Result<R.Response, APIError>) {
            DispatchQueue.main.async {
                result?(finalResult)
            }
        }
        
        // 1. URL Construction (Renamed variable to avoid shadowing)
        guard var components = URLComponents(string: baseUrl + request.path) else {
            assertionFailure("url for api request was not formatted correctly")
            completion(.failure(.serverError))
            return
        }
        
        components.queryItems = request.parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }.sorted { $0.name < $1.name }
        
        guard let url = components.url else {
            assertionFailure("url for api request was not formatted correctly")
            completion(.failure(.serverError))
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
                var data: Data?
                switch body {
                case .encodable(let object):
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .sortedKeys
                    data = try encoder.encode(object)
                case .dictionary(let dict):
                    data = try JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
                }
                urlRequest.httpBody = data
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                assertionFailure("body for api request was not formatted correctly")
                result?(.failure(.requestError))
                return
            }
        }
        
        // 3. Network Execution
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            // Check for fundamental networking errors (e.g., offline)
            if let error = error as? URLError {
                if error.code == .notConnectedToInternet || error.code == .timedOut {
                    completion(.failure(.lostConnection))
                } else {
                    completion(.failure(.serverError))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.serverError))
                return
            }
            
            // 4. Status Code Handling (Using Switch to prevent multiple callbacks)
            switch httpResponse.statusCode {
            case 200...299:
                // Success range, proceed to decoding
                break
            case 400:
                completion(.failure(.requestError))
                return
            case 401:
                completion(.failure(.authentification))
                return
            default:
                completion(.failure(.serverError))
                return
            }
            
            // 5. Data Unwrapping
            guard let data = data else {
                completion(.failure(.serverError))
                return
            }
            
            // 6. Decoding
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(R.Response.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.serverError))
            }
        }
        task.resume()
    }
}
