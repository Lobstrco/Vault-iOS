import Foundation
import UIKit

struct HomeHelper {
  
  func createSignerDetailsViewForMultipleAddresses(in parentView: UIView, for numberOfAccounts: String, bottomAnchor: NSLayoutYAxisAnchor) {
    let numberOfAccountsLabel = UILabel()
    numberOfAccountsLabel.text = numberOfAccounts
    numberOfAccountsLabel.textColor = Asset.Colors.main.color
    numberOfAccountsLabel.font = UIFont.boldSystemFont(ofSize: 40)
    parentView.addSubview(numberOfAccountsLabel)
    numberOfAccountsLabel.translatesAutoresizingMaskIntoConstraints = false
    numberOfAccountsLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: 6).isActive = true
    numberOfAccountsLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
    
    let accountsTitleLabel = UILabel()
    accountsTitleLabel.text = "accounts"
    accountsTitleLabel.textColor = Asset.Colors.grayOpacity30.color
    accountsTitleLabel.font = UIFont.systemFont(ofSize: 15)
    
    parentView.addSubview(accountsTitleLabel)
    
    accountsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    accountsTitleLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
    accountsTitleLabel.topAnchor.constraint(equalTo: numberOfAccountsLabel.bottomAnchor, constant: 5).isActive = true
  }
  
  func createSignerDetailsViewForSingleAddress(in parentView: UIView, address: String, bottomAnchor: NSLayoutYAxisAnchor) {
    let signedAccountLabel = UILabel()
    signedAccountLabel.textColor = Asset.Colors.grayOpacity30.color
    signedAccountLabel.font = UIFont.systemFont(ofSize: 15)
    signedAccountLabel.text = address
//    signedAccountLabel.setLineHeight(lineHeight: 15)
    signedAccountLabel.textAlignment = .center
    signedAccountLabel.numberOfLines = 2
    
    parentView.addSubview(signedAccountLabel)
    
    signedAccountLabel.translatesAutoresizingMaskIntoConstraints = false
    signedAccountLabel.topAnchor.constraint(equalTo: bottomAnchor, constant: 10).isActive = true
    signedAccountLabel.widthAnchor.constraint(equalToConstant: 315).isActive = true
    signedAccountLabel.centerXAnchor.constraint(equalTo: parentView.centerXAnchor).isActive = true
  }
}
