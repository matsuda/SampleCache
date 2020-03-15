//
//  ViewController.swift
//  SampleCache
//
//  Created by Kosuke Matsuda on 2020/03/15.
//  Copyright © 2020 Kosuke Matsuda. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    private let imageURLs: [String] = [
        "https://folio-sec.com/images/theme/themeBoard/vr.jpg",
        "https://folio-sec.com/images/theme/themeBoard/sushi.jpg",
        "https://folio-sec.com/images/theme/themeBoard/pet.jpg",
        "https://folio-sec.com/images/theme/themeBoard/kyoto.jpg",
        "https://folio-sec.com/images/investmentTips/01-bg.png",
        "https://folio-sec.com/images/investmentTips/02-bg.png",
        "https://folio-sec.com/images/investmentTips/03-bg.png",
    ]
    private lazy var cache: LRUImageCache = self.prepareImageCache()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapButton(_ sender: Any) {
        let url = imageURLs.randomElement()!
        print("md5 >>>", url.md5 as Any)
        fetchImage(with: url)
    }

    @IBAction func tapButton2(_ sender: Any) {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }
}

extension ViewController {
    func fetchImage(with urlString: String) {
        print("urlString >>>", urlString)
        DispatchQueue.global().async { [weak self] in
            if let image = self?.cache.image(forKey: urlString) {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
                return
            }
            self?.requestImage(with: urlString)
        }
    }

    func requestImage(with urlString: String) {
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            print("response.url >>>", response?.url)
            guard error == nil else { return }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }

            self?.cache.store(image: image, forKey: urlString)
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
            }
        }.resume()
    }
}

extension ViewController {
    private func prepareImageCache() -> LRUImageCache {
        return LRUImageCache(limitCount: 3)
    }
}
