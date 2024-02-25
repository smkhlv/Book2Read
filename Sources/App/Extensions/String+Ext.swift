//
//  String+Ext.swift
//
//
//  Created by Igoryok on 22.02.2024.
//

import Foundation

extension String {
    var fileNameWithoutExtension: String { URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent }
    var fileExtension: String { URL(fileURLWithPath: self).pathExtension }
}
