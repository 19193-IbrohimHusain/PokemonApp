//
//  RegisterViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import AsyncDisplayKit

final class RegisterViewController: BaseASDKViewController {
    private let pokeballImage = ASImageNode().configure {
        $0.image = UIImage(named: "Pokeball")
        $0.contentMode = .scaleAspectFit
        $0.style.preferredSize = CGSizeMake(100, 100)
    }
    
    private let titleNode = ASTextNode().configure {
        $0.attributedText = NSAttributedString(
            string: "Pokemon App",
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
    }
    
    private let registerNode = ASTextNode().configure {
        $0.attributedText = NSAttributedString(
            string: "Register",
            attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        )
    }
    
    private let usernameField = FormTextField().configure {
        $0.placeholder = "Name"
    }
    
    private let emailField = FormTextField().configure {
        $0.placeholder = "Email"
    }
    
    private let passwordField = FormTextField().configure {
        $0.placeholder = "Password"
        $0.isSecureTextEntry = true
        $0.rightViewMode = .always
    }
    
    private let confirmPasswordField = FormTextField().configure {
        $0.placeholder = "Confirm Password"
        $0.isSecureTextEntry = true
        $0.rightViewMode = .always
    }
    
    private let rightViewPasswordField = UIView(frame: CGRectMake(0, 0, 40, 40))
    private let rightViewConfirmPasswordField = UIView(frame: CGRectMake(0, 0, 40, 40))
    private let showPasswordImage = UIImageView(image: UIImage(systemName: "eye.fill"))
    private let showConfirmPasswordImage = UIImageView(image: UIImage(systemName: "eye.fill"))
    
    private let signUpBtn = ASButtonNode().configure {
        $0.setTitle("Sign Up", with: .systemFont(ofSize: 14, weight: .semibold), with: .white, for: .normal)
        $0.backgroundColor = .systemBlue
        $0.cornerRadius = 12
        $0.borderWidth = 1
        $0.borderColor = UIColor.systemBackground.cgColor
        $0.style.height = ASDimensionMake(40)
    }
    
    private let infoNode = ASTextNode().configure {
        $0.attributedText = NSAttributedString(
            string: "already have an account?",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
        )
    }
    
    private let signInBtn = ASButtonNode().configure {
        $0.setTitle("Sign In", with: .systemFont(ofSize: 14, weight: .semibold), with: .systemBlue, for: .normal)
    }
        
    private let viewModel = RegisterViewModel()
    
    override func configNode() {
        node.backgroundColor = .systemBackground
        setLayout()
        bindEvent()
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rightViewPasswordField.addSubview(showPasswordImage)
        showPasswordImage.center = CGPointMake(rightViewPasswordField.width / 2, rightViewPasswordField.height / 2)
        passwordField.rightView = rightViewPasswordField
        rightViewConfirmPasswordField.addSubview(showConfirmPasswordImage)
        showConfirmPasswordImage.center = CGPointMake(rightViewConfirmPasswordField.width / 2, rightViewConfirmPasswordField.height / 2)
        confirmPasswordField.rightView = rightViewConfirmPasswordField
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.visible()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    private func setLayout() {
        node.layoutSpecBlock = { [weak self] node, size in
            guard let self = self else { return ASLayoutSpec() }
            let insetImage = ASInsetLayoutSpec(
                insets: .init(top: node.safeAreaInsets.top + 45, left: 145, bottom: 0, right: 145),
                child: pokeballImage
            )
            let titleCenter = ASCenterLayoutSpec(centeringOptions: .X, sizingOptions: [], child: titleNode)
            
            let rowInfo = ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 4,
                justifyContent: .start,
                alignItems: .center,
                children: [infoNode, signInBtn]
            )
            
            let userNameNode = ASDisplayNode { self.usernameField }
            userNameNode.style.height = ASDimensionMake(50)
            let emailNode = ASDisplayNode { self.emailField }
            emailNode.style.height = ASDimensionMake(50)
            let passwordNode = ASDisplayNode { self.passwordField }
            passwordNode.style.height = ASDimensionMake(50)
            let confirmPasswordNode = ASDisplayNode { self.confirmPasswordField }
            confirmPasswordNode.style.height = ASDimensionMake(50)
            
            return ASStackLayoutSpec(
                direction: .vertical,
                spacing: 0,
                justifyContent: .start,
                alignItems: .stretch,
                children: [
                    insetImage,
                    ASInsetLayoutSpec(insets: .init(top: 25, left: 0, bottom: 0, right: 0), child: titleCenter),
                    ASInsetLayoutSpec(insets: .init(top: 16, left: 16, bottom: 0, right: 0), child: registerNode),
                    ASInsetLayoutSpec(insets: .init(top: 10, left: 16, bottom: 0, right: 16), child: userNameNode),
                    ASInsetLayoutSpec(insets: .init(top: 16, left: 16, bottom: 0, right: 16), child: emailNode),
                    ASInsetLayoutSpec(insets: .init(top: 16, left: 16, bottom: 0, right: 16), child: passwordNode),
                    ASInsetLayoutSpec(insets: .init(top: 16, left: 16, bottom: 0, right: 16), child: confirmPasswordNode),
                    ASInsetLayoutSpec(insets: .init(top: 26, left: 50, bottom: 0, right: 50), child: signUpBtn),
                    ASInsetLayoutSpec(insets: .init(top: 10, left: 85, bottom: 0, right: 16), child: rowInfo)
                ]
            )
        }
    }
    
    private func bindEvent() {
        rightViewPasswordField
            .tapPublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.togglePasswordVisibility()
            }
            .store(in: &cancellables)
        
        rightViewConfirmPasswordField
            .tapPublisher()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.toggleConfirmPasswordVisibility()
            }
            .store(in: &cancellables)
        
        signUpBtn
            .publisher(for: .touchUpInside)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.viewModel.loadingState.send(.loading)
                self.validateForm()
            }
            .store(in: &cancellables)
        
        signInBtn
            .publisher(for: .touchUpInside)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.navigateToLoginView()
            }
            .store(in: &cancellables)
        
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    LoadingHUDNode.show(in: self.node)
                case .finished:
                    LoadingHUDNode.show(in: self.node)
                    self.showAlertAndNavigateToLoginView()
                default:
                    LoadingHUDNode.hide()
                }
            }
            .store(in: &cancellables)
            
        viewModel.displayAlert
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                self.displayAlert(title: $0.title, message: $0.message)
            }
            .store(in: &cancellables)
    }
    
    private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry.toggle()
        showPasswordImage.image = UIImage(systemName: passwordField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill")
    }
    
    private func toggleConfirmPasswordVisibility() {
        confirmPasswordField.isSecureTextEntry.toggle()
        showConfirmPasswordImage.image = UIImage(systemName: confirmPasswordField.isSecureTextEntry ? "eye.fill" : "eye.slash.fill")
    }
    
    private func validateForm() {
        guard let name = self.usernameField.text, !name.isEmpty else {
            self.viewModel.loadingState.send(.failed)
            self.viewModel.displayAlert.send(("Sign Up Failed", "Please Enter Your Name"))
            return
        }
        
        guard let email = self.emailField.text, !email.isEmpty, self.viewModel.validateEmail(candidate: email) else {
            self.viewModel.loadingState.send(.failed)
            self.viewModel.displayAlert.send(("Sign Up Failed", "Please Enter Valid Email"))
            return
        }
        
        guard let password = self.passwordField.text, !password.isEmpty, self.viewModel.validatePassword(candidate: password) else {
            self.viewModel.loadingState.send(.failed)
            self.viewModel.displayAlert.send(("Sign Up Failed", "Please Enter Valid Password"))
            return
        }
        
        guard let confirmPassword = self.confirmPasswordField.text, !confirmPassword.isEmpty, confirmPassword == password else {
            self.viewModel.loadingState.send(.failed)
            self.viewModel.displayAlert.send(("Sign Up Failed", "Confirmed Password is not the same as Password you entered"))
            return
        }
        
        self.viewModel.register(name: name, email: email, password: password)
    }
    
    private func showAlertAndNavigateToLoginView() {
        self.displayAlert(title: "Sign Up Success!", message: "Please Sign In To Proceed", actionHandler: { _ in
            self.navigateToLoginView()
        })
    }
    
    private func navigateToLoginView() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.setBorder(1, color: .systemGray4)
        if textField.isEqual(usernameField) {
            emailField.becomeFirstResponder()
        } else if textField.isEqual(emailField) {
            passwordField.becomeFirstResponder()
        } else if textField.isEqual(passwordField) {
            confirmPasswordField.becomeFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        textField.setBorder(1, color: .systemGray4)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setBorder(1, color: .systemBlue)
    }
}
