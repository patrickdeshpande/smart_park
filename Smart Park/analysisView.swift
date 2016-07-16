//
//  analysisView.swift
//  Smart Park
//
//  Created by Patrick Deshpande on 7/16/16.
//  Copyright © 2016 Patrick Deshpande. All rights reserved.
//



import UIKit


class analysisView: UIViewController {
    
    
    @IBOutlet var textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var req = EZHttp(inurl: "http://www.ramp9.com/smart_meter/get_analytics.php", inparam: nil, inmethod: "POST", completion: presentAnalytics)

    }
    
    func presentAnalytics(data: NSData?, response: NSURLResponse?, err: NSError?){
        if err != nil {
            print("Error making request: \(err)")
        }
        do {
            let responseObject: AnyObject? =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            print("response from analytics data: \(responseObject)")
            if let arr = responseObject as? NSDictionary {
                dispatch_async(dispatch_get_main_queue()){
                    self.textview.text = self.textview.text.stringByAppendingString("meter number\tpopularity\n")
                }
                for (key, value) in arr {
                    print("\(key), \(value)")
                    dispatch_async(dispatch_get_main_queue()){
                        self.textview.text = self.textview.text.stringByAppendingString("\(key)\t\t\t\t\(value)\n")
                    }
                }
                
            }
        }
        catch let error as NSError {
            print("Error trying to parse JSON: \(error)")
        }
    
    }

    
    
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.title = "Analysis" 
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}