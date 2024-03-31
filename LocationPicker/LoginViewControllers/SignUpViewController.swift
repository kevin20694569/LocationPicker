
import UIKit
/*import Firebase

class SignUpViewController: UIViewController {
    
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBAction func registerAccount(sender: UIButton) {
        guard let name = nameTextField.text, name != "",
              let emailAddress = emailTextField.text, emailAddress != "",
              let password = passwordTextField.text, password != "" else {
            let alertController = UIAlertController(title: "Registration Error", message: "Please make sure you provide your name, email address and password to complete the registration.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        
        Auth.auth().createUser(withEmail: emailAddress, password: password, completion: {
            (user, error) in
            if let error = error {
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            
            // 儲存使⽤者的名稱
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = name
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print("Failed to change the display name: \(error.localizedDescription)")
                    }
                })
            }
            self.view.endEditing(true)
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainPageViewcontroller") {
                UIApplication.shared.keyWindow?.rootViewController = viewController
                self.dismiss(animated: true, completion: nil)
            }
            
        })
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    
    
}*/
