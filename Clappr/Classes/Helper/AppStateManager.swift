import Foundation

protocol AppStateManagerDelegate: class {
    #if os(iOS)
    func didChange(state: UIApplicationState)
    #endif
}

class AppStateManager: NSObject {

    private weak var delegate: AppStateManagerDelegate?

    @discardableResult
    init(delegate: AppStateManagerDelegate) {
        self.delegate = delegate
        super.init()
    }

    deinit {
        stopMonitoring()
    }

    func startMonitoring() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeState), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeState), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    func stopMonitoring() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    @objc private func didChangeState() {
        #if os(iOS)
            delegate?.didChange(state: UIApplication.shared.applicationState)
        #endif
    }
}
