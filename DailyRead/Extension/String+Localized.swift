//
//  String+Localized.swift
//  DailyRead
//
//  Created by 王克旭 on 2023/2/28.
//

import Foundation
extension String {
    func localized() -> String {
      return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
  }
}
