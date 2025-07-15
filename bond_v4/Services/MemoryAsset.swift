//
//  MemoryAsset.swift
//  bond_v4
//
//  Created by CJ Sanchez on 7/10/25.
//

import Foundation
import AVFoundation

class MemoryAsset: NSObject, AVAssetResourceLoaderDelegate {
    private let data: Data
    private let fileType: AVFileType
    
    init(data: Data, fileType: AVFileType) {
        self.data = data
        self.fileType = fileType
        super.init()
    }
    
    func makePlayerAsset()-> AVURLAsset {
        let url = URL(string: "inmemory://asset-\(UUID().uuidString)")!
        let asset = AVURLAsset(url: url)
        asset.resourceLoader.setDelegate(self, queue: .main)
        return asset
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let contentRequest = loadingRequest.contentInformationRequest {
            contentRequest.contentType = fileType.rawValue
            contentRequest.contentLength = Int64(data.count)
            contentRequest.isByteRangeAccessSupported = true
        }
        if let dataRequest = loadingRequest.dataRequest {
            let requestedOffset = Int(dataRequest.requestedOffset)
            let requestedLength = dataRequest.requestedLength
            let requestedData = data.subdata(in: requestedOffset..<(requestedOffset + requestedLength))
            dataRequest.respond(with: requestedData)
        }
        loadingRequest.finishLoading()
        return true
    }
    
    
    
    
    
    
    
    
    
    
}
