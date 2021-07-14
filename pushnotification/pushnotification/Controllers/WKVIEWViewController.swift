//
//  WKVIEWViewController.swift
//  pushnotification
//
//  Created by Vu Minh Tam on 7/9/21.
//

import UIKit
import WebKit
import WebArchiver

class WKVIEWViewController: UIViewController {
    
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var archiveURL = URL(string: "")
    var popup: Popup? = nil
    var toolbar = ToolbarState()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadURL(urlStr: "https://www.mediage.co.jp")
        webView.navigationDelegate = self
        
        // import 2 thu vien ơ trong File-> Swift packages -> Add package dependency
        // https://github.com/cezheng/Fuzi
        //https://github.com/ernesto-elsaesser/WebArchiver
        // để chạy webview ofline thì cần 2 thư viên đó.
    }
    
    func loadURL(urlStr: String) {
        if let url = URL(string: urlStr) {
            self.archiveURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("cached").appendingPathExtension("webarchive")
            
            self.spinner.startAnimating()
            self.webView.addObserver(toolbar, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
            
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    func archive() {
        guard let url = webView.url else {
            return
        }
        
        toolbar.loading = true
        
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            
            WebArchiver.archive(url: url, cookies: cookies) { [self] result in
                
                if let data = result.plistData {
                    do {
                        try data.write(to: self.archiveURL!)
                        self.popup = .archiveCreated
                        self.alert()
                    } catch {
                        self.popup = .achivingFailed(error: error)
                        self.alert()
                    }
                } else if let firstError = result.errors.first {
                    self.popup = .achivingFailed(error: firstError)
                    self.alert()
                }
                
                self.toolbar.loading = false
            }
        }
    }
   
    func unarchive() {
        if FileManager.default.fileExists(atPath: archiveURL!.path) {
            webView.loadFileURL(archiveURL!, allowingReadAccessTo: archiveURL!)
        } else {
            self.popup = .noArchive
            self.alert()
        }
    }
    
    func alert() {
        let alert = UIAlertController(title: "Alert", message: "\((self.popup?.message)!)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            switch action.style {
            
                case .default:
                    print("\((self.popup?.message)!)")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // action
    
    @IBAction func goToArchive(_ sender: Any) {
        archive()
    }
    
    @IBAction func goToUnArchive(_ sender: Any) {
        unarchive()
    }
    
}

class ToolbarState: NSObject {
     var loading = true

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        loading = change![.newKey] as! Bool // quick and dirty
    }
}

enum Popup: Identifiable {
    case archiveCreated
    case achivingFailed(error: Error)
    case noArchive
    
    var id: String { return self.message } // hack
    
    var message: String {
        switch self {
        case .archiveCreated:
            return "Web page stored offline."
        case .achivingFailed(let error):
            return "Error: " + error.localizedDescription
        case .noArchive:
            return "Nothing archived yet!"
        }
    }
}

// MARK: - WKNavigationDelegate
extension WKVIEWViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == webView {
            spinner.stopAnimating()
        }
    }
}
