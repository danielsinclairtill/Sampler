//
//  EnviromentProvider+Data.swift
//  Sampler
//
//  Created by Daniel on 2026-03-31.
//

protocol APIProvider {
    var api: APIContract { get }
}

protocol ImageMangagerProvider {
    /// Manager used to download, prefetch, and cache images.
    var imageManager: ImageManagerContract { get }
}

protocol StoreProvider {
    var store: StoreContract { get }
}

protocol StateProvider {
    var state: any SamplerStateContract { get }
}

protocol LikeManagerProvider {
    var likeManager: any LikeManagerContract { get }
}
