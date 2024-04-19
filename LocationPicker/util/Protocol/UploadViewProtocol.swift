
import UIKit


protocol UploadDelegate : AnyObject {
    func receiveUploadProgress(progress : Double)
    func receiveUploadFinished(success : Bool)
}

protocol UploadMediaTextFieldProtocol {
    func updateTextFieldValidStatus(text : String?) -> Bool
    var textField : RoundedTextField! { get set }
}

protocol NewPostCellDelegate : UICollectionViewCell {
    var descriptionTextfield : RoundedTextField! { get }
}
