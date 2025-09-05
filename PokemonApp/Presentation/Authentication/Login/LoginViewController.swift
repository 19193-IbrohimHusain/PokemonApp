//
//  LoginViewController.swift
//  PokemonApp
//
//  Created by Ibrohim Husain on 14/08/25.
//

import UIKit
import SnapKit

final class LoginViewController: BaseViewController {
    private let containerImage = UIView()
    
    private let pokeballImage = UIImageView().configure {
        $0.image = UIImage(named: "Pokeball")
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 24, weight: .semibold)
        $0.text = "Pokemon App"
    }
    
    private let loginLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.text = "Login"
    }
    
    private let emailField = FormTextField().configure {
        $0.placeholder = "Email"
    }
    
    private let passwordField = FormTextField().configure {
        $0.placeholder = "Password"
        $0.isSecureTextEntry = true
        $0.rightViewMode = .always
    }
    
    private let showPasswordImage = UIImageView(image: UIImage(systemName: "eye.fill"))
    private let rightViewPasswordField = UIView(frame: CGRectMake(0, 0, 40, 40))
    
    private let signInBtn = UIButton(type: .system).configure {
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("Sign In", for: .normal)
        $0.setCornerRadius(radius: 12)
        $0.setBorder(1, color: .white)
        $0.backgroundColor = .systemBlue
    }
    
    private let infoLabel = UILabel().configure {
        $0.font = .systemFont(ofSize: 14, weight: .regular)
        $0.text = "don't have an account?"
    }
    
    private let signUpBtn = UIButton(type: .system).configure {
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.setTitle("Sign Up", for: .normal)
        $0.backgroundColor = .clear
        $0.setContentHuggingPriority(.required, for: .horizontal)
    }
        
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        bindEvent()
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
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        view.addSubviews(containerImage, titleLabel, loginLabel, emailField, passwordField, signInBtn, infoLabel, signUpBtn)
        containerImage.addSubview(pokeballImage)
        rightViewPasswordField.addSubview(showPasswordImage)
        showPasswordImage.center = CGPointMake(rightViewPasswordField.width / 2, rightViewPasswordField.height / 2)
        passwordField.rightView = rightViewPasswordField
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    private func setConstraints() {
        containerImage.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(100)
            $0.height.equalTo(Screen.width - 100 - 100)
        }
        pokeballImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(100)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(containerImage.snp.bottom).inset(20)
        }
        loginLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(titleLabel.snp.bottom).inset(-16)
        }
        emailField.snp.makeConstraints {
            $0.top.equalTo(loginLabel.snp.bottom).inset(-10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        passwordField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).inset(-16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        signInBtn.snp.makeConstraints {
            $0.top.equalTo(passwordField.snp.bottom).inset(-26)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.height.equalTo(40)
        }
        infoLabel.snp.makeConstraints {
            $0.leading.equalTo(signInBtn).inset(35)
            $0.top.equalTo(signInBtn.snp.bottom).inset(-10)
        }
        signUpBtn.snp.makeConstraints {
            $0.leading.equalTo(infoLabel.snp.trailing).inset(-4)
            $0.height.equalTo(17)
            $0.top.equalTo(signInBtn.snp.bottom).inset(-10)
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
        
        signInBtn
            .publisher(for: .touchUpInside)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.viewModel.loadingState.send(.loading)
                self.validateForm()
            }
            .store(in: &cancellables)
        
        signUpBtn
            .publisher(for: .touchUpInside)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.navigateToRegisterView()
            }
            .store(in: &cancellables)
        
        viewModel.loadingState
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self = self else { return }
                switch $0 {
                case .loading:
                    LoadingHUD.show(in: self.view)
                case .finished:
                    LoadingHUD.show(in: self.view)
                    self.navigateToTabView()
                default:
                    LoadingHUD.hide(from: self.view)
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
    
    private func validateForm() {
        guard let email = self.emailField.text, !email.isEmpty, self.viewModel.validateEmail(candidate: email) else {
            self.viewModel.loadingState.send(.failed)
            self.viewModel.displayAlert.send(("Sign In Failed", "Please Enter Valid Email"))
            return
        }
        
        guard let password = self.passwordField.text, !password.isEmpty, self.viewModel.validatePassword(candidate: password) else {
            self.viewModel.loadingState.send(.failed)
            self.viewModel.displayAlert.send(("Sign In Failed", "Please Enter Valid Password"))
            return
        }
        
        self.viewModel.login(email: email, password: password)
    }
    
    private func navigateToTabView() {
        let vc = ParentTabViewController()
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    private func navigateToRegisterView() {
        let vc = RegisterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.setBorder(1, color: .systemGray4)
        if textField.isEqual(emailField) {
            passwordField.becomeFirstResponder()
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
