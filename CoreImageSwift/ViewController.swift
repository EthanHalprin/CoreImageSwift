//
//  ViewController.swift
//  CoreImageSwift
//
//  Created by Ethan Halprin on 02/01/2016.
//  License : Free
//
import UIKit
import CoreImage


extension CIFilter
{
    func hasIntensity() -> Bool
    {
        if self.name == "CISepiaTone"      ||
           self.name == "CIVignetteEffect" ||
           self.name == "CIUnsharpMask"
        {
            return true
        }
        
        return false
    }
    func hasSharpness() -> Bool
    {
        if self.name == "CISharpenLuminance"
        {
            return true
        }
        
        return false
    }
}

class ViewController: UIViewController
{
    //
    // @IBOutlet for image
    //
    @IBOutlet var imageView: UIImageView!
    //
    // All vars outside to save time (these are strong references by default)
    //
    var intensity         : Float     = 0.0
    var currentFilter     : String?
    var buttonAux         : UIButton  = UIButton()
    var labelAux          : UILabel   = UILabel()
    var CIImageOriginal   : CIImage?
    var CIImageClone      : CIImage?
    let context           : CIContext = CIContext()
    var filter            : CIFilter! = CIFilter()
    var filterCIIOutput   : CIImage?
    var CGImageReturn     : CGImage?
    var CGImagePostFilter : CGImage?
    var filterNamePicked  : String?
    var lastButtonPicked  : UIButton?
    let aqua : UIColor = UIColor(red   : 0.0   / 255.0,
                                 green : 140.0 / 255.0,
                                 blue  : 255.0 / 255.0,
                                 alpha : 1.0)
    //
    // @IBOutlets
    //
    @IBOutlet var intensitySlider : UISlider!
    @IBOutlet var sepiaButton     : UIButton!
    @IBOutlet var vignetteButton  : UIButton!
    @IBOutlet var unSharpButton   : UIButton!
    @IBOutlet var chromeButton    : UIButton!
    @IBOutlet var monoButton      : UIButton!
    @IBOutlet var instantButton   : UIButton!
    @IBOutlet var noirButton      : UIButton!
    @IBOutlet var posterButton    : UIButton!
    @IBOutlet var falseButton     : UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let uiImage = self.imageView.image
        {
            CIImageOriginal = CIImage(image: uiImage)
        }
    }
    fileprivate func applyFilter(filterName : String?, forImage image:CIImage?) -> CGImage?
    {
        //
        // The "heavy" action - runs the requested filter on our image
        //
        guard filterName != nil else { return nil }
        guard let image = image else { return nil }
        
        if (filter == nil || (filter != nil && filter.name != filterName))
        {
            filter = CIFilter(name: filterName!)!
        }
        if filter.hasIntensity()
        {
            filter.setValue(intensity, forKey: kCIInputIntensityKey)
        }
        filter.setValue(image, forKey: kCIInputImageKey)
        filterCIIOutput = filter.outputImage!
        CGImageReturn = context.createCGImage(filterCIIOutput!, from: (filterCIIOutput?.extent)!)
        
        return CGImageReturn
    }
    fileprivate func associateFilter(name tag : String) -> String?
    {
        switch tag
        {
            //
            // Row #1
            //
            case "Sepia" :
                sepiaButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CISepiaTone"
            
            case "Vignette" :
                vignetteButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIVignetteEffect"
            
            case "UnSharp" :
                unSharpButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIUnsharpMask"
            //
            // Row #2
            //
            case "Chrome" :
                chromeButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIPhotoEffectChrome"
                
            case "Mono" :
                monoButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIPhotoEffectMono"
            
            case "Instant" :
                instantButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIPhotoEffectInstant"

            case "Noir" :
                noirButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIPhotoEffectNoir"
            //
            // ROW #3
            //
            case "Poster" :
                posterButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIColorPosterize"

            case "False" :
                falseButton.setTitleColor(UIColor.yellow, for: UIControlState.normal)
                filterNamePicked = "CIFalseColor"

            default :
                filterNamePicked = nil
        }
        
        if filterNamePicked != nil
        {
            if filterNamePicked == "CISepiaTone"      ||
               filterNamePicked == "CIVignetteEffect" ||
               filterNamePicked == "CIUnsharpMask"    ||
               filterNamePicked == "CIGloom"
            {
                self.intensitySlider.isEnabled = true
            }
            else
            {
                self.intensitySlider.isEnabled = false
            }
        }
        
        return filterNamePicked
    }
    @IBAction func filterButtonPressed(_ sender: UIButton)
    {
        // "transitive" case - just restore original
        if sender === lastButtonPicked
        {
            if sender.titleLabel?.textColor == UIColor.yellow
            {
                sender.setTitleColor(aqua, for: UIControlState.normal)
                renormalize()
                
                return
            }
        }
        // save last button pressed
        if let prevButton = lastButtonPicked
        {
            prevButton.setTitleColor(aqua, for: UIControlState.normal)
        }

        lastButtonPicked = sender
        
        if let buttonLabel = sender.titleLabel?.text
        {
            // match label on view to CIFilter name
            guard let filter = associateFilter(name: buttonLabel) else { return }
            currentFilter = filter
            
            if filter == "CISepiaTone"      ||
               filter == "CIVignetteEffect" ||
               filter == "CIUnsharpMask"
            {
                // apply will be done on slider removal event
            }
            else
            {
                // apply once
                apply()
            }
        }
    }
    @IBAction func intensitySliderValueChanged(_ sender: UISlider)
    {
        DispatchQueue.global().async
        {
            // creating the CGImage and applying filter takes time
            // that's why on thread (otherwise UI gets stuck!)
            self.intensity = sender.value
            self.CIImageClone = CIImage(cgImage: (self.CIImageOriginal?.cgImage)!)
            self.CGImagePostFilter = self.applyFilter(filterName: self.currentFilter, forImage: self.CIImageClone)
            guard self.CGImagePostFilter != nil else { return }

            DispatchQueue.main.async
            {
                // update with new filtered image
                self.imageView?.image = UIImage(cgImage: self.CGImagePostFilter!)
                self.imageView.setNeedsDisplay()
                self.CIImageClone = nil
            }
        }
    }
    fileprivate func apply()
    {
        // sets the filter once, no slider values relevant to inputIntensity
        DispatchQueue.global().async
        {
            self.CIImageClone = CIImage(cgImage: (self.CIImageOriginal?.cgImage)!)
            self.CGImagePostFilter = self.applyFilter(filterName: self.currentFilter, forImage: self.CIImageClone)
            guard self.CGImagePostFilter != nil else { return }
            
            DispatchQueue.main.async
            {
                self.imageView?.image = UIImage(cgImage: self.CGImagePostFilter!)
                self.imageView.setNeedsDisplay()
                self.CIImageClone = nil
            }
        }
    }
    fileprivate func renormalize()
    {
        DispatchQueue.main.async
        {
            self.imageView?.image = UIImage(cgImage: (self.CIImageOriginal?.cgImage)!)
            self.imageView.setNeedsDisplay()
            self.CIImageClone = nil
        }
    }
}

