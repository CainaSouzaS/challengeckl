//
//  Article.swift
//  Challenge
//
//  Created by Cainã Souza on 9/4/14.
//  Copyright (c) 2014 Caina Souza. All rights reserved.
//

import Foundation
import CoreData

class Article: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var authors: String
    @NSManaged var date: NSDate
    @NSManaged var website: String

}
