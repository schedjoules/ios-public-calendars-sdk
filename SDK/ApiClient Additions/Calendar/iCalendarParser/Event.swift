//
//  Event.swift
//  iCalendarParser
//
//  Created by Balazs Vincze on 2018. 02. 16..
//  Copyright © 2018. SchedJoules. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public final class Event {
    public var startDate: Date!
    public var endDate: Date?
    public var description: String!
    public var summary: String!
    public var location: String!
    public var isAllDay: Bool!
    
    private func isDateAllDay(line: ParsedLine) -> Bool {
        guard let params = line.params else {
            print("No parameters")
            return false
        }
        guard let value = params["VALUE"] else {
            print("No value parameter")
            return false
        }
        if value == "DATE" {
            return true
        }
        return false
    }
    
    private func dateFrom(parsedLine: ParsedLine) -> Date {
        let dateFormatter = DateFormatter()
        if isDateAllDay(line: parsedLine){
            dateFormatter.dateFormat = "yyyyMMdd"
        } else {
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        }
        return dateFormatter.date(from: parsedLine.value)!
    }
    
    private func getLineFor(key: String, in lines: [ParsedLine]) -> ParsedLine?{
        for line in lines{
            if line.key == key{
                return line
            }
        }
        return nil
    }
    
    public required init(with parsedLines: [ParsedLine]) {
        summary = getLineFor(key: "SUMMARY", in: parsedLines)?.value
        description = getLineFor(key: "DESCRIPTION", in: parsedLines)?.value.replacingOccurrences(of: "\\n", with: "\n")
        location = getLineFor(key: "LOCATION", in: parsedLines)?.value
        startDate = dateFrom(parsedLine: getLineFor(key: "DTSTART", in: parsedLines)!)
        if let endDateLine = getLineFor(key: "DTEND", in: parsedLines) {
            endDate = dateFrom(parsedLine: endDateLine)
        }
        isAllDay = isDateAllDay(line: getLineFor(key: "DTSTART", in: parsedLines)!)
    }
    
}
