//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON
import SVProgressHUD

class ViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    @IBOutlet weak var posLabel: UILabel!
    @IBOutlet weak var negLabel: UILabel!
    @IBOutlet weak var neutralLabel: UILabel!
    @IBOutlet weak var numOfTweetsLabel: UILabel!
    
    var sentimentClassifier = TweetSentimentClassifier()
    var swifter: Swifter?
    var pos = 0
    var neg = 0
    var neutr = 0
    let tweetCount = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSwifter()
        textField.delegate = self
        hideKeyboardWhenTappedAround()
    }

    @IBAction func predictPressed(_ sender: Any) {
        pos = 0
        neg = 0
        neutr = 0
        fetchTweets()
        dismissKeyboard()
        SVProgressHUD.show()
    }
    
    func fetchTweets() {
        if let searchText = textField.text {
            guard let swifter = swifter else {fatalError()}
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
            }) { (error) in
                print(error)
            }
        }
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            var sentimentScore = 0.0
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            for pred in predictions {
                let sentiment = pred.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                    pos += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                    neg += 1
                } else {
//                    sentimentScore += 0.1
                    neutr += 1
                }
            }
            updateUI(with: sentimentScore)
        } catch {
            print(error)
        }
    }
    
    func updateUI(with sentimentScore: Double) {
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😠"
        } else {
            self.sentimentLabel.text = "😡"
        }
        
        posLabel.text = "Positive: \(pos)"
        negLabel.text = "Negative: \(neg)"
        neutralLabel.text = "Neutral: \(neutr)"
        
        sentimentLabel.isHidden = false
        posLabel.isHidden = false
        negLabel.isHidden = false
        neutralLabel.isHidden = false
        numOfTweetsLabel.isHidden = false
        
        SVProgressHUD.dismiss()
    }
    
    func setUpSwifter() {
        var api = ""
        var api_secret = ""
        if let path = Bundle.main.path(forResource: "API", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, String> {
                api = dict["API_key"]!
                api_secret = dict["API_secret_key"]!
            }
        }
        swifter = Swifter(consumerKey: api, consumerSecret: api_secret)
    }
    
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        predictPressed(self)
        return true
    }
    
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
