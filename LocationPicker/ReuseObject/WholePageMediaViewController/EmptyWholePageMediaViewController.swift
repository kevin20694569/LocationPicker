

import UIKit

class EmptyWholePageMediaViewController : WholePageMediaViewController {

    
    init(presentForTabBarLessView: Bool, post_id : String) {
        super.init(nibName: nil, bundle: nil)
        self.presentForTabBarLessView = presentForTabBarLessView
        self.postID = post_id
    }
    
    override func dismissSelf() {
        self.navigationController?.popViewController(animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutNavBar() {
        super.layoutNavBar()
        self.navigationItem.title = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.panWholeViewGesture.isEnabled = false
        self.view.layer.cornerRadius = 0
        self.navigationController?.sh_fullscreenPopGestureRecognizer.isEnabled = true
    }
    
    override func viewDidLoad() {
        layout()
        layoutBottomBarView()
        collectionViewFlowSet()
        registerCells()
        viewStyleSet()
        setGestureTarget()
        layoutBlurView()
        configurePostTitleView()
        Task {
            do {
                let post = try await PostManager.shared.getPostDetail(post_id: self.postID, request_user_id: Constant.user_id)
                currentPost = post
                collectionView.delegate = self
                collectionView.dataSource = self
                self.configureData(post: currentPost)
                self.panWholeViewGesture.isEnabled = false
                updateCellPageControll(currentCollectionIndexPath: currentMediaIndexPath)
            } catch {
                print(error)
            }
        }
    }
    
    

}
