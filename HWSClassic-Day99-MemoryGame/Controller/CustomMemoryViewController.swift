//
//  CustomMemoryViewController.swift
//  Project30M
//
//  Created by Romain Buewaert on 08/12/2021.
//

import UIKit

class CustomMemoryViewController: UIViewController {
    // MARK: - Properties
    var numberOfCouple = 0
    var propositionList = [[String]]()
    var gameManage = GameManage()

    // MARK: - Outlets
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet var buttonList: [UIButton]!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.isEnabled = false

        for button in buttonList {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
            button.layer.cornerRadius = 10
        }
    }

    // MARK: - Actions
    @IBAction func addTapped(_ sender: Any) {
        guard let firstText = firstTextField.text else { return }
        guard let secondText = secondTextField.text else { return }

        let combination = [firstText, secondText]
        propositionList.insert(combination, at: 0)
        numberOfCouple += 1
        tableView.reloadData()

        firstTextField.text = ""
        secondTextField.text = ""
        addButton.isEnabled = false
        addButton.backgroundColor = .systemGray4
    }

    @IBAction func validateTapped(_ sender: Any) {
        if propositionList.count < 20 {
            let ac = UIAlertController(title: "Insufficient combinations", message: "\(20 - propositionList.count) missing combinations", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Enter a name to save your custom game", message: nil, preferredStyle: .alert)
            ac.addTextField(configurationHandler: nil)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
                guard let title = ac?.textFields?[0].text else { return }
                guard let propositionList = self?.propositionList else { return }

                guard let categories = self?.gameManage.customCategories.wordCategories else { return }
                for category in categories {
                    print(category.title)
                    if title == category.title {
                        let ac = UIAlertController(title: "Title already use", message: "Please choose another title", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            return
                        }))
                        self?.present(ac, animated: true, completion: nil)
                    }
                }

                let customCategory = WordCategory(title: title, wordList: propositionList)
                self?.gameManage.customCategories.wordCategories.append(customCategory)
                self?.gameManage.saveCustomCategories(completionHandler: { [weak self] success in
                    if success {
                        self?.returnToMainMenu()
                    } else {
                        let ac = UIAlertController(title: "Failed to save custom game", message: nil, preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(ac, animated: true, completion: nil)
                    }
                })
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

    @IBAction func returnTapped(_ sender: Any) {
            if storyboard?.instantiateViewController(withIdentifier: "MainMenu") as? MainMenuViewController != nil {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Method
    func returnToMainMenu() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "MainMenu") as? MainMenuViewController {
            vc.gameManage = gameManage
//            vc.mainView.isHidden = true
//            vc.categoryWordListView.isHidden = false
            navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UITextField
extension CustomMemoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if firstTextField.text != "" && secondTextField.text != "" {
            addButton.isEnabled = true
            addButton.backgroundColor = .green
        }
        return true
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        firstTextField.resignFirstResponder()
        secondTextField.resignFirstResponder()
    }
}

// MARK: - TableView
extension CustomMemoryViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return propositionList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PropositionCell", for: indexPath)

        let coupleToDisplay = propositionList[indexPath.row]
        let firstText = coupleToDisplay[0]
        let secondText = coupleToDisplay[1]

        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = "\(firstText) -- \(secondText)"
        contentConfig.textProperties.numberOfLines = 0
        cell.contentConfiguration = contentConfig

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if propositionList.count < 20 {
            return "\(20 - propositionList.count) missing combinations"
        } else {
            return "Sufficient number of words, you can add another if you want"
        }
    }
}

extension CustomMemoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            propositionList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
}
