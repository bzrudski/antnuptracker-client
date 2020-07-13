//
// LoginViewController.swift
// AntNupTracker, the ant nuptial flight field database
// Copyright (C) 2020  Abouheif Lab
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import UIKit
import NotificationCenter
import UserNotifications

class LoginViewController: UIViewController, UITextFieldDelegate, LoginObserver {
    
    typealias LoginErrors = SessionManager.LoginErrors
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FlightAppManager.shared.sessionManager.setLoginObserver(observer: self)

        // Do any additional setup after loading the view.
        usernameField.delegate = self
        passwordField.delegate = self
        self.prepKeyboardNotifications()
    }
    

    // MARK: - UI Fields
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView:UIScrollView!
    
    // MARK: - Local Variables
    var focusedField:UITextField? = nil
    var completion:(()->())? = nil
    
    // MARK: - UI Actions
    @IBAction func login(_ sender: Any) {
        triggerLogin()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - LoginScreenObserver
    private var observer:LoginScreenObserver? = nil
    
    public func setLoginScreenObserver(_ o: LoginScreenObserver){
        self.observer = o
    }
    
    public func unsetLoginScreenObserver() {
        self.observer = nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == usernameField){
            usernameField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if (textField == passwordField){
            passwordField.resignFirstResponder()
            login(textField)
        }
        focusedField = nil
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        focusedField = textField
    }
    
    // MARK: - Keyboard management
    func prepKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset

        let desiredSpace:CGFloat = 10.0
        let keyboardTop = keyboardFrame.maxY
        if let currentFieldBottom = focusedField?.bounds.minY{
        
        let distanceBetween = currentFieldBottom - keyboardTop
        let offsetY = distanceBetween - desiredSpace

        let newRectToScrollTo = self.view.bounds.offsetBy(dx: 0, dy: offsetY)

        scrollView.scrollRectToVisible(newRectToScrollTo, animated: true)
        }
    }
    
    func triggerLogin() {
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        let deviceInfo = Device.getInfoForDevice()
        
        FlightAppManager.shared.sessionManager.login(username: username, password: password, deviceInfo: deviceInfo)
    }
    
    func loggedIn(s: Session) {
        DispatchQueue.main.async {
            FlightAppManager.shared.session = s
            FlightAppManager.shared.sessionManager.saveSession(s)
//            self.dismiss(animated: true, completion: self.completion)
//            FlightAppManager.shared.sessionManager
            self.observer?.loginScreenHasLoggedIn()
            self.unsetLoginScreenObserver()
            self.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    func loggedInWithError(e: Error) {
        DispatchQueue.main.async {
            let title: String
            let body: String
            let alert: UIAlertController
            var actions: [UIAlertAction] = []
            
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            switch e {
            case LoginErrors.emptyUserPass:
                title = "Empty Username or Password"
                body = "Please enter your username and password before continuing."
                actions.append(okAction)
            case LoginErrors.noResponse:
                title = "Network Error"
                body = "No response from the server. Please check your network connection and try again."
                actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                actions.append(UIAlertAction(title: "Try Again", style: .default, handler: {action in
                    self.triggerLogin()
                }))
            case LoginErrors.incorrectCreds:
                title = "Incorrect Login"
                body = "Your login credentials failed. Please try again."
                actions.append(okAction)
            case LoginErrors.jsonParseError:
                title = "Parse Error"
                body = "Error parsing the response. Please try again later."
                actions.append(okAction)
            case let LoginErrors.otherError(status: status):
                title = "Login Error"
                body = "Error logging in (status=\(status)). Please try again later. If the problem persists, please contact us."
                actions.append(okAction)
            default:
                title = "Other Error"
                body = "Some other error occurred. Please try again later."
                actions.append(okAction)
            }
            
            alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
            
            for action in actions {
                alert.addAction(action)
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
//    // MARK: - Switch to account creator
//    @IBAction func switchToCreate(_ sender: Any) {
//        let createView = UIStoryboard(name: "WebAccount", bundle: .main).instantiateInitialViewController()!
//        self.dismiss(animated: true, completion: {
//            self.navigationController!.pushViewController(createView, animated: true)
////            self.parent!.present(createView, animated: true, completion: nil)
//        })
//    }
    
    @IBAction func createAccount(_ sender: UIButton){
        UIApplication.shared.open(URLManager.current.getCreateAccountURL())
    }
    
    @IBAction func forgotPassword(_ sender: UIButton){
        UIApplication.shared.open(URLManager.current.getPasswordResetURL())
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        scrollView.contentInset.bottom = 0
    }

}
