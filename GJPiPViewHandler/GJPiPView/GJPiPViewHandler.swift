//
//  GJPiPViewHandler.swift
//  GJPiPViewHandler
//
//  Created by Adarsh GJ on 28/08/17.
//  Copyright © 2017 Adarsh. All rights reserved.
//

import UIKit


/**
 PiP view Staes.
 
 - minimized: Pipview minimized
 - fullScreen: Full view this was default pipview.
 - hidden: Remove pipview from superview state.
 - landScape: view rotaed to landscape mode when it was in full screen.
 */
@objc enum PiPViewState : Int {
    case minimized
    case fullScreen
    case hidden
    case landScape
    case none
    
}

/**
 Pan gesture drag direction view Staes.
 
 - up:   Pipview drag to up direction
 - left: pipview drag to left direction.
 - right:pipview drag to right direction.
 - none: default state.
 */

enum DragDirection {
    case up
    case down
    case left
    case right
    case none
}
/**
 PiPManagerDelegate
 
 - videoPause:
 - videoPlay:
 - hidePlayerContent:
 - deviceOrientationChanged:
 
 */
@objc protocol PiPManagerDelegate {
    @objc optional func videoPause ()
    @objc optional func videoPlay ()
    @objc optional func hidePlayerContent ()
    @objc optional func deviceOrientationChanged ()
    @objc optional func presentPlayerController ()
    @objc optional func dismissPlayerController ()
    @objc optional func pipChangeToMinimized ()
    @objc optional func pipChangeToFullScreen()
    
    
    
}
class GJPiPViewHandler: NSObject  {
    
    /// Base view it containing player and detail view.It will be viewcontroller view.
    var parentView          : UIView? = nil
    
    /// playerView in player only tap and pan gesture going to add and also this will contain the player.
    var playerView          : UIView? = nil
    
    /// detailView is bottom view (below playerview).
    var detailView          : UIView? = nil
    
    /// pipConfiguration is SwipePalyerConfiguration object here we will set the default values like inital ogin ,minimized orgin etc.
    var pipConfiguration    :GJPiPViewConfiguration!
    
    /// dragRecognizer is UIPanGestureRecognizer and this will add on player view and it will handle the player dragging.
    var dragRecognizer      : UIPanGestureRecognizer?
    
    /// tapRecognizer is UITapGestureRecognizer and this will add on player view and it will handle the player tap actions.
    var tapRecognizer       : UITapGestureRecognizer?
    
    /// delegate is PiPManagerDelegate In this contain set of function.
    var delegate            : PiPManagerDelegate?
    
    
    var pipViewState        = PiPViewState.hidden
    
    var dragDirection       = DragDirection.none
    
    var isSmall             = false
    var isVertical          = false
    var isHorizontal        = false
    
    let animationDuration = 0.5
    
    
    class var sharedInstance :GJPiPViewHandler {
        struct Singleton {
            static let instance = GJPiPViewHandler()
        }
        return Singleton.instance
    }
    /**
     Pass all views to PipManager class
     
     - Parameter customParentView: This will be the base view (viewcontroller view).
     - Parameter customPlayerView: Top most player view
     - Parameter customDetailView: This will be bottom detail view.
     */
    func addViewWith(_ customParentView : UIView,customPlayerView playerView : UIView,customDetailView detailView: UIView,withConfiguration configuration: GJPiPViewConfiguration =  GJPiPViewConfiguration()) {
        
        removeSubViewFromView()
        
        self.playerView = playerView
        self.detailView = detailView
        self.parentView = customParentView
        self.pipConfiguration = configuration
        addGestureRecognizerOnPlayerView ()
        
        self.parentView?.backgroundColor = UIColor.clear
        self.playerView?.layer.anchorPoint.applying(CGAffineTransform.init(translationX: -0.5, y: -0.5))
        
        if !GJUtils.isIpad() {
            NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
    }
    
    func deviceOrientationDidChange(_ notification: Notification) {
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            if self.pipViewState == .fullScreen  {
                self.playerView?.removeGestureRecognizer(self.dragRecognizer!)
                self.pipViewState = .landScape
                guard let presentPlayer = self.delegate?.presentPlayerController else {
                    return
                }
                presentPlayer()
            }
        }
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            if self.pipViewState == .landScape {
                self.playerView?.addGestureRecognizer(self.dragRecognizer!)
                
                self.pipViewState = .fullScreen
                //self.pipViewAnimate()
                guard let dismissPlayer = self.delegate?.dismissPlayerController else {
                    return
                }
                dismissPlayer()
            }
        }
    }
    
    /**
     Change pipview to minimize
     */
    func minimizePlayerView()  {
        if self.pipViewState == .fullScreen {
            self.pipViewState = .minimized
            self.pipViewAnimate()
        }
    }
    /**
     Change pipview to minimize
     */
    func removePiPView()  {
        if self.pipViewState != .hidden {
            self.pipViewState = .hidden
            self.pipViewAnimate()
        }
    }
    
    /**
     Tap on pip view this will call and if pipview stae in minimized then changed to full screen otherewise no action.
     */
    func tapOnPlayerView()  {
        if self.pipViewState == .minimized || self.pipViewState == .none {
            self.pipViewState = .fullScreen
            self.pipViewAnimate()
            //            if let videoPlayFunction = self.delegate?.videoPlay!() {
            //                videoPlayFunction
            //            }
            
        }
    }
    /**
     remove pipview from UIWindow
     */
    func removeSubViewFromView() {
        
        if (self.parentView != nil) {
            self.parentView?.removeFromSuperview()
        }
        parentView?.alpha = 1
    }
    /**
     Add pipview on UIWindow
     */
    func showPipView() {
        removeSubViewFromView()
        self.pipViewState = .fullScreen
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.parentView!)
        }
    }
    
    /**
     If player view and others are already added then we need to update only the pipview content no need to update on other values.
     
     */
    func updateThePipView() {
        
        self.parentView?.removeFromSuperview()
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(self.parentView!)
        }
        self.parentView?.backgroundColor = UIColor.clear
        self.tapOnPlayerView()
        self.pipViewState = .fullScreen
        self.pipViewAnimate()
    }
    
    /**
     Add GestureRecognizer on playerview.
     
     */
    func addGestureRecognizerOnPlayerView () {
        self.dragRecognizer = UIPanGestureRecognizer(target: self, action:#selector(self.minimizeGesture(_:)))
        self.dragRecognizer?.delegate = self
        self.dragRecognizer?.minimumNumberOfTouches = 1
        self.dragRecognizer?.maximumNumberOfTouches = 1
        self.playerView?.isUserInteractionEnabled = true
        self.playerView?.addGestureRecognizer(self.dragRecognizer!)
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction(senderGesture:)))
        self.tapRecognizer?.delegate = self
        self.playerView?.addGestureRecognizer(self.tapRecognizer!)
        
    }
    
    func changeValues(scaleFactor: CGFloat, viewState : PiPViewState) {
        
        self.detailView?.alpha = 1 - scaleFactor
        let scale = CGAffineTransform.init(scaleX: (1 - 0.5 * scaleFactor), y: (1 - 0.5 * scaleFactor))
        let trasform = scale.concatenating(CGAffineTransform.init(translationX: -(self.playerView!.bounds.width / 4 * scaleFactor), y: -((self.playerView?.bounds.height)! / 4 * scaleFactor)))
        
        switch viewState {
        case .fullScreen:
            self.parentView?.frame.origin = self.positionDuringSwipe(scaleFactor: scaleFactor)
            self.playerView?.transform = trasform
            
        case .hidden:
            self.parentView?.frame.origin.x = UIScreen.main.bounds.width/2 - abs(scaleFactor)
            
        case .minimized:
            self.parentView?.frame.origin = self.positionDuringSwipe(scaleFactor: scaleFactor)
            self.playerView?.transform = trasform
            
        default: break
            
        }
    }
    /**
     Here create CGPoint based on scale factor and playerview from.
     
     - Parameter meters: The distance to travel in meters.
     */
    func positionDuringSwipe(scaleFactor: CGFloat) -> CGPoint {
        let width = UIScreen.main.bounds.width * 0.5 * scaleFactor
        let height = width * 9 / 16
        let x = (UIScreen.main.bounds.width) * scaleFactor - width
        let y = self.pipConfiguration.screenHeight * scaleFactor - height
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }
    /**
     Here update the Pip view frame based on PipView state.
     
     */
    func pipViewAnimate()  {
        
        switch self.pipViewState {
        case .fullScreen:
            UIView.animate(withDuration: animationDuration, animations: {
                
                self.detailView?.alpha = 1
                self.playerView?.transform = CGAffineTransform.identity
                self.parentView?.frame.origin = self.pipConfiguration.fullScreenOrigin
                
            }, completion: { (finished) in
                
                self.isSmall = false
            })
            
            UIView.animate(withDuration: 0.5, animations: {
                if let pipChangeToFullScreen = self.delegate?.pipChangeToFullScreen  {
                    pipChangeToFullScreen()
                }
            })
        case .minimized:
            
            UIView.animate(withDuration: animationDuration, animations: {
                UIApplication.shared.isStatusBarHidden = false
                self.detailView?.alpha = 0
                let widthContraint = GJUtils.isIpad() ? CGFloat(0.5) :  CGFloat(0.5)
                
                let scale = CGAffineTransform.init(scaleX: widthContraint, y: widthContraint)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -((self.playerView?.bounds.width)!/4) , y: -((self.playerView?.bounds.height)!/4)))
                self.parentView?.frame.origin = self.pipConfiguration.minimizedOrigin
                self.playerView?.transform  = trasform
                
            }, completion: { (finished) in
                self.isSmall = true
                if let pipChangeMinimized = self.delegate?.pipChangeToMinimized  {
                    pipChangeMinimized()
                }
            })
            
        case .hidden :
            UIView.animate(withDuration: animationDuration, animations: {
                let hideenCGPoint = self.pipConfiguration.hiddenOrigin
                self.parentView?.frame.origin =  CGPoint(x: (self.dragDirection == .left) ? -hideenCGPoint.x : hideenCGPoint.x, y:hideenCGPoint.y )
            }, completion: { (finished) in
                self.isSmall = false
                
                guard let removePlayer = self.delegate?.hidePlayerContent else {
                    return
                }
                removePlayer()
            })
            
        case .landScape :
            print("landScape")
        case .none :
            UIView.animate(withDuration: animationDuration, animations: {
                UIApplication.shared.isStatusBarHidden = false
                self.detailView?.alpha = 0
                let scale = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
                let trasform = scale.concatenating(CGAffineTransform.init(translationX: -((self.playerView?.bounds.width)!/4) , y: -((self.playerView?.bounds.height)!/4)))
                self.parentView?.frame.origin = self.pipConfiguration.minimizedOrigin
                self.playerView?.transform  = trasform
                
            }, completion: { (finished) in
                self.isSmall = true
                
            })
            
            // default : break
        }
        
        isVertical = false
        isHorizontal = false
    }
    
    // MARK: - GestureRecognizer Action
    
    func tapGestureAction(senderGesture : UIPanGestureRecognizer)  {
        tapOnPlayerView()
    }
    @IBAction func minimizeGesture(_ sender: UIPanGestureRecognizer) {
        let gestureTranslatedPoint =  sender.translation(in: playerView)
        if sender.state == .ended {
            updateSwipeState(gestureTranslatedPoint)
            self.pipViewAnimate()
            
        }else{
            updateMovingSwipeState(gestureTranslatedPoint)
            updateMovingFrame(sender)
        }
    }
    func updateMovingFrame(_ sender: UIPanGestureRecognizer){
        let translatedPoint =  sender.translation(in: nil)
        
        switch self.pipViewState {
        case .fullScreen:
            let factor = 1 - (abs(translatedPoint.y) / self.pipConfiguration.screenHeight)
            
            self.changeValues(scaleFactor: factor, viewState: .fullScreen)
        case .minimized:
            let factor = (abs(translatedPoint.y) / self.pipConfiguration.screenHeight)
            
            self.changeValues(scaleFactor: factor, viewState: .minimized)
        case .hidden:
            
            self.parentView?.frame.origin.x = UIScreen.main.bounds.width/2 + translatedPoint.x
            
        default: break
        }
    }
    
    func updateSwipeState(_ translatedPoint: CGPoint){
        dragDirection               = .none
        pipViewState                = .none
        
        let screenWidth             = self.pipConfiguration.screenWidth
        let screenHeight            = self.pipConfiguration.screenHeight
        
        let playerHeight = (playerView?.bounds.size.height)! / 4
        
        if( isSmall && !isVertical){
            if((translatedPoint.x < 0 && fabs(translatedPoint.x) > screenWidth / 5) || translatedPoint.x > 0){
                dragDirection = (translatedPoint.x < 0) ? .left : .right
                pipViewState  = .hidden
            }
        }
        else if((self.parentView?.frame.origin.y)! > (screenHeight / 2 - playerHeight) ){
            dragDirection = .down
            pipViewState  = .minimized
            
        }
        else if((self.parentView?.frame.origin.y)! <= (screenHeight / 2 - playerHeight)){
            dragDirection = .up
            pipViewState  = .fullScreen
        }
        
    }
    func updateMovingSwipeState(_ translatedPoint: CGPoint){
        
        dragDirection               = .none
        pipViewState                = .none
        
        if(!isSmall && translatedPoint.y > 0 && !isHorizontal ){
            isVertical = true
            dragDirection = .down
            pipViewState  = .minimized
            
        }
        else if(isSmall){
            if(translatedPoint.y < 0 && !isHorizontal){
                isVertical = true
                dragDirection = .up
                pipViewState  = .fullScreen
            }
            else if(translatedPoint.x > 15 && translatedPoint.x > 0 && !isVertical){
                isHorizontal = true
                dragDirection = .right
                pipViewState  = .hidden
            }
            else if(translatedPoint.x < -15 && translatedPoint.x < 0 && !isVertical){
                isHorizontal = true
                dragDirection = .left
                pipViewState  = .hidden
            }
        }
    }
}
// MARK: - UIGestureRecognizerDelegate

extension GJPiPViewHandler : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

