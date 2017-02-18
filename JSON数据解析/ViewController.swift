//
//  ViewController.swift
//  JSON数据解析
//
//  Created by 曾文志 on 17/02/2017.
//  Copyright © 2017 Lebron. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController {

    private let urlStr = "http://olixskhpy.bkt.clouddn.com/weather.json"
    
    private var parser: XMLParser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    // MARK: - Actions

    @IBAction private func extractJSONWithJSONSerialization() {
        if let url = URL(string: urlStr) {
            let reqeust = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: reqeust, completionHandler: { (data, response, error) in
                if error != nil || data == nil {
                    DispatchQueue.main.sync { // 在主线程中更新UI
                        self.show(text: "请求失败")
                    }
                    return
                }
                
                if let dict = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? Dictionary<String, Any> {
                    print(dict! as Any)
                    
                    DispatchQueue.main.sync { // 在主线程中更新UI
                        self.show(text: "解析成功")
                    }
                }
            })
            
            task.resume()
        }
    }
    
    @IBAction private func extractJSONWithJSONKit() {
        if let url = URL(string: urlStr) {
            if let jsonStr = try? String(contentsOf: url) as NSString {
                let dict = jsonStr.objectFromJSONString() as! Dictionary<String, Any>
                print(dict)
                show(text: "解析成功")
            }
        }
        else {
            show(text: "解析失败")
        }
        
    }
    
    @IBAction private func extractXMLWithXMLParser() {
        let path = Bundle.main.path(forResource: "info.xml", ofType: nil)!
        if let data = try? NSData.init(contentsOfFile: path) as Data {
            parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
    }
    
    @IBAction private func extractXMLWithGDataXML() {
        let path = Bundle.main.path(forResource: "info.xml", ofType: nil)!
        if let data = try? NSData(contentsOfFile: path) as Data {
            // 加载整个XML
            if let doc = try? GDataXMLDocument(data: data, options: 0) {
                // 获取根节点
                let rootDoc = doc.rootElement()!
                // 获取所有city节点
                if let cities = rootDoc.elements(forName: "city") as? [GDataXMLElement] {
                    for city in cities {
                        // 获取name节点
                        let name = city.elements(forName: "name").first as! GDataXMLElement
                        print(name.stringValue())
                    }
                }
            }
        }
    }
    
    // MARK: - Utilities
    
    private func show(text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = text
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            hud.hide(animated: true)
        }
    }
    
}

// MARK: - XMLParserDelegate
extension ViewController: XMLParserDelegate {
    
    // 解析到文档开头调用
    func parserDidStartDocument(_ parser: XMLParser) {
        print("parserDidStartDocument")
    }
    
    // 解析到一个元素的开始就会调用
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print("-------didStartElement-------")
        print(elementName)
        print(namespaceURI as Any)
        print(attributeDict)
        print("-------didStartElement-------")

    }
    
    // 解析到节点时调用
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("-------foundCharacters-------")
        print(string)
        print("-------foundCharacters-------")
    }
    
    // 解析到一个元素的结尾就会调用
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        print("-------didEndElement-------")
        print(elementName)
        print(namespaceURI as Any)
        print(qName as Any)
        print("-------didEndElement-------")
    }
    
    // 解析到文档结尾调用
    func parserDidEndDocument(_ parser: XMLParser) {
        print("parserDidEndDocument")
    }
}

