//
//  ViewController.swift
//  KeychainWrapper
//
//  Created by Emilio Parra on 05/06/21.
//

import UIKit

enum SecurePersistenActions: Int {
    case save = 0, load, list
}

class ViewController: UIViewController {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Secure Persistent Memory"
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "Secure Persistent Memory"
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let keyTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Key"
        tf.textColor = .white
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 1.3
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let entryTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Entry"
        tf.textColor = .white
        tf.layer.borderColor = UIColor.white.cgColor
        tf.layer.borderWidth = 1.3
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let saveEntryBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("SAVE ENTRY", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .red
        btn.tag = SecurePersistenActions.save.rawValue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let loadEntryBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("LOAD ENTRY", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .green
        btn.tag = SecurePersistenActions.load.rawValue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let listKeysBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("LIST KEYS", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .blue
        btn.tag = SecurePersistenActions.list.rawValue
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    let keychainWrapper = SecurePersistentMemory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }

    @objc func actionButton(_ sender: UIButton) {
        let tag = sender.tag
        if tag == SecurePersistenActions.save.rawValue {
            saveAction()
        }
        
        if tag == SecurePersistenActions.load.rawValue {
            loadAction()
        }
        
        if tag == SecurePersistenActions.list.rawValue {
            listAction()
        }
        
    }
    
    func listAction() {
        do {
            let entry = try keychainWrapper.listKeys()
            resultLabel.text = entry.reduce("", { (res, text) -> String in
                "\(res)\(text)."
            })
        } catch let error as NSError {
            print(error.description)
        }
    }

    func loadAction() {
        guard let key = keyTextField.text, !key.isEmpty else {
            print("Key is missing.")
            return
        }
        do {
            let entry = try keychainWrapper.entry(forKey: key)
            resultLabel.text = entry ?? ""
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func saveAction() {
        guard let entry = entryTextField.text, let key = keyTextField.text, !entry.isEmpty, !key.isEmpty else {
            print("Entry or key is missing.")
            return
        }
        do {
            try keychainWrapper.set(entry: entry, forKey: key)
        } catch let error as NSError {
            print(error.description)
        }
        
        entryTextField.text = ""
        keyTextField.text = ""
    }

}

extension ViewController {
    func config(){
        self.view.backgroundColor = .lightGray
        self.view.addSubview(titleLabel)
        self.view.addSubview(resultLabel)
        self.view.addSubview(keyTextField)
        self.view.addSubview(entryTextField)
        self.view.addSubview(loadEntryBtn)
        self.view.addSubview(saveEntryBtn)
        self.view.addSubview(listKeysBtn)
        loadEntryBtn.addTarget(self, action: #selector(actionButton(_:)), for: .touchUpInside)
        saveEntryBtn.addTarget(self, action: #selector(actionButton(_:)), for: .touchUpInside)
        listKeysBtn.addTarget(self, action: #selector(actionButton(_:)), for: .touchUpInside)
        setConstraints()
    }
    func setConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40.0),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40.0),
            
            keyTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 60.0),
            keyTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            keyTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            keyTextField.heightAnchor.constraint(equalToConstant: 50.0),
            
            entryTextField.topAnchor.constraint(equalTo: keyTextField.bottomAnchor, constant: 50.0),
            entryTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            entryTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            entryTextField.heightAnchor.constraint(equalToConstant: 50.0),
            
            resultLabel.topAnchor.constraint(equalTo: entryTextField.bottomAnchor, constant: 60.0),
            resultLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resultLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            saveEntryBtn.bottomAnchor.constraint(equalTo: loadEntryBtn.topAnchor, constant: -30.0),
            saveEntryBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40.0),
            saveEntryBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40.0),
            saveEntryBtn.heightAnchor.constraint(equalToConstant: 50.0),
            
            loadEntryBtn.bottomAnchor.constraint(equalTo: listKeysBtn.topAnchor, constant: -30.0),
            loadEntryBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40.0),
            loadEntryBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40.0),
            loadEntryBtn.heightAnchor.constraint(equalToConstant: 50.0),
            
            listKeysBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30.0),
            listKeysBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 40.0),
            listKeysBtn.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -40.0),
            listKeysBtn.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
}

