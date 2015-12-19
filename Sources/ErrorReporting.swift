//
//  ErrorReporting.swift
//  Targone
//
//  Created by Marco Conti on 19/12/15.
//  Copyright © 2015 Marco. All rights reserved.
//

import Foundation


public struct ErrorReporting
{
    /// Return code that the process will return in case of error
    public static let ReturnCodeForUnrecoverableError : Int32 = 2
    
    /// Prints out the error and exists with status 'ReturnCodeForUnrecoverableError'
    /// - SeeAlso: CustomErrorReportingHandler
    @noreturn static func die(error: Any...)  {
        let errorString = error.map { String($0) }.joinWithSeparator(" ")
        print("Fatal Targone usage error in script: ", errorString)
        exit(ReturnCodeForUnrecoverableError)
    }
}