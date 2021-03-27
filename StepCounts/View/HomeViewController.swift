//
//  HomeViewController.swift
//  StepCounts
//
//  Created by Ashish Dwivedi on 26/03/21.
//

import UIKit

protocol HomeViewHandling {
    func showLoader()
    func hideLoader()
    func reloadView()
}

class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    
    private let inputStepCountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = Display.stepCountPlaceholder
        textField.keyboardType = .numberPad
        textField.font = FontBook.inputStepCountText
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = ColorPalette.background
        textField.layer.cornerRadius = Dimension.cornerRadius
        textField.layer.masksToBounds = true
        textField.textAlignment = .center
        textField.textColor = UIColor.black
        return textField
    }()
    
    private let resultInfoLabel: UILabel = {
        let label = UILabel()
        label.text = Display.welcomeMessageForResult
        label.font = FontBook.resultInfoLabelText
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    private let containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = Dimension.interItemSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var loaderIndicator: UIAlertController?
    
    
    // MARK: Initialization
    
    init(with viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.setViewHandler(self)
        self.view.backgroundColor = .white
        self.containerStackView.addArrangedSubview(self.inputStepCountTextField)
        self.containerStackView.addArrangedSubview(self.resultInfoLabel)
        self.view.addSubview(self.containerStackView)
        self.layoutComponents()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    
    // MARK: - View Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.inputStepCountTextField.becomeFirstResponder()
        self.viewModel.viewDidLoad()
    }
    
    
    // MARK: - Private methods
    
    private func layoutComponents() {
        self.inputStepCountTextField.heightAnchor.constraint(
            equalToConstant: Dimension.inputStepCountTextHeight).isActive = true
        
        self.containerStackView.leadingAnchor.constraint(
            equalTo: self.view.leadingAnchor, constant: Dimension.padding).isActive = true
        self.containerStackView.trailingAnchor.constraint(
            equalTo: self.view.trailingAnchor, constant: -Dimension.padding).isActive = true
        self.containerStackView.topAnchor.constraint(
            equalTo: self.view.topAnchor, constant: Dimension.topPadding).isActive = true
        self.containerStackView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor, constant: -Dimension.bottomPadding).isActive = true
    }
}


// MARK: - Helper methods

private extension HomeViewController {
    private enum Display {
        static let stepCountPlaceholder = "Enter your step count here ?"
        static let welcomeMessageForResult = "We will check your health data and show your goal status. Hang on!"
    }
    
    private enum FontBook {
        static let inputStepCountText = UIFont.systemFont(ofSize: 15)
        static let resultInfoLabelText = UIFont.systemFont(ofSize: 13, weight: .light)
    }
    
    private enum Dimension {
        static let interItemSpacing: CGFloat = 10
        static let inputStepCountTextHeight: CGFloat = 44
        static let padding: CGFloat = 20
        static let topPadding: CGFloat = 100
        static let bottomPadding: CGFloat = padding * 2
        static let cornerRadius: CGFloat = 4
    }
    
    private enum ColorPalette {
        static let background: UIColor = UIColor(
            displayP3Red: 252/255, green: 251/255, blue: 247/255, alpha: 1.0)
    }
}


// MARK: - View Handling Actions

extension HomeViewController: HomeViewHandling {
    func showLoader() {
        DispatchQueue.main.async {[weak self] in
            let loaderAlert = UIAlertController(
                title: nil, message: "Loading...", preferredStyle: .alert)
            let activityIndicatorView = UIActivityIndicatorView(
                frame: .init(x: 10, y: 5, width: 50, height: 50))
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.startAnimating()
            activityIndicatorView.style = .medium
            loaderAlert.view.addSubview(activityIndicatorView)
            self?.loaderIndicator = loaderAlert
            self?.present(loaderAlert, animated: true, completion: nil)
        }
    }
    
    func hideLoader() {
        DispatchQueue.main.async {[weak self] in
            self?.loaderIndicator?.dismiss(animated: true, completion: nil)
        }
    }
    
    func reloadView() {
        
    }
}

