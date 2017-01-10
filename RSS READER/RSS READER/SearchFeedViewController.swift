//
//  ViewController.swift
//  RSS READER
//
//  Created by Seab on 1/9/17.
//  Copyright © 2017 Seab Jackson. All rights reserved.
//

import UIKit

import UIKit

class SearchFeedController: UICollectionViewController {
    
    var entries: [Entry]? = [
        Entry(title: "Sample Title 1", contentSnippet: "Sample Content Snippet 1", url: nil),
        Entry(title: "Sample Title 2", contentSnippet: "Sample Content Snippet 2", url: nil),
        Entry(title: "Sample Title 3", contentSnippet: "Sample Content Snippet 3", url: nil)
    ]
    
    let entryCellId = "entryCellId"
    let headerId = "headerId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "RSS Reader"
        
        collectionView?.register(EntryCell.self, forCellWithReuseIdentifier: entryCellId)
        collectionView?.register(SearchHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.alwaysBounceVertical = true
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.headerReferenceSize = CGSize(width: view.frame.width, height: 50)
            // use estimated height to help the collectionView auto resize to fit content
            layout.estimatedItemSize = CGSize(width: view.frame.width, height: 100)
        }
    }
    
    func performSearchForText(_ text: String) {
        print("Performing search for \(text), please wait...")
        let urlString = "https://ajax.googleapis.com/ajax/services/feed/find?v=1.0&q=Official%20Google%20Blogs"
        let url = NSURL(string: urlString)
        let request = URLRequest(url: url as! URL)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error)
                return
            }
            
//            let string = String(data: data!, encoding: String.Encoding.utf8)
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as! [String: Any]
                
                let responseData = json["responseData"] as? NSDictionary
                if let entryDictionaries = responseData?["entries"] as? [NSDictionary] {
                    self.entries = [Entry]()
                    
                    for entryDictionary in entryDictionaries {
                        let title = entryDictionary["title"] as? String
                        let contentSnippet = entryDictionary["contentSnippet"] as? String
                        let url = entryDictionary["url"] as? String
                        self.entries?.append(Entry(title: title, contentSnippet: contentSnippet, url: url))
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
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = entries?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let entryCell = collectionView.dequeueReusableCell(withReuseIdentifier: entryCellId, for: indexPath) as! EntryCell
        let entry = entries?[indexPath.item]
        entryCell.titleLabel.text = entry?.title
        let data = entry?.contentSnippet?.data(using: String.Encoding.unicode)
        let options = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        
        do {
            let htmlText = try NSAttributedString(data: data!, options: options, documentAttributes: nil)
            entryCell.contentSnippetTextView.attributedText = htmlText
        } catch let error {
            print(error)
        }
        return entryCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! SearchHeader
        header.searchFeedController = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
}

struct Entry {
    var title: String?
    var contentSnippet: String?
    var url: String?
}
