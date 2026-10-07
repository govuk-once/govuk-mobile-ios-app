import UIKit

final class QualtricsSurveyHostViewController: UIViewController {
    private let surveyViewController: UIViewController
    private let notificationCenter: NotificationCenter

    init(surveyViewController: UIViewController,
         notificationCenter: NotificationCenter = .default) {
        self.surveyViewController = surveyViewController
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addChild(surveyViewController)
        surveyViewController.view.frame = view.bounds
        surveyViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(surveyViewController.view)
        surveyViewController.didMove(toParent: self)
    }

    override var childForStatusBarStyle: UIViewController? {
        surveyViewController
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isBeingDismissed else { return }
        notificationCenter.post(name: .qualtricsSurveyDismissed, object: nil)
    }
}
