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
    ]
    private var number = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tapButton(_ sender: Any) {
        let url = imageURLs[number]
        fetchImage(with: url)
        number += 1
        if number >= imageURLs.count {
            number = 0
        }
    }

    @IBAction func tapButton2(_ sender: Any) {
        UIApplication.shared.perform(Selector(("_performMemoryWarning")))
    }
}

extension ViewController {
    func fetchImage(with urlString: String) {
        let url = URL(string: urlString)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
            }
        }.resume()
    }
}
