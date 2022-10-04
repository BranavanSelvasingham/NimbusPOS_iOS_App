//
//  DateExtension.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-09.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation

extension Date {
    func convertFromISOString(isoDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:isoDate)
        if let date = date{
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            let finalDate = calendar.date(from:components)
        
            return finalDate
        }
        return nil
    }
    
    func convertToISOString()->String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.string(from: self)
    }
    
    func toFormattedString (includeTime: Bool = true, longDate: Bool = false) -> String {
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
        
        return dateFormatter.string(from: self)
    }
    
    var year: Int {
        get {
            let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
            let currentYearInt = (calendar?.component(NSCalendar.Unit.year, from: self))!
            return currentYearInt
        }
    }
    
    var month: Int { //***** Month returns with Scale of 0 to 11
        get {
            let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
            let currentMonthInt = (calendar?.component(NSCalendar.Unit.month, from: self))!
            return currentMonthInt - 1
        }
    }
    
    var day: Int {
        get {
            let calendar = NSCalendar.init(calendarIdentifier: NSCalendar.Identifier.gregorian)
            let currentDayInt = (calendar?.component(NSCalendar.Unit.day, from: self))!
            return currentDayInt
        }
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
}


extension DateFormatter{
    static var iso8601UTC: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }
}
