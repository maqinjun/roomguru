//
//  CalendarPickerViewModel.swift
//  Roomguru
//
//  Created by Patryk Kaczmarek on 02/04/15.
//  Copyright (c) 2015 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

private class PickerCalendar {
    var isSelected: Bool = false
    let calendar: Calendar
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
}

class CalendarPickerViewModel {

    private let calendars: [PickerCalendar]
    
    init(calendars: [Calendar]) {
        var array: [PickerCalendar] = []
        for calendar in calendars {
            let pickerCalendar = PickerCalendar(calendar: calendar)
            pickerCalendar.isSelected = CalendarPersistenceStore.sharedStore.isCalendarPersisted(calendar)
            array += [pickerCalendar]
        }
        self.calendars = array
    }
    
    // MARK: Public
    
    func selectOrDeselectCalendarAtIndex(index: Int) {
        let calendar = calendars[index]
        calendar.isSelected = !calendar.isSelected
    }
    
    func shouldSelectCalendarAtIndex(index: Int) -> Bool {
        return calendars[index].isSelected
    }
    
    func shouldProcceed() -> Bool {
        return !self.calendars.filter { $0.isSelected }.isEmpty
    }
    
    func count() -> Int {
        return calendars.count
    }
    
    func saveNameForCalendarAtIndex(index: Int, name: String?) {
        calendars[index].calendar.name = name
    }
    
    func save() {
        let array = calendars.filter{ $0.isSelected }.map { $0.calendar }
        CalendarPersistenceStore.sharedStore.saveCalendars(array)
    }
    
    func resetCustomCalendarNameAtIndex(index: Int) {
        calendars[index].calendar.name = nil
    }
    
    func hasCalendarAtIndexCustomizedName(index: Int) -> Bool {
        return calendars[index].calendar.name != nil
    }
    
    func textForCalendarAtIndex(index: Int) -> (mainText: String?, detailText: String?) {
        
        let picker = calendars[index]
        
        let placeholder = NSLocalizedString("Not change yet", comment: "")
        let mainText = picker.calendar.name ?? picker.calendar.summary
        var detailText = (picker.calendar.name != nil) ? picker.calendar.summary : placeholder
        
        if (detailText != nil) && (detailText != placeholder) {
            detailText = NSLocalizedString("was: ", comment: "") + detailText!
        }
        return (mainText, detailText)
    }
}