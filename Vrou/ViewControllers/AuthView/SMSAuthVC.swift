//
//  SMSAuthVC.swift
//  Vrou
//
//  Created by Islam Elgaafary on 4/12/20.
//  Copyright © 2020 waysGroup. All rights reserved.
//

import UIKit
import PKHUD
import FirebaseCore
import FirebaseAuth

class SMSAuthVC: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet var numbersTxtFields: [UITextField]!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var errorMsgLbl: UILabel!
    @IBOutlet weak var resendCodeBtn: UIButton!
    
    // MARK: - Variables
    var verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
    var Code = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLbl.text = "\("A 6-digit confirmation code has been sent to Your Email".ar()) \(SignUpData.params["email"] ?? "") \("and Send to".ar()) \(SignUpData.params["phone"] ?? "") \("via SMS".ar())"
        
        numbersTxtFields.forEach { (txtField) in
            txtField.delegate = self
        }
        backImage.AddBlurEffect(blueEffectStrength: 0.4)
        setTransparentNavagtionBar()
    }

    
    // MARK: - IBAction
    @IBAction func ResendCodeBtn_pressed(_ sender: Any) {
//        if checkEmptyTxtFields() {
//            verification()
//            resendCodeBtn.isHidden = true
//            errorMsgLbl.isHidden = true
//        }else {
//            HUD.flash(.label("Please fill all fields"), delay: 2 , completion: nil)
//        }
    }
    
    // MARK: - Firebase Funcitons
    func verification() {
        HUD.show(.progress, onView: self.view)
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID!,
            verificationCode: Code)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                HUD.hide()
                self.numbersTxtFields.forEach { (txtField) in
                    txtField.borderColor = #colorLiteral(red: 0.9738150239, green: 0.2587826252, blue: 0.1934048533, alpha: 1)
                }
                self.Code = ""
               // self.resendCodeBtn.isHidden = false
                self.errorMsgLbl.isHidden = false
                return
            }
            
             HUD.hide()
            let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "TermsNavController") as! TermsNavController
            keyWindow?.rootViewController = vc
        }
    }
    
    
    
        func SendPhoneNumber() {
           Auth.auth().languageCode = UserDefaults.standard.string(forKey: "Language") ?? "en"
           PhoneAuthProvider.provider().verifyPhoneNumber(SignUpData.params["phone"] ?? "", uiDelegate: nil) { (verificationID, error) in
               if let error = error {
                   HUD.flash(.labeledError(title: "حدث خطأ", subtitle: error.localizedDescription), onView: self.view, delay: 1.0, completion: nil)
                   return
               }
               // Sign in using the verificationID and the code sent to the user
              UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
              self.verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
           }
           
       }

    
}

 // MARK: - UITextFieldDelegate
extension SMSAuthVC: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.borderColor = #colorLiteral(red: 0.7631620765, green: 0.2140536606, blue: 0.5194403529, alpha: 1)
        textField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        
        if textField.text?.count ?? 0 > 0 {
            textField.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }else {
            textField.backgroundColor = #colorLiteral(red: 0.2803636789, green: 0.2248003483, blue: 0.431211561, alpha: 0.9)
        }
        
        if textField == numbersTxtFields[5] {
            if checkEmptyTxtFields() {
                verification()
            }else {
                HUD.flash(.label("Please fill all fields".ar()), delay: 2 , completion: nil)
            }
        }
        
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text?.count ?? 0 == 0 {
            if textField == numbersTxtFields[0] {
                CheckTxtField(index: 0, next_index: 1, text: string)
            }
            if textField == numbersTxtFields[1] {
                CheckTxtField(index: 1, next_index: 2, text: string)
            }
            if textField == numbersTxtFields[2] {
                CheckTxtField(index: 2, next_index: 3, text: string)
            }
            if textField == numbersTxtFields[3] {
                CheckTxtField(index: 3, next_index: 4, text: string)
            }
            if textField == numbersTxtFields[4] {
                CheckTxtField(index: 4, next_index: 5, text: string)
            }
            if textField == numbersTxtFields[5] {
                numbersTxtFields[5].text = string
                numbersTxtFields[5].backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                numbersTxtFields[5].endEditing(true)
            }
        }
        
        return true
    }
    
    
    func CheckTxtField(index:Int, next_index:Int, text:String) {
//        if numbersTxtFields[next_index].text?.count ?? 0 == 0 {
//            numbersTxtFields[next_index].becomeFirstResponder()
//        }else {
//            numbersTxtFields[index].endEditing(true)
//        }
        if text != "" && text != nil {
            numbersTxtFields[next_index].becomeFirstResponder()
            numbersTxtFields[index].text = text
            numbersTxtFields[index].backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
       
    }
    
    
    func checkEmptyTxtFields()-> Bool{
        var returnValue = true
        
        numbersTxtFields.forEach { (txtField) in
            if txtField.text == "" {
                returnValue = false
            }else {
                Code.append(txtField.text!)
            }
        }
        
        return returnValue
    }
    
    
}
