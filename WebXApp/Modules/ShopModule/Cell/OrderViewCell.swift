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
    @IBOutlet weak var summOrderTitle: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deliveryTypeLabel: UILabel!
    @IBOutlet weak var deliveryDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        summOrderTitle?.text = "\(NSLocalizedString("orderSummTitle", comment: "")):"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(_ order: Orders) {
        self.numberOrderLabel?.text = "\(NSLocalizedString("orderNumberTitle", comment: "")): \(order.idEncoded)"
        switch order.stateId {
        case .new:
            self.statusOrderLabel?.text = "\(NSLocalizedString("orderStatusTitle", comment: "")): \(NSLocalizedString("newOrder", comment: ""))"
        case .shipped:
            self.statusOrderLabel?.text = "\(NSLocalizedString("orderStatusTitle", comment: "")): \(NSLocalizedString("shippedOrder", comment: ""))"
        case .completed:
            self.statusOrderLabel?.text = "\(NSLocalizedString("orderStatusTitle", comment: "")): \(NSLocalizedString("completedOrder", comment: ""))"
        case .refuned:
            self.statusOrderLabel?.text = "\(NSLocalizedString("orderStatusTitle", comment: "")): \(NSLocalizedString("refunedOrder", comment: ""))"
        case .unknown(value: _):
            self.statusOrderLabel?.text = "\(NSLocalizedString("orderStatusTitle", comment: "")): \(NSLocalizedString("unknownOrder", comment: ""))"
        }
        self.priceLabel?.text =  "\(String(format: "%.1f", Double(order.total) ?? 0)) \(order.currency)"
        self.deliveryTypeLabel?.text = order.params.shippingName
        self.deliveryDateLabel?.text = order.params.shippingEstDelivery
    }
    
}
