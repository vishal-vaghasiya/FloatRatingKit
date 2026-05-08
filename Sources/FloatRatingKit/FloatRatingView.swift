import UIKit

@IBDesignable
@objcMembers
open class FloatRatingView: UIView {

    // MARK: - Properties

    open weak var delegate: FloatRatingViewDelegate?

    private var emptyImageViews: [UIImageView] = []
    private var fullImageViews: [UIImageView] = []

    // MARK: - Images

    @IBInspectable
    open var emptyImage: UIImage? {
        didSet {
            emptyImageViews.forEach {
                $0.image = emptyImage
            }
            refresh()
        }
    }

    @IBInspectable
    open var fullImage: UIImage? {
        didSet {
            fullImageViews.forEach {
                $0.image = fullImage
            }
            refresh()
        }
    }

    open var imageContentMode: UIView.ContentMode = .scaleAspectFit

    // MARK: - Rating

    @IBInspectable
    open var minRating: Int = 0 {
        didSet {
            if rating < Double(minRating) {
                rating = Double(minRating)
            }
        }
    }

    @IBInspectable
    open var maxRating: Int = 5 {
        didSet {
            guard maxRating != oldValue else {
                return
            }

            removeImageViews()
            setupImageViews()

            setNeedsLayout()
            refresh()
        }
    }

    @IBInspectable
    open var minImageSize: CGSize = CGSize(
        width: 5,
        height: 5
    )

    @IBInspectable
    open var rating: Double = 0 {
        didSet {
            if rating != oldValue {
                refresh()
            }
        }
    }

    @IBInspectable
    open var editable: Bool = true

    // MARK: - Rating Type

    @objc
    public enum FloatRatingViewType: Int {
        case wholeRatings
        case halfRatings
        case floatRatings

        func supportsFractions() -> Bool {
            return self == .halfRatings || self == .floatRatings
        }
    }

    @IBInspectable
    open var type: FloatRatingViewType = .wholeRatings

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageViews()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageViews()
    }

    // MARK: - Setup

    private func setupImageViews() {

        guard emptyImageViews.isEmpty,
              fullImageViews.isEmpty else {
            return
        }

        for _ in 0..<maxRating {

            let emptyImageView = UIImageView()
            emptyImageView.contentMode = imageContentMode
            emptyImageView.image = emptyImage
            addSubview(emptyImageView)

            emptyImageViews.append(emptyImageView)

            let fullImageView = UIImageView()
            fullImageView.contentMode = imageContentMode
            fullImageView.image = fullImage
            addSubview(fullImageView)

            fullImageViews.append(fullImageView)
        }
    }

    private func removeImageViews() {

        emptyImageViews.forEach {
            $0.removeFromSuperview()
        }

        fullImageViews.forEach {
            $0.removeFromSuperview()
        }

        emptyImageViews.removeAll()
        fullImageViews.removeAll()
    }

    // MARK: - Refresh

    private func refresh() {

        for i in 0..<fullImageViews.count {

            let imageView = fullImageViews[i]

            if rating >= Double(i + 1) {

                imageView.layer.mask = nil
                imageView.isHidden = false

            } else if rating > Double(i),
                      rating < Double(i + 1) {

                let maskLayer = CALayer()

                maskLayer.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: CGFloat(rating - Double(i)) * imageView.frame.width,
                    height: imageView.frame.height
                )

                maskLayer.backgroundColor = UIColor.black.cgColor

                imageView.layer.mask = maskLayer
                imageView.isHidden = false

            } else {

                imageView.layer.mask = nil
                imageView.isHidden = true
            }
        }
    }

    // MARK: - Layout

    override open func layoutSubviews() {

        super.layoutSubviews()

        guard let emptyImage else {
            return
        }

        let desiredImageWidth =
            frame.width / CGFloat(emptyImageViews.count)

        let maxImageWidth =
            max(minImageSize.width, desiredImageWidth)

        let maxImageHeight =
            max(minImageSize.height, frame.height)

        let imageViewSize = sizeForImage(
            emptyImage,
            inSize: CGSize(
                width: maxImageWidth,
                height: maxImageHeight
            )
        )

        let imageXOffset =
        (frame.width -
         (imageViewSize.width * CGFloat(emptyImageViews.count)))
        /
        CGFloat((emptyImageViews.count - 1))

        for i in 0..<maxRating {

            let imageFrame = CGRect(
                x: i == 0
                ? 0
                : CGFloat(i) * (imageXOffset + imageViewSize.width),
                y: 0,
                width: imageViewSize.width,
                height: imageViewSize.height
            )

            emptyImageViews[i].frame = imageFrame
            fullImageViews[i].frame = imageFrame
        }

        refresh()
    }

    // MARK: - Helpers

    private func sizeForImage(
        _ image: UIImage,
        inSize size: CGSize
    ) -> CGSize {

        let imageRatio =
            image.size.width / image.size.height

        let viewRatio =
            size.width / size.height

        if imageRatio < viewRatio {

            let scale =
                size.height / image.size.height

            let width =
                scale * image.size.width

            return CGSize(
                width: width,
                height: size.height
            )

        } else {

            let scale =
                size.width / image.size.width

            let height =
                scale * image.size.height

            return CGSize(
                width: size.width,
                height: height
            )
        }
    }

    private func updateLocation(_ touch: UITouch) {

        guard editable else {
            return
        }

        let touchLocation = touch.location(in: self)

        var newRating: Double = 0

        for i in stride(
            from: (maxRating - 1),
            through: 0,
            by: -1
        ) {

            let imageView = emptyImageViews[i]

            guard touchLocation.x > imageView.frame.origin.x else {
                continue
            }

            let newLocation =
                imageView.convert(
                    touchLocation,
                    from: self
                )

            if imageView.point(
                inside: newLocation,
                with: nil
            ) && type.supportsFractions() {

                let decimalNum =
                    Double(newLocation.x / imageView.frame.width)

                newRating = Double(i) + decimalNum

                if type == .halfRatings {

                    newRating =
                    Double(i)
                    +
                    (
                        decimalNum > 0.75
                        ? 1
                        : (
                            decimalNum > 0.25
                            ? 0.5
                            : 0
                        )
                    )
                }

            } else {

                newRating = Double(i) + 1.0
            }

            break
        }

        rating =
            newRating < Double(minRating)
            ? Double(minRating)
            : newRating

        delegate?.floatRatingView?(
            self,
            isUpdating: rating
        )
    }

    // MARK: - Touches

    override open func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard let touch = touches.first else {
            return
        }

        updateLocation(touch)
    }

    override open func touchesMoved(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        guard let touch = touches.first else {
            return
        }

        updateLocation(touch)
    }

    override open func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        delegate?.floatRatingView?(
            self,
            didUpdate: rating
        )
    }

    override open func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {

        delegate?.floatRatingView?(
            self,
            didUpdate: rating
        )
    }
}
