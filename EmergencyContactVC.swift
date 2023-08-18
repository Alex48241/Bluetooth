//
//  EmergencyContactVC.swift
//  VitalApp
//
//  Created by Ninehertz.  on 15/03/22.
//

import UIKit
import ContactsUI

class EmergencyContactVC: UIViewController {
    
    @IBOutlet weak var collEmerg:UICollectionView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var viewBlur:UIView!
    
    var arrEmergencyContact = [UserHome]()
    var aws_Url = ""
    
    
    
    let margin: CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emergency Contacts"
        guard let collectionView = collEmerg, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
            flowLayout.minimumInteritemSpacing = margin
            flowLayout.minimumLineSpacing = margin
            flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        viewBlur.updateLayerProperties()
        //viewBlur.dropShadow(color: .lightGray, opacity: 0.5, offSet: CGSize.zero, radius: 2, scale: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blurEffect.isHidden = true
        getEmergencyContact()
    }
    
    @IBAction func btnInfo(_ sender: Any) {
        blurEffect.isHidden = false
    }
    

    @IBAction func closeTap(_ sender: Any) {
        blurEffect.isHidden = true
    }
    
    @objc func addContact() {
        if  arrEmergencyContact.count < 4 {
            let cnPicker = CNContactPickerViewController()
            cnPicker.delegate = self
            self.present(cnPicker, animated: true, completion: nil)
        }else {
            SubscriptionService.shared.subscriptionStatus = nil
            SubscriptionService.shared.verifySubscriptions { [weak self] (status , productId) in
                if status == SubscriptionStatus.purchased {
                    let cnPicker = CNContactPickerViewController()
                    cnPicker.delegate = self
                    self?.present(cnPicker, animated: true, completion: nil)
                }else{
                    self?.showLogoutAlert(withTitle: "Upgrade to Vital Guard ER", message: "To unlock 24/7\nEmergency Life Rescue", cancelButtonTitle: "Close", logoutButtonTitle: "Upgrade") {
                        
                    } logoutButtonPostHandler: {
                        let vc = kMainStoryboard.instantiateViewController(identifier: "subscriptionVC")as! subscriptionVC
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func getEmergencyContact() {
        guard Reachability.isConnectedToNetwork() else {
            self.showMessageToUser(title: AppConstant, msg: "Internet is not connected.")
            return
        }
        WebService.performGetApiList(isShowHud: true, urlString: "\(BASE_URL)users/viewcontact") { response, error in
            
           let responseJSON = response?.value as! [String : Any]
           let json: NSDictionary = responseJSON as NSDictionary
                
            if json ["success"] as! Bool {
                let dic = Helper.jsonToData(json: (json.value(forKey: "data") as! NSDictionary))
                do {
                    let decoder = JSONDecoder()
                    let model1 = try decoder.decode(EmergencyConatact.self, from: dic!)
                    self.arrEmergencyContact = model1.emergency
                    self.aws_Url = (json.value(forKey: "data") as! NSDictionary).value(forKey: "aws_url") as? String ?? ""
                    self.collEmerg.reloadData()
                } catch let parsingError {
                    print("Error", parsingError)
                }
            }
            else {
                self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
            }
        }
    }
}

extension EmergencyContactVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrEmergencyContact.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == arrEmergencyContact.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmergencyConatct", for: indexPath) as! AddEmergencyConatct
            cell.btnAdd.addTarget(self, action: #selector(addContact), for: .touchUpInside)
            return cell
        }
        
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmergencyCell", for: indexPath) as! EmergencyCell
            cell.lblEmergency.text = arrEmergencyContact[indexPath.row].name
            
            if arrEmergencyContact[indexPath.row].avatar != nil {
                cell.imgEmergency.downloadImage(UrlString: aws_Url + arrEmergencyContact[indexPath.row].avatar!)
            }
            
            return cell
        }
        
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let noOfCellsInRow = 3   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: size)
    }

    
    
}


//MARK:- CNContactPickerDelegate Method

extension EmergencyContactVC:CNContactPickerDelegate{
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let phoneNumber = contact.phoneNumbers
        print("number is = \(phoneNumber)")
        let vc = kMainStoryboard.instantiateViewController(identifier: "AddMemeberVC") as! AddMemeberVC
        vc.member = contact
        navigationController?.pushViewController(vc, animated: false)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        
        
        print("Cancel Contact Picker")
    }
}
