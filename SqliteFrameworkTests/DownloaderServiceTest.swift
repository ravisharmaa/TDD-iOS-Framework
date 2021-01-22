//
//  SqliteFrameworkTests.swift
//  SqliteFrameworkTests
//
//  Created by Ravi Bastola on 20/01/2021.
//

import XCTest
@testable import SqliteFramework


class DummyDownnloadTask: URLSessionDownloadTask {
    
    override func resume() {
        //
    }
}

class MockDownloaderService: DownloadRequestProtocol {
    
    var downloadTaskCallCount: Int = 0
    
    func downloadTask(with request: URLRequest, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Void) -> URLSessionDownloadTask {
        downloadTaskCallCount += 1
        return DummyDownnloadTask()
    }
}

class DownloaderServiceTest: XCTestCase {

    func test_file_downloader_downloads_twice_when_the_url_is_hit_twice () {
    
        let mockDownloaderService = MockDownloaderService()
        
        let downloadRequest = DownloadRequest()
        downloadRequest.urlSession = mockDownloaderService
        
        let sut = FileDownloader(intentdedFileType: .database, request: downloadRequest)
        
        sut.downloadFileFromURL(completion: {_ in })
        sut.downloadFileFromURL(completion: {_ in })
        
        XCTAssertEqual(mockDownloaderService.downloadTaskCallCount, 2)
    }
    
}
