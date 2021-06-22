//
//  OrderViewCell.swift
//  WebXApp
//
//  Created by Виктор Кобыхно on 1/27/21.
//

import UIKit

class OrderViewCell: UITableViewCell {

    @IBOutlet weak var numberOrderLabel: UILabel!
    @IBOutlet weak var statusOrderLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deliveryTypeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    func configureCell(_ order: Orders) {
        self.numberOrderLabel?.text = order.idEncoded
        switch order.stateId {
        case .new:
            self.statusOrderLabel?.text = NSLocalizedString("newOrder", comment: "")
        case .shipped:
            self.statusOrderLabel?.text = NSLocalizedString("shippedOrder", comment: "")
        case .completed:
            self.statusOrderLabel?.text = NSLocalizedString("completedOrder", comment: "")
        case .refuned:
            self.statusOrderLabel?.text = NSLocalizedString("refunedOrder", comment: "")
        case .unknown(value: _):
            self.statusOrderLabel?.text = NSLocalizedString("unknownOrder", comment: "")
        }
        self.priceLabel?.text =  "\(String(format: "%.1f", Double(order.total) ?? 0)) \(order.currency)"
        self.deliveryTypeLabel?.text = order.params.shippingName
    }
    
}
