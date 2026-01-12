//
//  SamplerAPI.swift
//  Sampler
//
//
//

import Foundation
import Network

class SamplerAPI: APIContract {
    // See https://dummyjson.com/docs/recipes#recipes-all for documentation on test API
    let baseUrl = "https://dummyjson.com"
    let imageManager: ImageManagerContract = SamplerAPIImageManager()
    
    func request<R>(_ request: R, result: ((Result<R.Response, APIError>) -> Void)?) where R : APIRequestContract {
        guard var url = URLComponents(string: baseUrl + request.path) else {
            assertionFailure("url for api request was not formatted correctly")
            result?(.failure(.serverError))
            return
        }
        
        url.queryItems = request.parameters?.map { key, value in
            URLQueryItem(name: key, value: value)
        }.sorted { $0.name < $1.name }
        
        guard let url = url.url else {
            assertionFailure("url for api request was not formatted correctly")
            result?(.failure(.serverError))
            return
        }
        var urlRequest = URLRequest(url: url, timeoutInterval: request.timeoutInterval)
        urlRequest.httpMethod = request.method.rawValue.capitalized
        
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = request.body{
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: body)
                urlRequest.httpBody = jsonData
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                assertionFailure("body for api request was not formatted correctly")
                result?(.failure(.requestError))
            }
        }
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error as? URLError {
                if error.code == .notConnectedToInternet || error.code == .timedOut {
                    result?(.failure(.lostConnection))
                } else {
                    result?(.failure(.serverError))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 400 {
                result?(.failure(.requestError))
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                result?(.failure(.authentification))
            }

            if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                result?(.failure(.serverError))
                return
            }
            
            guard let data = data else {
                result?(.failure(.serverError))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(R.Response.self, from: data)
                result?(.success(data))
            }
            catch {
                result?(.failure(.serverError))
            }
        }
        task.resume()
    }
}
