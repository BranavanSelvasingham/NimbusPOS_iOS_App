//
//  EmployeeListTableViewCell.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-02-23.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import UIKit

class EmployeeListTableViewCell: UITableViewCell {
    var employee: Employee? {
        didSet {
            refreshLabels()
        }
    }
    
    var employeeNameField: UILabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(employee: Employee){
        self.employee = employee
    }
    
    func refreshLabels(){
        self.textLabel?.text = employee?.name ?? ""
    }

}
