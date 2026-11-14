import UIKit

final class RootViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let demo = ViewController()
        addChild(demo)
        demo.view.frame = view.bounds
        demo.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(demo.view)
        demo.didMove(toParent: self)
    }
}
