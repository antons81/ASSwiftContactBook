//
//  ContactHeader.swift
//  ASContactBook
//
//  Created by Anton Stremovskiy on 7/12/17.
//  Copyright © 2017 áSoft. All rights reserved.
//

import UIKit
import MessageUI

open class ContactHeader: UIView {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileDescription: UILabel!
    
    @IBOutlet weak var callButton: ActionButton!
    @IBOutlet weak var chatButton: ActionButton!
    @IBOutlet weak var mailButton: ActionButton!
    
    var contact: Contact!

    func setupHeader(_ contact: Contact) {
        
        let bundle              = Bundle(for: ASContactPicker.self)
        self.contact            = contact
        profileImage.image      = contact.thumb ?? UIImage(named: "person", in: bundle, compatibleWith: nil)
        profileName.text        = contact.firstName + " " + contact.lastName
        profileDescription.text = contact.jobTitle + "\n\n" + contact.organization
        setupButtons()
    }
    
    func setupButtons() {
        callButton.subtitleType = .phone
        chatButton.subtitleType = .message
        mailButton.subtitleType = .email
    }
    
    @IBAction func actionTap(_ button: ActionButton) {
        
        switch button.subtitleType {
        case .phone:
            showAlertController(contact.phones, subtype: button.subtitleType)
        case .message:
            var allData = [String]()
            allData.append(contentsOf: contact.phones)
            allData.append(contentsOf: contact.emails)
            showAlertController(allData, subtype: button.subtitleType)
        case .email:
            showAlertController(contact.emails, subtype: button.subtitleType)
        default:
            break
        }
       
    }
    
    fileprivate func sendMessage(_ contact: String) {
        
        if MFMessageComposeViewController.canSendText() {
            let messageVC = MFMessageComposeViewController()
            messageVC.recipients = [contact]
            messageVC.messageComposeDelegate = self
            presentController(messageVC)
        }
    }
    
    fileprivate func sendEmail(_ contact: String) {
        
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.setToRecipients([contact])
            mailVC.mailComposeDelegate = self
            presentController(mailVC)
        }
    }
    
    fileprivate func openCallUrl(_ contact: String) {
        let num = contact.digits.hasPrefix("+") ? contact.digits : "+" + contact.digits
        if let url = URL(string: "tel://\(num)"), UIApplication.shared.canOpenURL(url) {
            openURL(url)
        }
    }

    fileprivate func presentController(_ controller: UIViewController) {
        if let vc = UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController {
            vc.present(controller, animated: true, completion: nil)
        }
    }
    
    private func openURL(_ url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func showAlertController(_ data: [String], subtype: SubtitleType) {
        
        let actionSheet = UIAlertController(title: "Make your choose", message: nil, preferredStyle: .actionSheet)
        for contact in data {
            let action = UIAlertAction(title: contact, style: .default, handler: { _ in
                
                switch subtype {
                case .phone:
                    self.openCallUrl(contact.digits)
                case .email:
                    self.sendEmail(contact)
                case .message:
                    self.sendMessage(contact)
                default:
                    break
                }
            })
            
            actionSheet.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
       
        if let vc = UIApplication.shared.delegate?.window??.rootViewController?.presentedViewController {
            vc.present(actionSheet, animated: true, completion: nil)
        }
    }
}


extension ContactHeader: MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    public func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                             didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
    }
}


