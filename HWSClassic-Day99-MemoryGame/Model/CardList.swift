//
//  CardList.swift
//  Project30M
//
//  Created by Romain Buewaert on 03/12/2021.
//

import Foundation

struct CardList: Codable {
    let imageList: [String]
    let wordCategories: [WordCategory]
}

struct WordCategory: Codable {
    let title: String
    let wordList: [[String]]
}

struct CustomCategories: Codable {
    var wordCategories: [WordCategory]
}
