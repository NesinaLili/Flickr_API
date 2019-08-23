//
//  FirstViewController.swift
//  BloomyLabTest
//
//  Created by Лилия on 7/31/19.
//  Copyright © 2019 ITEA. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var nameCapitalDetail: String?
    let hostURL = "https://api.flickr.com/services/rest/"
    var arrayInModel = [ApiModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request(text: textField.text ?? "")
        textField.delegate = self
        //textField.borderStyle = .none
        //searchImage(text: "russia")
        textField.becomeFirstResponder()
        
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width - 20)/3, height: (self.collectionView.frame.size.height)/5)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.reloadData()
        
        
        
    }
    
    func convert(farm: Int, server: String, id:String, secret: String) -> URL? {
        return URL(string:"https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_c.jpg")
    }
    
    func request(text: String) {
        
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let key = "&api_key=9e52cff2258ebe2c2f54cb01502a1e59"
        let format = "&format=json&nojsoncallback=1"
        let farmattedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let textToSearch = "&text=\(farmattedText)"
        let sort = "&sort=relevance"
        
        let searchUrl = base + key + textToSearch + sort + format;
        
        if let url = URL(string: "\(searchUrl)") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            //request.allHTTPHeaderFields = ["X-Api-Key": "9e52cff2258ebe2c2f54cb01502a1e59"]
            
            let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                guard let data = data else {
                    return
                }
                
                do {
            
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                        if let photos = json["photos"] as? [String: Any] {
                            debugPrint(photos)
                            if let photo = photos["photo"] as? [[String: Any]] {
                                self.arrayInModel = []
                                for items in photo {
                                    
                                    let list = ApiModel()
                                    
                                    
                                    if let farm = items["farm"] as? Int {
                                        list.farm = farm
                                    
                                    }
                                    if let id = items["id"] as? String {
                                        list.id = id
                                    }
                                    if let secret = items["secret"] as? String {
                                        list.secret = secret
                                    }
                                    if let server = items["server"] as? String {
                                        list.server = server
                                    }
                                    let pictureUrl = self.convert(farm: list.farm ?? 0, server: list.server ?? "", id: list.id ?? "", secret: list.secret ?? "")
                                    
                                    URLSession.shared.dataTask(with: pictureUrl!, completionHandler: { (data, _, _) in
                                        DispatchQueue.main.async {
                                            list.image = UIImage(data:data!)
                                            self.collectionView.reloadData()
                                        }
                                    }).resume()
                                    
                                    self.arrayInModel.append(list)
                                    debugPrint(self.arrayInModel.count)
                                    
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            
                        }
                    }
                }
                catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
                
            }
            task.resume()
        }
    }
    
}

extension FirstViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        request(text: textField.text ?? "")
        return true
    }
}

extension FirstViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayInModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        
        
        item.imageView.image = arrayInModel[indexPath.row].image
        item.imageView.clipsToBounds = true
        item.imageView.layer.cornerRadius = 15
//        item.imageView.layer.shadowOffset = CGSize(width: 5, height: 5)
//        item.imageView.layer.shadowOpacity = 0.7
//        item.imageView.layer.shadowRadius = 1
//        item.imageView.layer.shadowColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 1.0).cgColor
        return item
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        vc.imageDetail = arrayInModel[indexPath.row].image!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        <#code#>
//    }
    
}
