//
//  AlertGenreView.swift
//  CSE438_FinalProject
//
//  Created by Taylor Howard on 12/12/20.
//  Copyright © 2020 Taylor Howard. All rights reserved.
//

import UIKit

class AlertGenreView: UIView {
    @IBOutlet weak var customlabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        
    }
}
