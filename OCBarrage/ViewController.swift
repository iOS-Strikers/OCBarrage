import UIKit

final class ViewController: UIViewController {
    let barrageManager = OCBarrageManager()
    let contentView = UIScrollView()
    let headingLabel = UILabel()
    let introLabel = UILabel()
    let statusLabel = UILabel()
    let sectionLabel = UILabel()
    let hintLabel = UILabel()
    let modeControl = UISegmentedControl(items: ["轨道错峰", "竖排文字", "综合演示"])
    let stageView = UIView()
    let verticalPreview = YYLabel()
    let startButton = UIButton(type: .system)
    let pauseButton = UIButton(type: .system)
    let stopButton = UIButton(type: .system)
    var emissionTick = 0
    private var heartbeatTask: Task<Void, Never>?
    private(set) var demoIconImage: YYImage?
    private(set) var demoGifImage: YYImage?

    private func configureLabel(_ label: UILabel, text: String, size: CGFloat, weight: UIFont.Weight) {
        label.text = text
        label.font = .systemFont(ofSize: size, weight: weight)
        label.textColor = UIColor(red: 0.14, green: 0.17, blue: 0.19, alpha: 1)
        label.numberOfLines = 0
        contentView.addSubview(label)
    }
    private func configureButton(_ button: UIButton, title: String, action: Selector, identifier: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.86, alpha: 1)
        button.setTitleColor(UIColor(white: 0.18, alpha: 1), for: .normal)
        button.layer.cornerRadius = 16
        button.accessibilityIdentifier = identifier
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.96, blue: 0.93, alpha: 1)
        contentView.alwaysBounceVertical = true
        view.addSubview(contentView)
        configureLabel(headingLabel, text: "弹幕实验室", size: 32, weight: .bold)
        configureLabel(introLabel, text: "OCBARRAGE  /  MOTION STUDIES", size: 11, weight: .semibold)
        introLabel.textColor = UIColor(white: 0.42, alpha: 1)
        modeControl.selectedSegmentIndex = 0
        modeControl.accessibilityIdentifier = "demo.mode"
        modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        contentView.addSubview(modeControl)
        configureLabel(sectionLabel, text: "01  /  自然错峰", size: 18, weight: .semibold)
        stageView.backgroundColor = UIColor(red: 0.10, green: 0.14, blue: 0.16, alpha: 1)
        stageView.layer.cornerRadius = 22
        stageView.clipsToBounds = true
        contentView.addSubview(stageView)
        stageView.addSubview(barrageManager.renderView)
        verticalPreview.text = "让文字慢慢流动\n从右向左，纵向阅读\n组合字符 é 与家庭 👨‍👩‍👧‍👦"
        verticalPreview.font = .systemFont(ofSize: 25, weight: .medium)
        verticalPreview.textColor = UIColor(red: 0.96, green: 0.90, blue: 0.76, alpha: 1)
        verticalPreview.numberOfLines = 0
        verticalPreview.isVerticalForm = true
        verticalPreview.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        verticalPreview.isHidden = true
        stageView.addSubview(verticalPreview)
        configureLabel(hintLabel, text: "逐条进入 · 奇数轨道慢，偶数轨道快。", size: 14, weight: .regular)
        hintLabel.textColor = UIColor(white: 0.40, alpha: 1)
        configureLabel(statusLabel, text: "准备就绪 · 点击开始", size: 13, weight: .medium)
        statusLabel.accessibilityIdentifier = "demo.status"
        configureButton(startButton, title: "开始播放", action: #selector(startBarrage), identifier: "demo.start")
        startButton.backgroundColor = UIColor(red: 0.79, green: 0.28, blue: 0.13, alpha: 1)
        startButton.setTitleColor(.white, for: .normal)
        configureButton(pauseButton, title: "暂停", action: #selector(pauseBarrage), identifier: "demo.pause")
        configureButton(stopButton, title: "停止", action: #selector(stopBarrage), identifier: "demo.stop")
        NotificationCenter.default.addObserver(self, selector: #selector(pauseBarrage), name: UIApplication.willResignActiveNotification, object: nil)
        updateControls()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safe = view.safeAreaInsets
        let width = view.bounds.width
        let height = view.bounds.height
        let left = safe.left + 20
        let usable = width - safe.left - safe.right - 40
        let controlsY = height - safe.bottom - 68
        contentView.frame = CGRect(x: left, y: safe.top, width: usable, height: max(0, controlsY - safe.top - 12))
        introLabel.frame = CGRect(x: 0, y: 12, width: usable, height: 18)
        headingLabel.frame = CGRect(x: 0, y: 35, width: usable, height: 44)
        modeControl.frame = CGRect(x: 0, y: 101, width: usable, height: 40)
        sectionLabel.frame = CGRect(x: 0, y: 165, width: usable, height: 28)
        let stageHeight = max(250, min(360, contentView.bounds.height - 300))
        stageView.frame = CGRect(x: 0, y: 207, width: usable, height: stageHeight)
        barrageManager.renderView.frame = CGRect(x: 0, y: 20, width: usable, height: stageHeight - 40)
        verticalPreview.frame = stageView.bounds
        hintLabel.frame = CGRect(x: 0, y: 223 + stageHeight, width: usable, height: 44)
        statusLabel.frame = CGRect(x: 0, y: 275 + stageHeight, width: usable, height: 24)
        contentView.contentSize = CGSize(width: usable, height: 311 + stageHeight)
        let gap: CGFloat = 10
        let secondary = (usable - gap * 2) * 0.25
        startButton.frame = CGRect(x: left, y: controlsY, width: usable - secondary * 2 - gap * 2, height: 52)
        pauseButton.frame = CGRect(x: startButton.frame.maxX + gap, y: controlsY, width: secondary, height: 52)
        stopButton.frame = CGRect(x: pauseButton.frame.maxX + gap, y: controlsY, width: secondary, height: 52)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopBarrage()
    }
    isolated deinit {
        NotificationCenter.default.removeObserver(self)
        heartbeatTask?.cancel()
        barrageManager.stop()
    }
    @objc func modeChanged() {
        stopBarrage()
        let mode = modeControl.selectedSegmentIndex
        verticalPreview.isHidden = mode != 1
        barrageManager.renderView.isHidden = mode == 1
        sectionLabel.text = ["01  /  自然错峰", "02  /  纵向阅读", "03  /  多样弹幕"][mode]
        hintLabel.text = ["逐条进入 · 奇数轨道慢，偶数轨道快。", "默认竖排容器 · 从右向左排版。此页为静态文字预览。", "文字、图片与礼物动画同场展示。自定义效果可能相互重叠。"][mode]
        updateControls()
    }
    func updateControls() {
        let vertical = modeControl.selectedSegmentIndex == 1
        let status = barrageManager.renderStatus
        let running = status == .started
        startButton.isEnabled = !vertical && !running
        pauseButton.isEnabled = !vertical && running
        stopButton.isEnabled = !vertical && status != .stopped
        startButton.setTitle(status == .paused ? "继续播放" : (running ? "播放中" : "开始播放"), for: .normal)
        for button in [startButton, pauseButton, stopButton] { button.alpha = button.isEnabled ? 1 : 0.45 }
        statusLabel.text = vertical ? "静态预览 · 无需播放" : (running ? "正在播放 · 弹幕持续进入" : (status == .paused ? "已暂停 · 点击继续播放" : "准备就绪 · 点击开始"))
    }
    @objc func startBarrage() {
        guard modeControl.selectedSegmentIndex != 1, barrageManager.renderStatus != .started else { return }
        let resuming = barrageManager.renderStatus == .paused
        view.layoutIfNeeded()
        barrageManager.start()
        if !resuming {
            emissionTick = 0
            emitDemoBarrage()
        }
        heartbeatTask?.cancel()
        let interval: UInt64 = modeControl.selectedSegmentIndex == 0 ? 650_000_000 : 142_857_143
        heartbeatTask = Task { [weak self] in
            while !Task.isCancelled {
                do { try await Task.sleep(nanoseconds: interval) } catch { return }
                guard let self, self.view.window != nil, self.barrageManager.renderStatus == .started else { return }
                self.emissionHeartbeat()
            }
        }
        updateControls()
    }
    func emissionHeartbeat() {
        guard view.window != nil, barrageManager.renderStatus == .started else { return }
        emissionTick += 1
        emitDemoBarrage()
    }
    @objc func pauseBarrage() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
        barrageManager.pause()
        updateControls()
    }
    @objc func stopBarrage() {
        heartbeatTask?.cancel()
        heartbeatTask = nil
        barrageManager.stop()
        emissionTick = 0
        updateControls()
    }
    func emitDemoBarrage() {
        guard barrageManager.renderView.animatingCells.count <= 32 else { return }
        if modeControl.selectedSegmentIndex == 0 {
            let laneCount = min(8, Int(floor(barrageManager.renderView.bounds.height / 40)))
            guard laneCount > 0 else { return }
            let lane = emissionTick % laneCount
            let fast = (lane + 1) % 2 == 0
            let messages = ["慢慢流动", "轻快前行", "保留节奏", "先走一步", "不急不忙", "追上风声", "沿途停留", "轻盈经过"]
            let descriptor = OCBarrageTextDescriptor()
            descriptor.text = String(format: "%02d %@ · %@", lane + 1, fast ? "快" : "慢", messages[lane])
            descriptor.textFont = .systemFont(ofSize: 22, weight: .medium)
            descriptor.textColor = fast ? UIColor(red: 0.67, green: 0.83, blue: 0.79, alpha: 1) : UIColor(red: 0.96, green: 0.87, blue: 0.66, alpha: 1)
            descriptor.fixedSpeed = (fast ? 110 : 60) / (UIScreen.main.scale * 2)
            descriptor.renderRange = NSRange(location: lane * 40, length: (lane + 1) * 40)
            descriptor.barrageCellClass = OCBarrageTextCell.self
            barrageManager.renderBarrageDescriptor(descriptor)
        } else if modeControl.selectedSegmentIndex == 2 {
            let cycle = emissionTick / 7
            switch emissionTick % 7 {
            case 0: addNormalBarrage()
            case 1: addFixedSpeedAnimationCell()
            case 2: addVerticalAnimationCell()
            case 3: if cycle % 2 == 0 { addMixedImageAndTextBarrage() }
            case 4: if cycle % 3 == 0 { addWalkBannerBarrage() }
            case 5: if cycle % 4 == 0 { addGifBarrage() }
            case 6: if cycle % 5 == 0 { addStopoverBarrage() }
            default: break
            }
        }
    }
    private var randomColor: UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
    private func configureText(_ descriptor: OCBarrageTextDescriptor, text: String, cell: OCBarrageCell.Type) {
        descriptor.text = text
        descriptor.textColor = .gray
        descriptor.textFont = .systemFont(ofSize: 17)
        descriptor.strokeColor = UIColor.black.withAlphaComponent(0.3)
        descriptor.strokeWidth = -1
        descriptor.animationDuration = Double(Int.random(in: 5...9))
        descriptor.barrageCellClass = cell
    }
    func addNormalBarrage() {
        let descriptor = OCBarrageTextDescriptor()
        configureText(descriptor, text: "~OCBarrage~", cell: OCBarrageTextCell.self)
        barrageManager.renderBarrageDescriptor(descriptor)
    }
    func addFixedSpeedAnimationCell() {
        let descriptor = OCBarrageGradientBackgroundColorDescriptor()
        configureText(descriptor, text: "~等速弹幕~", cell: OCBarrageGradientBackgroundColorCell.self)
        descriptor.textColor = .white
        descriptor.fixedSpeed = 50
        descriptor.gradientColor = randomColor
        barrageManager.renderBarrageDescriptor(descriptor)
    }
    func addWalkBannerBarrage() {
        let descriptor = OCBarrageWalkBannerDescriptor()
        configureText(descriptor, text: "~欢迎全民超人大驾光临~", cell: OCBarrageWalkBannerCell.self)
        descriptor.textColor = randomColor
        descriptor.positionPriority = .middle
        descriptor.cellTouchedAction = { [weak self] _, cell in
            let alert = UIAlertController(title: "OCBarrage", message: "全民超人为您服务", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "朕知道了", style: .default))
            self?.present(alert, animated: true)
            (cell as? OCBarrageWalkBannerCell)?.textLabel.backgroundColor = .red
        }
        barrageManager.renderBarrageDescriptor(descriptor)
    }
    func addStopoverBarrage() {
        let descriptor = OCBarrageBecomeNobleDescriptor()
        let text = NSMutableAttributedString(string: "~OCBarrage~全民直播~荣誉出品~", attributes: [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 17)])
        text.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 1, length: 9))
        text.addAttribute(.foregroundColor, value: UIColor.cyan, range: NSRange(location: 11, length: 4))
        text.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: 16, length: 4))
        descriptor.attributedText = text
        let midY = barrageManager.renderView.bounds.midY
        descriptor.renderRange = NSRange(location: max(0, Int(midY - 92.5)), length: max(0, Int(midY + 92.5)))
        descriptor.positionPriority = .veryHigh
        descriptor.animationDuration = 4
        descriptor.barrageCellClass = OCBarrageBecomeNobleCell.self
        descriptor.backgroundImage = UIImage(named: "noble_background_image@2x")
        barrageManager.renderBarrageDescriptor(descriptor)
    }
    private func loadImage(_ name: String, type: String, scale: CGFloat) -> YYImage? {
        guard let path = Bundle.main.path(forScaledResource: name, ofType: type), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else { return nil }
        return YYImage(data: data, scale: scale)
    }
    func addMixedImageAndTextBarrage() {
        let descriptor = OCBarrageTextDescriptor()
        if demoIconImage == nil { demoIconImage = loadImage("demoIcon", type: "png", scale: 7) }
        let text = NSMutableAttributedString(string: "")
        for index in 0..<3 {
            let imageView = YYAnimatedImageView(image: demoIconImage)
            let attachment = NSMutableAttributedString.attachmentString(withContent: imageView, contentMode: .center, attachmentSize: imageView.bounds.size, alignTo: .boldSystemFont(ofSize: 25), alignment: .center)
            text.append(attachment)
            if index < 2 { text.append(NSAttributedString(string: "~OCBarrage~", attributes: [.foregroundColor: randomColor])) }
        }
        text.addAttributes([.strokeWidth: -1, .strokeColor: UIColor.black, .font: UIFont.boldSystemFont(ofSize: 25)], range: NSRange(location: 0, length: text.length))
        descriptor.attributedText = text
        descriptor.positionPriority = .high
        descriptor.animationDuration = Double(Int.random(in: 5...9))
        descriptor.barrageCellClass = OCBarrageMixedImageAndTextCell.self
        barrageManager.renderBarrageDescriptor(descriptor)
    }
    func addVerticalAnimationCell() {
        let descriptor = OCBarrageVerticalTextDescriptor()
        configureText(descriptor, text: "~从上往下的动画~", cell: OCBarrageVerticalAnimationCell.self)
        descriptor.animationDuration = 5
        barrageManager.renderBarrageDescriptor(descriptor)
    }
    func addGifBarrage() {
        if demoGifImage == nil { demoGifImage = loadImage("xuanzhuan", type: "gif", scale: 4) }
        let descriptor = OCBarrageGifDescriptor()
        descriptor.image = demoGifImage
        descriptor.positionPriority = .high
        descriptor.animationDuration = Double(Int.random(in: 5...9))
        descriptor.barrageCellClass = OCBarrageGifCell.self
        barrageManager.renderBarrageDescriptor(descriptor)
    }
}
