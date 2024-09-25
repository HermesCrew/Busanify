//
//  String+Extension.swift
//  Busanify
//
//  Created by MadCow on 2024/9/24.
//

import UIKit

extension String {
    
    func truncate(to length: Int, addEllipsis: Bool = true) -> String {
        guard self.count > length else { return self }
        
        let truncated = self.prefix(length)
        return addEllipsis ? truncated + "..." : String(truncated)
    }
}
