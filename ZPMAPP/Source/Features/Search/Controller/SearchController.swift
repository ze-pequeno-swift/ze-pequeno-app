//
//  SearchController.swift
//  ZPMAPP
//
//  Created by Gabriela Sillis on 25/08/21.
//

import Foundation

enum selectedScopeBar: Int {
    case title = 0
    case actors = 1
    case user = 2
}

class SearchController {

    private var arrayMovie: [MovieList] = [
        MovieList(title: "Joker", image: "joker", genre: "Drama", length: "2h10m", actors: "Elizabeth Olsen"), MovieList(title: "Viúva Negra", image: "black-widow", genre: "Ação", length: "1h50", actors: "Elizabeth Banks"), MovieList(title: "Nós", image: "us", genre: "Terror", length: "2h50m", actors: "Mary Elizabeth"), MovieList(title: "Midsommar", image: "midsommar", genre: "Terror", length: "2h40m", actors: "Elizabeth Olsen"), MovieList(title: "Jaws", image: "jaws", genre: "Suspense", length: "1h50", actors: "Elizabeth Banks")
    ]

    private var arrayFilmSearchResult: [MovieList] = []
    private var arrayActorsSearchResult: [MovieList] = []
    //private var arrayUsersSearchResult: [Users] = []

    func resultCount() -> Int {
        if checkFilmEmptyState() {
            return arrayActorsSearchResult.count
        } else {
            return arrayFilmSearchResult.count
        }
    }

    func checkFilmEmptyState() -> Bool {
        return arrayFilmSearchResult.isEmpty
    }

    func loadCustomFilmCell(indexPath: IndexPath) -> MovieList {
        return self.arrayFilmSearchResult[indexPath.row]
    }

    func loadCustomActorsCell(indexPath: IndexPath) -> MovieList {
        return self.arrayActorsSearchResult[indexPath.row]
    }

    func searchMovieResults(searchText: String, index: Int) {

        if searchText.isEmpty {
            self.arrayFilmSearchResult = []
            self.arrayActorsSearchResult = []
        }

        switch index {
            case selectedScopeBar.title.rawValue:
                self.arrayFilmSearchResult = self.arrayMovie.filter { model -> Bool in
                    guard let movie = model.title?.uppercased() else { return false }
                    return movie.contains(searchText.uppercased())
                }
            case selectedScopeBar.actors.rawValue:
                self.arrayActorsSearchResult = self.arrayMovie.filter { model -> Bool in
                    guard let movie = model.actors?.uppercased() else { return false }
                    return movie.contains(searchText.uppercased()) 
                }
            default:
                print("error")
        }
    }
}

