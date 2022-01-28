//
//  WordMemoryViewController.swift
//  Project30M
//
//  Created by Romain Buewaert on 08/12/2021.
//

import UIKit

class WordMemoryViewController: UIViewController {
    // MARK: - Properties
    var gameManage = GameManage()
    var currentWordCategory = ""
    var categoryList = [WordCategory]()
    var wordsCoupleToFind = [[String]]()
    var singleWords = [String]()
    var numberOfCards = 28
    var cardsFind = 0
    var cardsUsed = [UIButton]()
    var numberOfReturnedCards = 0
    var selectedCards = [UIButton]()

    // MARK: - Outlet
    @IBOutlet var cardsButton: [UIButton]!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGame()
        configureCards()
    }

    // MARK: - Privates Methods to launch game
    private func configureGame() {
        for button in cardsButton {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 10
            button.imageView?.layer.cornerRadius = 10
            button.setBackgroundImage(UIImage(systemName: "questionmark"), for: .normal)
            button.tintColor = .black
            button.isHidden = true
            button.alpha = 1
            button.isSelected = false
        }

        for index in 0...(numberOfCards - 1) {
            let cardButton = cardsButton[index]
            cardButton.isHidden = false
            cardsUsed.append(cardButton)
        }
    }

    private func configureCards() {
        var potentialsWords = [[String]]()

        if currentWordCategory == "Capital and country" || currentWordCategory == "Traduction FR to EN" {
            if categoryList.isEmpty {
                gameManage.loadCards()
                categoryList = gameManage.defaultCategories
            }
            guard let index = gameManage.loadWordFromCategory(categoryList, currentWordCategory: currentWordCategory) else { return }
            potentialsWords = categoryList[index].wordList
        } else {
            let customCategories = gameManage.customCategories.wordCategories
            guard let index = gameManage.loadWordFromCategory(customCategories, currentWordCategory: currentWordCategory) else { return }
            potentialsWords = customCategories[index].wordList
        }

        for index in 0...((numberOfCards - 1) / 2) {
            let array = potentialsWords[index]
            wordsCoupleToFind.append(array)
            singleWords.append(array[0])
            singleWords.append(array[1])
        }

        cardsUsed = cardsUsed.shuffled()

        var currentIndex = 0
        for index in 0...(cardsUsed.count - 1) {
            cardsUsed[index].setTitle(singleWords[index], for: .selected)

            if currentIndex < (wordsCoupleToFind.count - 1) {
                currentIndex += 1
            } else {
                currentIndex = 0
            }
        }
    }

    // MARK: - Action
    @IBAction func cardTapped(_ sender: UIButton) {
        for card in cardsUsed {
            card.isUserInteractionEnabled = false
        }

        if numberOfReturnedCards == 2 {
            selectedCards[0].setBackgroundImage(UIImage(systemName: "questionmark"), for: .normal)
            selectedCards[1].setBackgroundImage(UIImage(systemName: "questionmark"), for: .normal)
            selectedCards[0].isSelected = false
            selectedCards[1].isSelected = false
            selectedCards.removeAll()
            numberOfReturnedCards = 0
        }

        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        UIView.transition(with: sender, duration: 0.5, options: transitionOptions) {
            sender.setBackgroundImage(nil, for: .normal)
            sender.isSelected = true
        } completion: { [weak self] _ in
            self?.numberOfReturnedCards += 1
            self?.selectedCards.append(sender)

            if self?.numberOfReturnedCards == 2 {
                self?.checkSelectedCards()
            } else {
                guard let cardsUsed = self?.cardsUsed else { return }
                for card in cardsUsed {
                    card.isUserInteractionEnabled = true
                    sender.isUserInteractionEnabled = false
                }
            }
        }
    }

    // MARK: - Private methods links to Action
    private func checkSelectedCards() {
        if numberOfReturnedCards == 2 {
            let firstWord = selectedCards[0].title(for: .selected)
            let secondWord = selectedCards[1].title(for: .selected)

            for coupleOfWords in wordsCoupleToFind {
                if firstWord == coupleOfWords[0] || firstWord == coupleOfWords[1] {
                    if secondWord == coupleOfWords[0] || secondWord == coupleOfWords[1] {
                        UIView.animate(withDuration: 0.9) { [weak self] in
                            self?.selectedCards[0].alpha = 0
                            self?.selectedCards[1].alpha = 0
                        } completion: { [weak self] _ in
                            self?.selectedCards.removeAll()
                            self?.numberOfReturnedCards = 0
                            self?.cardsFind += 2

                            guard let cardsUsed = self?.cardsUsed else { return }
                            for card in cardsUsed {
                                card.isUserInteractionEnabled = true
                            }

                            if self?.cardsFind == self?.numberOfCards {
                                self?.endOfParty()
                            }
                        }
                    } else {
                        for card in cardsUsed {
                            card.isUserInteractionEnabled = true
                        }
                        return
                    }
                }
            }
        }
    }

    private func endOfParty() {
        let ac = UIAlertController(title: "You have won!", message: "What do you want to do?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "New Part with sames number of cards", style: .default, handler: { [weak self] _ in
            guard let numberOfCard = self?.numberOfCards else { return }
            self?.configureNewGame(quantityOfCard: numberOfCard)
        }))
        ac.addAction(UIAlertAction(title: "New Part with other number of cards", style: .default, handler: { [weak self] _ in
            let ac = UIAlertController(title: "Number of cards?", message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "8", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 8)
            }))
            ac.addAction(UIAlertAction(title: "10", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 10)
            }))
            ac.addAction(UIAlertAction(title: "12", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 12)
            }))
            ac.addAction(UIAlertAction(title: "14", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 14)
            }))
            ac.addAction(UIAlertAction(title: "16", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 16)
            }))
            ac.addAction(UIAlertAction(title: "18", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 18)
            }))
            ac.addAction(UIAlertAction(title: "20", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 20)
            }))
            self?.present(ac, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Return to main menu", style: .default, handler: { [weak self] _ in
            if (self?.storyboard?.instantiateViewController(withIdentifier: "MainMenu") as? MainMenuViewController) != nil {
                self?.navigationController?.popViewController(animated: true)
            }
        }))
        present(ac, animated: true, completion: nil)
    }

    private func configureNewGame(quantityOfCard: Int) {
        wordsCoupleToFind.removeAll()
        singleWords.removeAll()
        cardsUsed.removeAll()
        selectedCards.removeAll()
        numberOfCards = quantityOfCard
        numberOfReturnedCards = 0
        cardsFind = 0
        configureGame()
        configureCards()
        for card in cardsUsed {
            card.imageView?.isHidden = true
        }
    }
}
