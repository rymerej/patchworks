//
//  ShapeView.swift
//  Patchworks
//
//  Created by Jeremy Reynolds on 12/6/17.
//  Copyright © 2017 Jeremy Reynolds. All rights reserved.
//

import UIKit

class ShapeView: UIView {
    
    enum ShapeType: String {
        case rectangle = "rectangle"
        case triangle = "triangle"
    }
    
    var shapePath = UIBezierPath()
    var originalFrame = CGRect()
    var shapeType = ShapeType.rectangle
    var strokeColor = UIColor.shapeStrokeColor
    var fillColor = UIColor.shapeFillColor
    var rotation = CGFloat()
    var image: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    weak var delegate: ShapeDelegate?
    
    convenience init(frame: CGRect, rotation: CGFloat, image: UIImage? = nil, shapeType: ShapeType) {
        self.init(frame: frame)
        self.originalFrame = frame
        self.rotation = rotation
        self.image = image
        self.shapeType = shapeType
        setup(shape: shapeType)
    }
    
    override func draw(_ rect: CGRect) {
        drawShape()
    }
    
    @discardableResult func drawShape() -> UIBezierPath {
        if let image = image?.cgImage {
            if let context = UIGraphicsGetCurrentContext()  {
                context.saveGState()
                shapePath.addClip()
                context.scaleBy(x: 1, y: -1)
                context.draw(image, in: CGRect(x: bounds.minX, y: bounds.minY, width: CGFloat(shapePath.bounds.width), height: CGFloat(shapePath.bounds.height)), byTiling: true)
                context.restoreGState()
//                UIColor.black.setStroke()
//                shapePath.lineJoinStyle = .round
//                shapePath.stroke()
            }
        } else {
            shapePath.lineWidth = 5.0
            fillColor.setFill()
            shapePath.fill()
            strokeColor.setStroke()
            shapePath.stroke()
        }
        return shapePath
    }
    
    func removeImage() {
        if image != nil {
            image = nil
        }
    }
    
    func setup(shape: ShapeType = .rectangle) {
        backgroundColor = UIColor.clear
        if shape == .triangle {
            shapePath = triangle
        } else {
            shapePath = rectangle
        }
        frame = CGRect(x: frame.minX, y: frame.minY, width: shapePath.bounds.width, height: shapePath.bounds.height)
        shapePath.apply(CGAffineTransform(translationX: -shapePath.bounds.minX, y: -shapePath.bounds.minY))
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard shapePath.contains(point) else {
            return nil
        }
        delegate?.shapeClicked(self)
        return self
    }
}

protocol ShapeDelegate: class {
    func shapeClicked(_ sender: ShapeView)
}
