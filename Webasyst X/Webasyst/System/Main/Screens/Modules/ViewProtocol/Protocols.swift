//
//  Protocols.swift
//  CRM
//
//  Created by Леонид Лукашевич on 02.06.2023.
//

import Foundation

@objc protocol ViewProtocol {}

@objc protocol AddAccountProtocol: ViewProtocol {}
@objc protocol InstallProtocol: ViewProtocol {}

@objc protocol LoadingProtocol: ViewProtocol {}
@objc protocol ErrorProtocol: ViewProtocol {}
@objc protocol EmptyProtocol: ViewProtocol {}
@objc protocol AccessDeniedProtocol: ViewProtocol {}
