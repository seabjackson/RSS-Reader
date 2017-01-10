//
//  FeedDetailCollectionViewController.swift
//  RSS READER
//
//  Created by Seab on 1/10/17.
//  Copyright © 2017 Seab Jackson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FeedDetailCollectionViewController: UICollectionViewController {
    
    var entryUrl: String? {
        didSet {
            fetchFeed()
        }
    }
    
    var entries: [Entry]?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = UIColor.white

        // Register cell classes
        self.collectionView!.register(EntryCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    func fetchFeed() {
        let urlString = "https://ajax.googleapis.com/ajax/services/feed/load?v=1.0&q=http%3A//api.flickr.com/services/feeds/photos_public.gne%3Fid%3D17472213@N00%26lang%3Den-us%26format%3Drss_200&v=1.0&callback=processResults"
        let url = NSURL(string: urlString)
        let request = URLRequest(url: url as! URL)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print("there was an error", error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: Any]
                
                let responseData = json["responseData"] as? NSDictionary
                
                if let feedEntries = responseData?["feed"] as? [NSDictionary] {
                    self.entries = [Entry]()
                    
                    for entryDictionary in feedEntries {
                        let title = entryDictionary["title"] as? String
                        let contentSnippet = entryDictionary["content"] as? String
                        let entry = Entry(title: title, contentSnippet: contentSnippet, url: nil)
                        self.entries?.append(entry)
                    }
                }
                
                // cells must be reloaded in the main thread since we are updating the UI
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
                
            } catch let error {
                print(error)
            }
            
        }
        task.resume()

    }
    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = entries?.count {
            return count
        }
        return 0
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entryCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! EntryCell
        if let entry = entries?[indexPath.item], let title = entry.title, let contentSnippet = entry.contentSnippet {
            let data = contentSnippet.data(using: String.Encoding.unicode)!
            print(data)
            let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
            do {
                entryCell.titleLabel.text = title
                entryCell.contentSnippetTextView.attributedText = try NSAttributedString(data: data , options: options, documentAttributes: nil)
                entryCell.contentSnippetTextView.isScrollEnabled = true
            } catch let error {
                print("an error was created when using attributed string", error)
            }
            
        }
        return entryCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let entry = entries?[indexPath.item], let contentSnippet = entry.contentSnippet {
            do {
                let text = try(NSAttributedString(data: contentSnippet.data(using: String.Encoding.unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil))
                let size = text.boundingRect(with: CGSize(width: view.frame.width - 26, height: 2000), options: NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin), context: nil).size
                return CGSize(width: view.frame.width, height: size.height + 16)
            } catch let error {
                print(error)
            }
        }
        
        return CGSize(width: view.frame.height, height: 100)
    }

    




}

































