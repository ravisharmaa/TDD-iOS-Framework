//
//  DowloaderService.swift
//  SqliteFramework
//
//  Created by Ravi Bastola on 20/01/2021.
//

import Foundation

enum DownloadbleFileTypes {
    case database
    case image
    case unknown
    
    var downloadURL: URL {
        switch self {
        case .database:
            return URL(string: "https://sqlite-experiments.herokuapp.com/")!
        default:
            return URL(string: "")!
        }
    }
}

public enum DownloadingErrors: Error {
    case fileNotFound(reason: Error)
    case invalidResponse(reason: HTTPURLResponse)
}

protocol DownloadRequestProtocol {
    func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask
}

extension URLSession: DownloadRequestProtocol {}

class DownloadRequest {
    
    var urlSession: DownloadRequestProtocol
    
    init(session: URLSession = URLSession.shared) {
        self.urlSession = session
    }
    
    func download(with downloadURL: URL, completion: @escaping(Result<URL, DownloadingErrors>)->Void) {
        urlSession.downloadTask(with: .init(url: downloadURL)) { (dowloadedURL, response, error) in
            if let downloadError = error {
                completion(.failure(.fileNotFound(reason: downloadError)))
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.invalidResponse(reason: response)))
            }
            
            if let downloadedURL = dowloadedURL {
                completion(.success(downloadedURL))
            }
        }.resume()
    }
}

public final class FileDownloader {
    
    private let downloadURL: URL
    
    private let downloadRequest: DownloadRequest
    
    init(intentdedFileType: DownloadbleFileTypes, request: DownloadRequest = DownloadRequest()) {
        self.downloadURL = intentdedFileType.downloadURL
        self.downloadRequest = request
    }
    
    func downloadFileFromURL(completion: @escaping(Result<Bool, DownloadingErrors>)->Void) {
        
        downloadRequest.download(with: self.downloadURL) { [self] (result) in
            switch result {
            case .success(let url):
                do {
                    try saveFile(from: url)
                    completion(.success(true))
                    
                } catch {
                    print ("file error: \(error)")
                    completion(.failure(.fileNotFound(reason: error)))
                }
            case .failure(let error):
                print(error)
                completion(.failure(.fileNotFound(reason: error)))
            }
        }
    }
    
    
    fileprivate func saveFile(from downlodedPath: URL) throws {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let savedURL = documentsURL.appendingPathComponent(downlodedPath.lastPathComponent)
        
        try FileManager.default.moveItem(at: downlodedPath, to: savedURL)
    }
}
