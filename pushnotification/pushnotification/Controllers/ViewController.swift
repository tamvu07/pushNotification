//
//  ViewController.swift
//  pushnotification
//
//  Created by Vu Minh Tam on 6/26/21.
//

import UIKit

import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var image1: ImageLoader!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //
        //https://stackoverflow.com/questions/53624466/urlcache-ios-storecachedresponse-works-asynchronously-how-to-catch-the-compl
        //https://stackoverflow.com/questions/32242148/best-way-to-cache-json-from-api-in-swift
        
//        AF.request("https://api.androidhive.info/volley/person_array.json", encoding: JSONEncoding.default)
//                .responseJSON { response in
//                   print(response.response?.statusCode)
//                    switch response.result {
//                    case .success:
//                        if let data = response.value as? [Any] {
//                            for d in data as? [Any]  ?? []{
//                                if let json = d as? [String: Any]  {
//                                    let arrphone = json["phone"] as? [String: Any] ?? [:]
//                                    print("mobile: \(arrphone["mobile"])")
//                                }
//                            }
//
//                        }
//                    case .failure(let error):
//                        print(error)
//                    }
//            }
        
        //
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("")
    }
    
    @IBAction func callAPI(_ sender: Any) {
        MediageApiManager.shareInstance.downloadContent(fromUrlString: "http://demo.aris-vn.com:7010/api/information", completionHandler: { (result) in

            switch result {
            case .success(let data):
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                for arr in json as? [Any] ?? [] {
                    if let value = arr as? [String: Any] {
                        let name = value["name"] as? String ?? ""
                        print("name:\(name) ")
                    }
                }
                break
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        })
        
        
//        MediageApiManager.shareInstance.downloadContent(fromUrlString: "http://mediage:mediage@mediage-app.sakura.ne.jp/api/customer/CT6fXV0iaSxkymUIl1ePycB4QLPARoXsMwUBaXYN", completionHandler: { (result) in
//
//            switch result {
//            case .success(let data):
//                let json = try? JSONSerialization.jsonObject(with: data, options: [])
//                if let j = json as? [String: Any] {
//                    let status = j["status"] as? Int
//                    print("status: \(status)")
//                }
//                break
//            case .failure(let error):
//                debugPrint(error.localizedDescription)
//            }
//        })
        
        if let urlImge = URL(string: "http://mediage-app.sakura.ne.jp/storage/mainview.png") {
            image1.loadImageWithUrl(urlImge)
        }
        
        
        
        
    }
    
    @IBAction func deleteCache(_ sender: Any) {
        MediageApiManager.shareInstance.clearCache()
    }
    

    @IBAction func goToLine(_ sender: Any) {
        
//        let url = URL(string: "line://ti/p/@UserlineID")!
//        let url = URL(string: "line://ti/p/@gwd8622t")!
        // chuyên đến add firend
//        let url = URL(string: "line://oaMessage/@lineteamjp")!
//        let url = URL(string: "https://line.me/R/oaMessage/@lineteamjp")!
        // tự add firend sau đó đến chat
//        let url = URL(string: "https://line.me/R/oaMessage/@gwd8622t")!
//        if UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//            //If you want handle the completion block than
//            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
//                 print("Open url : \(success)")
//            })
//        } else {
//            if let url = URL(string: "itms-apps://apple.com/app/id839686104") {
//                UIApplication.shared.open(url)
//            }
//        }
        checkAndOpenApp()
        
    }
    
    @IBAction func goToPhone(_ sender: Any) {
        dialNumber(number: "19003090")
    }
    
    @IBAction func goToEmail(_ sender: Any) {
//        let email = "vuminhtam.sdb2@gmail.com"
//        if let url = URL(string: "mailto:\(email)") {
//          if #available(iOS 10.0, *) {
//            UIApplication.shared.open(url)
//          } else {
//            UIApplication.shared.openURL(url)
//          }
//        }
        if let url = URL(string: "https://www.mediage.co.jp/aoyamainq/index.php") {
            UIApplication.shared.open(url)
        }
    }
    
    //100010307837623
    func checkAndOpenApp(){
        let app = UIApplication.shared
        let appScheme = "line://app"
        if app.canOpenURL(URL(string: appScheme)!) {
            print("App is install and can be opened")
            let url = URL(string: "https://line.me/R/ti/p/%40xat.0000131396.fyi")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            print("App in not installed. Go to AppStore")
            if let url = URL(string: "https://apps.apple.com/us/app/App1/id1445847940?ls=1"),
                UIApplication.shared.canOpenURL(url)
            {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    func dialNumber(number: String) {

     if let url = URL(string: "tel://\(number)"),
       UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler:nil)
           } else {
               UIApplication.shared.openURL(url)
           }
       } else {
                // add error message here
       }
    }
    
    @IBAction func goTosafari(_ sender: Any) {
        
        if let url = URL(string: "https://www.mediage.co.jp") {
            UIApplication.shared.open(url)
        }
    }
    

}

