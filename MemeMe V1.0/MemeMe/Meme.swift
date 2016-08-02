//
//  meme.swift
//  MemeMe
//
//  Created by JING ZHANG on 7/31/16.
//  Copyright © 2016 JING ZHANG. All rights reserved.
//

import UIKit

// This class will hold the Meme with its attributes: top text, bottom txt, image and generated image.
struct Meme {
    
    //Meme elements
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    
    //The actual generated image with top/bottom text
    var memedImage: UIImage
}