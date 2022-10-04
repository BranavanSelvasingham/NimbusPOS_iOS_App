//
//  NSDateExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension NSDate {
    func toFormattedString (includeTime: Bool = true, longDate: Bool = false) -> String {
        let selfDate = self as Date
        let dateFormatter = DateFormatter()
        
        var formatString = ""
        
        if longDate {
            formatString = "dd-MMM-yyyy"
        } else {
            formatString = "dd-MMM"
        }
        
        if includeTime {
            formatString = formatString + " | h:mm a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
        }
        
        dateFormatter.dateFormat = formatString
        
        return dateFormatter.string(from: selfDate)
    }
    
    func toTimeStringOnly(timeStyle: DateFormatter.Style) -> String{
        return DateFormatter.localizedString(from: self as! Date, dateStyle: .none, timeStyle: timeStyle)
    }
    
    func toDateStringWithoutTime(dateStyle: DateFormatter.Style) -> String{
        return DateFormatter.localizedString(from: self as! Date, dateStyle: dateStyle, timeStyle: .none)
    }
    
    func toDateStringWithTime(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style) -> String{
        return DateFormatter.localizedString(from: self as! Date, dateStyle: dateStyle, timeStyle: timeStyle)
    }
}
