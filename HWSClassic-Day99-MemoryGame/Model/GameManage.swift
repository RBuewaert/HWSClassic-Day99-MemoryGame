//
//  GameManage.swift
//  Project30M
//
//  Created by Romain Buewaert on 08/12/2021.
//

import Foundation

final class GameManage {
    // MARK: - Properties
    var imageList = [String]()
    var defaultCategories = [WordCategory]()
    var customCategories = CustomCategories(wordCategories: [])

    // MARK: - Methods
    func loadCards() {
        if let fileToLoad = Bundle.main.url(forResource: "ListOfCards", withExtension: "json") {
            if let data = try? Data(contentsOf: fileToLoad) {
                print("data: ", data)
                if let jsonDecodable = try? JSONDecoder().decode(CardList.self, from: data) {
                    imageList = jsonDecodable.imageList
                    defaultCategories = jsonDecodable.wordCategories
                }
            }
        }
    }

    func loadCustomCategories() {
        let defaults = UserDefaults.standard
        if let savedCustomWords = defaults.object(forKey: "customWords") as? Data {
            let jsonDecoder = JSONDecoder()

            do {
                customCategories = try jsonDecoder.decode(CustomCategories.self, from: savedCustomWords)
                print("catégories:", customCategories)
            } catch {
                print("Failed to load saved categories.")
            }
        } else {
            let emptyCategory = WordCategory(title: "Empty", wordList: [])
            let customCategory = CustomCategories(wordCategories: [emptyCategory])

            customCategories = customCategory
        }
    }

    func saveCustomCategories(completionHandler: ((Bool) -> ())?) {
        let jsonEncoder = JSONEncoder()

        if let savedData = try? jsonEncoder.encode(customCategories) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "customWords")
            guard let completionHandler = completionHandler else {
                return
            }
            completionHandler(true)
            print("OK")
        } else {
            guard let completionHandler = completionHandler else {
                return
            }
            completionHandler(false)
            print("Failed to saved custom categories.")
        }
    }

    func loadWordFromCategory(_ categories: [WordCategory], currentWordCategory: String) -> Int? {
        var indexToFind = 0
        for (index, category) in categories.enumerated() {
            if category.title == currentWordCategory {
                indexToFind = index
                print("index", index)
                print("index to find", indexToFind)
                return indexToFind
            }
        }
        return nil
    }
}
