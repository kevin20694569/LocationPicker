import UIKit
/*import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var emailTextField : UITextField! { didSet {
        emailTextField.text = ""
    }}
    @IBOutlet var passwordTextField: UITextField! { didSet {
        passwordTextField.text = ""
    }}
    
    @IBAction func login(sender: UIButton) {
        // 輸入驗證
        guard let emailAddress = emailTextField.text, emailAddress != "",
              let password = passwordTextField.text, password != "" else {
            let alertController = UIAlertController(title: "Login Error", message:"Both fields must not be blank.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            return
        }
        // 呼叫 Firebase APIs 執⾏登入
        Auth.auth().signIn(withEmail: emailAddress, password: password, completion: {
            (user, error) in
            if let error = error {
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            // 解除鍵盤
            self.view.endEditing(true)
            // 呈現主視圖
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
