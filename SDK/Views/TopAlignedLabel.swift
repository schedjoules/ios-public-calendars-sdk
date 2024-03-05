//
//  TopAlignedLabel.swift
//  iOS-SDK
//
//  Created by Irmak Ozonay on 5.03.2024.
//  Copyright © 2024 SchedJoules. All rights reserved.
//

import Foundation
import UIKit

final class TopAlignedLabel: UILabel {
  override func drawText(in rect: CGRect) {
    super.drawText(in: .init(
      origin: .zero,
      size: textRect(
        forBounds: rect,
        limitedToNumberOfLines: numberOfLines
      ).size
    ))
  }
}
