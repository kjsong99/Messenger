//
//  RegisterViewController.swift
//  Messanger
//
//  Created by 송경진 on 2022/01/06.
//

import UIKit
import FirebaseAuth


class RegisterViewController: UIViewController {
    
    // MARK: - UIFIELD
    
    private let scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image=UIImage(systemName: "person.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        //       imageView.layer.borderWidth = 2
        //       imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()
    
    private let emailField : UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Email Address",
                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.attributedPlaceholder = placeholderText
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
        field.returnKeyType = .continue
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
    
    private let nameField : UITextField = {
        let field = UITextField()
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        let placeholderText = NSAttributedString(string: "Name",
                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.attributedPlaceholder = placeholderText
        field.leftView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    //
    //    private let lastNameField : UITextField = {
    //       let field = UITextField()
    //        field.textColor = .black
    //        field.autocapitalizationType = .none
    //        field.autocorrectionType = .no
    //        field.returnKeyType = .done
    //        field.layer.cornerRadius = 12
    //        field.layer.borderWidth = 1
    //        field.layer.borderColor = UIColor.lightGray.cgColor
    //        let placeholderText = NSAttributedString(string: "Last Name",
    //                                                            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    //        field.attributedPlaceholder = placeholderText
    //        field.leftView = UIView (frame: CGRect(x: 0, y: 0, width: 5, height: 0))
    //        field.leftViewMode = .always
    //        field.backgroundColor = .white
    //        return field
    //    }()
    
    private let birthdayLabel : UILabel = {
        let label = UILabel()
        
        label.text = "Birth"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 17 , weight : .bold)
        
        label.textAlignment = .left
        return label
    }()
    
    private let birthdayPicker : UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        let locale = Locale(identifier: "ko_KO")
        datePicker.locale = locale
        
        datePicker.preferredDatePickerStyle = .wheels
        return datePicker
    }()
    
    private let registerButton : UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20 , weight : .bold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        
        //       navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
        //                                                           style: .done,
        //                                                           target: self,
        //                                                           action: #selector(didTapRegister))
        registerButton.addTarget(self,
                                 action: #selector(registerButtonTapped),
                                 for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        nameField.delegate = self
        
        //       firstNameField.delegate = self
        //       lastNameField.delegate = self
        
        
        // MARK: - ADD SUBVIEW
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(birthdayLabel)
        scrollView.addSubview(birthdayPicker)
        scrollView.addSubview(nameField)
        //       scrollView.addSubview(lastNameField)
        scrollView.addSubview(registerButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        
        
        imageView.addGestureRecognizer(gesture)
        
        
    }
    
    @objc private func didTapChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/2
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y:30,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+20 ,
                                  width: scrollView.width-60 ,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10 ,
                                     width: scrollView.width-60 ,
                                     height: 52)
        
        nameField.frame = CGRect(x: 30,
                                 y: passwordField.bottom+10 ,
                                 width: scrollView.width-60 ,
                                 height: 52)
        
        birthdayLabel.frame = CGRect(x: 35,
                                     y: nameField.bottom+10 ,
                                     width: 40,
                                     height: 52)
        
        birthdayPicker.frame = CGRect(x: 75,
                                      y: nameField.bottom+10 ,
                                      width: scrollView.width-95 ,
                                      height: 52)
        
        //       firstNameField.frame = CGRect(x: 30,
        //                                 y: passwordField.bottom+10 ,
        //                                 width: scrollView.width-60 ,
        //                                 height: 52)
        //
        //       lastNameField.frame = CGRect(x: 30,
        //                                 y: firstNameField.bottom+10 ,
        //                                 width: scrollView.width-60 ,
        //                                 height: 52)
        registerButton.frame = CGRect(x: 30,
                                      y: birthdayPicker.bottom+10 ,
                                      width: scrollView.width-60 ,
                                      height: 52)
    }
    
    //    @objc private func registerButtonTapped(){
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "MM/dd/YYYY"
    //        let birthday = formatter.string(from: birthdayPicker.date)
    //    }
    
    @objc private func registerButtonTapped(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        
        //       firstNameField.resignFirstResponder()
        //       lastNameField.resignFirstResponder()
        //
        //       guard let firstName = firstNameField.text,
        //             let lastrName = lastNameField.text,
        
        
        
        let birthday = formatter.string(from: birthdayPicker.date)
        
        guard let email = emailField.text,
              let password = passwordField.text,
              let name = nameField.text,
              !email.isEmpty,
              !password.isEmpty,
              !birthday.isEmpty,
              !name.isEmpty,
              //             !firstName.isEmpty,
              //             !lastrName.isEmpty,
                password.count >= 6 else{
                    alertUserRegisterError()
                    return
                }
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            guard !exists else {
                //user already exists
                strongSelf.alertUserRegisterError(message: "Looks like a user account for that email address already exists.")
                return
                
            }
            
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                                password: password,
                                                completion: { authResult, error in
                
                
                guard authResult != nil , error == nil else {
                    print("Error creating user")
                    return
                }
                
                
                DatabaseManager.shared.insertUser(with: ChatAppUser(name: name,
                                                                    birth: birthday,
                                                                    emailAddress: email))
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
        })
    }
    
    func alertUserRegisterError(message : String = "Please enter all information to create a new account" ){
        
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        
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

extension RegisterViewController : UITextFieldDelegate {
    
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            nameField.becomeFirstResponder()
        }
        else if textField == nameField {
            nameField.resignFirstResponder()
        }
        
        else{
            registerButtonTapped()

        }
        //        else if textField == passwordField {
        //            firstNameField.becomeFirstResponder()
        //        }
        //        else if textField == firstNameField {
        //            lastNameField.becomeFirstResponder()
        //        }
        //        else if textField == lastNameField {
        //            registerButtonTapped()
        //        }
        
        return true
    }
}

extension RegisterViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancle",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentCamera()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presetPhotoPicker()
            
        }))
        
        present(actionSheet,animated: true)
        
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated: true)
    }
    
    func presetPhotoPicker(){
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}



