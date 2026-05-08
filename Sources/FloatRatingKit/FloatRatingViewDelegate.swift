
import UIKit

@objc public protocol FloatRatingViewDelegate: AnyObject {

    /// Called when rating update completed
    @objc optional func floatRatingView(
        _ ratingView: FloatRatingView,
        didUpdate rating: Double
    )

    /// Called while updating rating
    @objc optional func floatRatingView(
        _ ratingView: FloatRatingView,
        isUpdating rating: Double
    )
}
