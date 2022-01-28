//
//  MainMenuViewController.swift
//  Project30M
//
//  Created by Romain Buewaert on 03/12/2021.
//

import UIKit
import LocalAuthentication

final class MainMenuViewController: UIViewController {
    // MARK: - Properties
    var gameManage = GameManage()
    var currentWordCategory = ""
    var currentWordToFind = [[String]]()

    // MARK: - Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var numberOfImageView: UIView!
    @IBOutlet weak var categoryWordListView: UIStackView!
    @IBOutlet weak var numberOfWordsView: UIStackView!
    @IBOutlet var buttonList: [UIButton]!
    @IBOutlet weak var customWordPickerView: UIPickerView!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        for button in buttonList {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 10
        }
        customWordPickerView.layer.borderWidth = 1
        customWordPickerView.layer.borderColor = UIColor.gray.cgColor
        customWordPickerView.layer.cornerRadius = 10
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        gameManage.loadCustomCategories()

        mainView.isHidden = false
        numberOfImageView.isHidden = true
        categoryWordListView.isHidden = true
        numberOfWordsView.isHidden = true
        customWordPickerView.reloadAllComponents()
    }

    // MARK: - Actions
    @IBAction func playWithImagesTapped(_ sender: Any) {
        mainView.isHidden = true
        numberOfImageView.isHidden = false
    }

    @IBAction func playWithWordsTapped(_ sender: Any) {
        mainView.isHidden = true
        categoryWordListView.isHidden = false
    }

    @IBAction func numberOfImageTapped(_ sender: UIButton) {
        let numberOfCards = sender.tag
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageMemory") as? ImageMemoryViewController {
            vc.numberOfCards = numberOfCards
            vc.gameManage = gameManage
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func wordCategoryTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            currentWordCategory = "Capital and country"
            categoryWordListView.isHidden = true
            numberOfWordsView.isHidden = false
        } else if sender.tag == 1 {
            currentWordCategory = "Traduction FR to EN"
            categoryWordListView.isHidden = true
            numberOfWordsView.isHidden = false
        } else {
            createCustomGame()
        }
    }

    @IBAction func numberOfWordsTapped(_ sender: UIButton) {
        let numberOfCards = sender.tag
        if let vc = storyboard?.instantiateViewController(withIdentifier: "WordMemory") as? WordMemoryViewController {
            vc.numberOfCards = numberOfCards
            vc.currentWordCategory = currentWordCategory
            vc.gameManage = gameManage
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func returnTappedOnFirstMenu(_ sender: Any) {
        numberOfImageView.isHidden = true
        categoryWordListView.isHidden = true
        mainView.isHidden = false
    }
 
    @IBAction func returnTappedOnSecondMenu(_ sender: Any) {
        numberOfWordsView.isHidden = true
        categoryWordListView.isHidden = false
    }
}

// MARK: - PickerView
extension MainMenuViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gameManage.customCategories.wordCategories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gameManage.customCategories.wordCategories[row].title
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currentLineTitle = gameManage.customCategories.wordCategories[row].title
        let currentLineWords = gameManage.customCategories.wordCategories[row].wordList

        if currentLineTitle == "Empty" && currentLineWords == [] {
            return
        } else {
            currentWordCategory = currentLineTitle
            categoryWordListView.isHidden = true
            numberOfWordsView.isHidden = false
        }
    }
}

// MARK: - LocalAuthentication
extension MainMenuViewController {
    private func createCustomGame() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticating users"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] succes, authentificationError in
                DispatchQueue.main.async {
                    if succes {
                        self?.launchCustomViewController()
                    } else {
                        let ac = UIAlertController(title: "Authentication failded", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(ac, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

    private func launchCustomViewController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CustomMemory") as? CustomMemoryViewController {
            vc.gameManage = gameManage
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
