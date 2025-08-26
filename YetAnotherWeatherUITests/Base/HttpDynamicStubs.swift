//
//  HttpDynamicStubs.swift
//  YetAnotherWeatherUITests
//
//  Created by Иван Гребенюк on 17.08.2025.
//

import Swifter
import XCTest

enum HttpMethod {
    case GET
    case POST
    case PUT
    case DELETE
}

struct HttpStub {
    let url: String
    let jsonFileName: String
    let method: HttpMethod
    let version: Int
}

final class HttpDynamicStubs {
    
    var httpServer = HttpServer()
    var port: UInt16 = 8080
    var stubs: [HttpStub] = []
    var preferredStubVersion: Int = 1
    
    func setUp() {
        startServer()
    }
    
    func tearDown() {
        stubs = []
        httpServer.stop()
    }
    
    func setUpStub(
        url: String,
        fileName: String,
        method: HttpMethod = .GET,
        version: Int = 1
    ) {
        let stub = HttpStub(
            url: url,
            jsonFileName: fileName,
            method: method,
            version: version
        )
        
        stubs.append(stub)
        
        let response: ((HttpRequest) -> HttpResponse) = { [weak self] _ in
            guard let self else { return .internalServerError }
            
            guard let selectedStub = stubs.first(where: { stub in
                stub.version == self.preferredStubVersion &&
                stub.url == url &&
                stub.method == method
            }) else {
                return .notFound
            }
            
            
            guard let json = loadJson(fileName: selectedStub.jsonFileName) else {
                return .internalServerError
            }
            return .ok(HttpResponseBody.json(json as AnyObject))
        }
        
        switch method  {
        case .GET : httpServer.GET[url] = response
        case .POST: httpServer.POST[url] = response
        case .PUT: httpServer.PUT[url] = response
        case .DELETE: httpServer.DELETE[url] = response
        }
    }
}

// MARK: - Private

private extension HttpDynamicStubs {
    
    func dataToJson(data: Data) -> Any? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            return json
        } catch let error {
            print("JSON parsing failed⚠️", error)
            return nil
        }
    }
        
    private func loadJson(fileName: String) -> Any? {
        let bundle = Bundle(for: type(of: self))
        guard let filePath = bundle.path(forResource: fileName, ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
              let json = dataToJson(data: data) else {
            return nil
        }
        return json
    }
    
    @discardableResult
    func startServer() -> UInt16? {
        var attempts = 0
        let maximumPortAttempts = 10
        
        while attempts < maximumPortAttempts {
            let actualPort = UInt16.random(in: 8080..<10000)
            do {
                port = actualPort
                try httpServer.start(port, forceIPv4: true)
                
                // Проверяем, что сервер действительно отвечает
                if verifyServerIsRunning() {
                    print("✅ Server started and responding on port \(port)")
                    return port
                } else {
                    print("⚠️ Server started but not responding on port \(port)")
                    httpServer.stop()
                    attempts += 1
                }
            } catch SocketError.bindFailed(let message) where message == "Address already in use" {
                print("⚠️ Port \(port) is in use, retrying...")
                attempts += 1
            } catch {
                print("❌ Server start error: \(error)")
                attempts += 1
            }
        }

        print("❌ Failed to start server after \(maximumPortAttempts) attempts")
        return nil
    }
    
    func verifyServerIsRunning() -> Bool {
        // Добавляем простой тестовый маршрут для проверки
        httpServer.GET["/test"] = { _ in
            return HttpResponse.ok(.text("OK"))
        }
        
        // Проверяем, что сервер отвечает
        let testURL = URL(string: "http://localhost:\(port)/test")!
        let expectation = XCTestExpectation(description: "Server response")
        
        URLSession.shared.dataTask(with: testURL) { _, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                expectation.fulfill()
            } else {
                print("❌ Server verification failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
        
        // Ждем ответа максимум 5 секунд
        let result = XCTWaiter.wait(for: [expectation], timeout: 5.0)
        return result == .completed
    }
}
