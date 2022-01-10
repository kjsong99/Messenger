//
//  LoginViewController.swift
//  Messanger
//
//  Created by 송경진 on 2022/01/06.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - UIFIELD
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image=UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        
        let placeholderText = NSAttributedString(string: "Email Address",
                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.attributedPlaceholder = placeholderText
        
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        
        field.leftView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField : UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Password",
                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.attributedPlaceholder = placeholderText
        field.leftView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton : UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20 , weight : .bold)
        return button
    }()
    
    private let fbLoginButton : FBLoginButton = {
        let fbLoginButton = FBLoginButton()
        fbLoginButton.permissions = ["public_profile", "email", "user_birthday"]
        fbLoginButton.layer.cornerRadius = 12
        fbLoginButton.layer.masksToBounds = true
        fbLoginButton.titleLabel?.font = .systemFont(ofSize: 20 , weight : .bold)
        return fbLoginButton
    }()
    
    private let googleLoginButton  = GIDSignInButton()
    
    
    
    private var loginObserver : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification,
                                                               object: nil,
                                                               queue: .main,
                                                               using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        
        
        
        // MARK: - ADD SUBVIEW
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLoginButton)
        
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(loginObserver)
        }
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/5
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y:30,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+20 ,
                                  width: scrollView.width-60 ,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10 ,
                                     width: scrollView.width-60 ,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10 ,
                                   width: scrollView.width-60 ,
                                   height: 52)
        
        fbLoginButton.center = scrollView.center
        fbLoginButton.frame = CGRect(x: 30,
                                     y: loginButton.bottom+10 ,
                                     width: scrollView.width-60 ,
                                     height: 52)
        fbLoginButton.layer.cornerRadius = 12
        
        googleLoginButton.frame = CGRect(x: 30,
                                         y: fbLoginButton.bottom+10 ,
                                         width: scrollView.width-60 ,
                                         height: 52)
        googleLoginButton.layer.cornerRadius = 12
        
        //        fbLoginButton.frame.origin.y = loginButton.bottom + 20
        
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else{
                  alertUserLoginError()
                  return
              }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user! \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        
    }
    
    func alertUserLoginError(){
        
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}




extension LoginViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController : LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields" : "email, name, birthday, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else{
                print("Failed to make facebook graph request")
                return
            }
            
            print("\(result)")
            print(type(of: result["birth"]))
            
            guard let userName = result["name"] as? String,
                  let birth = result["birthday"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String else {
                      print("Failed to get email and name from fb result")
                      return
                  }
            //
            //            let formatter = DateFormatter()
            //            formatter.dateFormat = "YYYY-mm-dd"
            //
            //            let birth = formatter.string(from: result["birth"] as! Date)
            
            //            var firstIndex = userName.index(userName.startIndex, offsetBy: 0)
            //            var lastIndex = userName.index(userName.startIndex, offsetBy: 1)
            //
            //            let lastName = userName[firstIndex..<lastIndex]
            //
            //             firstIndex = userName.index(userName.startIndex, offsetBy: 1)
            //             lastIndex = userName.index(userName.startIndex, offsetBy: 3)
            //
            //            let firstName = userName[firstIndex..<lastIndex]
            //
            //            print("last name : \(lastName)")
            //            print("first name : \(firstName)")
            
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                
                if !exists {
                    //                    //insert user
                    let chatUser = ChatAppUser(name: userName,
                                               birth: birth,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with:chatUser, completion: { success in
                        if success {
                            //upload image
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    print("Failed to get data from fb")
                                    return
                                }
                                
                                print("got data from FB, uploading.")
                                
                                let filename = chatUser.profilePictureFileNmae
                                StorageManager.shared.uploadProfilePicture(with: data,
                                                                           fileName: filename,
                                                                           completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl,forKey: "profile_picture_url")
                                        print(downloadUrl)
                                        
                                    case .failure(let error) :
                                        print("Storage manager error \(error)")
                                    }
                                })
                            }).resume()
                            
                        }
                    } )
                }
            })
            
            
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard  authResult != nil , error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed - \(error)")
                        
                    }
                    
                    return
                }
                
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
            
            
            
            //
            
            
            
            //code
        })
    }
}

