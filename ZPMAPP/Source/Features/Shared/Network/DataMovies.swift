//
//  DataMovies.swift
//  ZPMAPP
//
//  Created by Alan Silva on 14/09/21.
//

import Foundation


struct APIMovieData: Codable {
    let results: [DataMovies]
}
struct DataMovies: Codable {
    let backdrop_path: String?
    let name: String?
    let overview: String?
}
