//
//  KakaoMapPoiExtension.swift
//  Busanify
//
//  Created by MadCow on 2024/7/25.
//

import UIKit
import KakaoMapsSDK

// Manage Poi
extension HomeViewController: KakaoMapEventDelegate {
    func createLabelLayer(layerID: String) {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: layerID, competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 100000)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle(styleID: String, currentLocation: Bool = false) {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        // PoiBadge는 스타일에도 추가될 수 있다. 이렇게 추가된 Badge는 해당 스타일이 적용될 때 함께 그려진다.
//        let noti1 = PoiBadge(badgeID: "badge1", image: UIImage(named: "noti.png"), offset: CGPoint(x: 0.9, y: 0.1), zOrder: 0)
        let iconStyle1 = PoiIconStyle(symbol: UIImage(named: currentLocation ? "map_ico_marker" : "pin_green.png"), 
                                      anchorPoint: CGPoint(x: 0, y: 0),
                                      transition: PoiTransition(entrance: .scale, exit: .scale)
                                      /*badges: [noti1]*/)
        
        // 5~11, 12~21 에 표출될 스타일을 지정한다.
        let poiStyle = PoiStyle(styleID: styleID, styles: [
            PerLevelPoiStyle(iconStyle: iconStyle1, level: 5)
        ])
        manager.addPoiStyle(poiStyle)
    }
    
    func createPois(layerID: String, styleID: String, poiID: String, mapPoints: [MapPoint]) {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: layerID)
        layer?.visible = true
        let poiOption1 = PoiOptions(styleID: styleID)
        poiOption1.rank = 0
        poiOption1.clickable = true
        
        let pois = layer?.addPois(option: poiOption1, at: mapPoints)
        
        guard let pois = pois else { return }
        for poi in pois {
            let _ = poi.addPoiTappedEventHandler(target: self, handler: HomeViewController.poiTappedHandler)
        }
        layer?.showAllPois()
    }
    
    // POI 탭 이벤트가 발생하고, 표시하고 있던 Poi를 숨긴다.
    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        print(param.poiItem.itemID)
    }
}

// Manage Auth
extension HomeViewController {
    // 인증 성공시 delegate 호출.
    func authenticationSucceeded() {
        // 일반적으로 내부적으로 인증과정 진행하여 성공한 경우 별도의 작업은 필요하지 않으나,
        // 네트워크 실패와 같은 이슈로 인증실패하여 인증을 재시도한 경우, 성공한 후 정지된 엔진을 다시 시작할 수 있다.
        if _auth == false {
            _auth = true
        }
        
        if _appear && mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break;
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break;
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                                        toastLabel.alpha = 0.0
                                    },
                       completion: { (finished) in
                                        toastLabel.removeFromSuperview()
                                    })
    }
}
