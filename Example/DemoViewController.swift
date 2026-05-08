//
//  DemoViewController.swift
//  FloatRatingKit
//
//  Created by Vishal Vaghasiya on 08/05/26.
//

import UIKit
import FloatRatingKit

final class DemoViewController: UIViewController {

    private let ratingView = FloatRatingView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        ratingView.frame = CGRect(
            x: 40,
            y: 200,
            width: 250,
            height: 50
        )

        ratingView.emptyImage =
            UIImage(systemName: "star")

        ratingView.fullImage =
            UIImage(systemName: "star.fill")

        ratingView.type = .halfRatings
        ratingView.rating = 3.5

        view.addSubview(ratingView)
    }
}
