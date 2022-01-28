//
//  MemoryImageViewController.swift
//  Project30M
//
//  Created by Romain Buewaert on 03/12/2021.
//

import UIKit

final class ImageMemoryViewController: UIViewController {
    // MARK: - Properties
    var gameManage = GameManage()
    var imagesToFind = [String]()
    var numberOfCards = 28
    var cardsFind = 0
    var cardsUsed = [UIButton]()
    var numberOfReturnedCards = 0
    var selectedCards = [UIButton]()

    // MARK: - Outlets
    @IBOutlet var cardsButtonQty28: [UIButton]!
    @IBOutlet var cardsButtonQty24: [UIButton]!
    @IBOutlet var cardsButtonQty20: [UIButton]!
    @IBOutlet var cardsButtonQty18: [UIButton]!
    @IBOutlet var cardsButtonQty16: [UIButton]!
    @IBOutlet var cardsButtonQty12: [UIButton]!
    @IBOutlet var cardsButtonQty10: [UIButton]!
    @IBOutlet weak var stackViewLastRight: UIStackView!
    @IBOutlet weak var stackViewCenterRight: UIStackView!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGame()
        configureCards()
    }

    // MARK: - Privates Methods to launch game
    private func configureGame() {
        for button in cardsButtonQty28 {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 10
            button.imageView?.layer.cornerRadius = 10
            button.setBackgroundImage(UIImage(systemName: "questionmark"), for: .normal)
            button.tintColor = .black
            button.isHidden = true
            button.alpha = 1
        }

        if numberOfCards == 10 {
            stackViewLastRight.isHidden = true
            stackViewCenterRight.isHidden = true
            for cardButton in cardsButtonQty10 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }

        if numberOfCards == 12 {
            stackViewLastRight.isHidden = true
            for cardButton in cardsButtonQty12 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }

        if numberOfCards == 16 {
            for cardButton in cardsButtonQty16 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }

        if numberOfCards == 18 {
            stackViewLastRight.isHidden = true
            for cardButton in cardsButtonQty18 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }

        if numberOfCards == 20 {
            for cardButton in cardsButtonQty20 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }

        if numberOfCards == 24 {
            for cardButton in cardsButtonQty24 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }

        if numberOfCards == 28 {
            for cardButton in cardsButtonQty28 {
                cardButton.isHidden = false
                cardsUsed.append(cardButton)
            }
        }
    }

    private func configureCards() {
        if gameManage.imageList.isEmpty {
            gameManage.loadCards()
        }
        let cardList = gameManage.imageList.shuffled()
        for card in 1...(numberOfCards / 2) {
            imagesToFind.append(cardList[card])
        }
        cardsUsed = cardsUsed.shuffled()

        var currentIndex = 0
        for index in 0...(cardsUsed.count - 1) {
            let image = UIImage(named: imagesToFind[currentIndex])
            cardsUsed[index].setImage(image, for: .selected)
            cardsUsed[index].imageView?.isHidden = true

            if currentIndex < (imagesToFind.count - 1) {
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
            selectedCards[0].imageView?.isHidden = true
            selectedCards[1].imageView?.isHidden = true
            selectedCards.removeAll()
            numberOfReturnedCards = 0
        }

        let transitionOptions: UIView.AnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        UIView.transition(with: sender, duration: 0.5, options: transitionOptions) {
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
        if selectedCards[0].image(for: .selected) == selectedCards[1].image(for: .selected) {
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
            ac.addAction(UIAlertAction(title: "10", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 10)
            }))
            ac.addAction(UIAlertAction(title: "12", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 12)
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
            ac.addAction(UIAlertAction(title: "24", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 24)
            }))
            ac.addAction(UIAlertAction(title: "28", style: .default, handler: { [weak self] _ in
                self?.configureNewGame(quantityOfCard: 28)
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
        imagesToFind.removeAll()
        cardsUsed.removeAll()
        selectedCards.removeAll()
        stackViewLastRight.isHidden = false
        stackViewCenterRight.isHidden = false
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
