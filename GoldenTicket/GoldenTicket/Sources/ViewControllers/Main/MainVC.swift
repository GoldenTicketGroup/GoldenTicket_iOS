//
//  MainVC.swift
//  GoldenTicket
//
//  Created by 안재은 on 30/06/2019.
//  Copyright © 2019 황수빈. All rights reserved.
//

import UIKit
import Hero
import SideMenu
import Kingfisher
import AnimatedCollectionViewLayout
import SwiftGifOrigin
import SwiftOverlayShims

class MainVC: UIViewController {
    
    @IBOutlet var userName: UILabel!
    var showIdx: Int?
    var ticketIdx: Int?
    var ticketIdx1: Int?
    var ticketIdx2: Int?
    var showList : [Show] = []
    var timeList : [LotteryList] = []
    var labelList : [LotteryList] = []
    var ticketDetail : [LotteryDetail] = []
    var showAllList : [ShowAll] = [] //전체추가
    
    // time label 시간 통신
    var lotteryTime1 : String!
    var lotteryTime2 : String!
    
    // 응모한 공연 없는지 여부
    var noLottery = false
    
    // 스크롤뷰
    @IBOutlet weak var scrollView: UIScrollView!
    
    // 안내 메시지 라벨
    @IBOutlet weak var infoLabel: UILabel!
    
    //홈 공연 상세 정보에 필요한 outlet
    @IBOutlet weak var showCollectionView: UICollectionView!
    
    //오늘 올라온 공연이 없는 경우
    @IBOutlet weak var noShow: UIImageView!
    
    //응모내역 보여주기에 대한 뷰
    @IBOutlet weak var lotteryCollectionView: UICollectionView!
    @IBOutlet weak var firstLotteryView: UIView!
    @IBOutlet weak var firstTimeLabel: UILabel!
    
    @IBOutlet weak var firstLotteryCheckButton: UIButton!
    
    @IBOutlet weak var secondLotteryView: UIView!
    @IBOutlet weak var secondTimeLabel: UILabel!
    @IBOutlet weak var secondLotteryCheckButton: UIButton!
    
    @IBOutlet weak var lotteryLeftButton: UIButton!
    @IBOutlet weak var lotteryRightButton: UIButton!
    
    // 응모한 공연이 없습니다.
    @IBOutlet var noLotteryHere: UILabel!
    @IBOutlet weak var noLotteryView: UIView!
    @IBOutlet weak var setLotteryView: UIView!
    
    // 모든 공연 보여주는 뷰.
    @IBOutlet weak var allShowView: UICollectionView!
    @IBOutlet weak var todayBtn: UIButton!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var todayUnder: UIView!
    @IBOutlet weak var allUnder: UIView!
    
    let formatter = DateFormatter()
    let userCalender = Calendar.current;
    let requestedComponent : Set<Calendar.Component> = [
        Calendar.Component.month,
        Calendar.Component.day,
        Calendar.Component.hour,
        Calendar.Component.minute,
        Calendar.Component.second
    ]
    
    //콘텐츠 페이지로 넘어가는 버튼
    @IBOutlet weak var monthShowButton: UIButton!
    
    @IBOutlet weak var monthMusicalButton: UIButton!
    
    //검색창으로 넘어가는 버튼
    @IBOutlet weak var searchButton: UIButton!
    
    //메인화면 공연 collectin view animator 설정
    let animator : (LayoutAttributesAnimator, Bool, Int, Int) = (LinearCardAttributesAnimator(), false, 1, 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSideMenu()
        
        //
        secondLotteryView.isHidden = true
        lotteryLeftButton.isHidden = true
        firstLotteryCheckButton.isHidden = true
        secondLotteryCheckButton.isHidden = true
        
        showCollectionView.dataSource = self
        showCollectionView.delegate = self
        
        //전체추가
        allShowView.dataSource = self
        
        // 로그인한 사용자 이름으로 메인 label 반영
        let user = UserDefaults.standard
        
        // 저장된 값을 꺼내어 각 컨트롤에 적용
        self.userName.text = user.string(forKey: "name")
        
        
        // 월 공연, 월 뮤지컬, 검색버튼 customize
        monthShowButton.dropShadow(color: UIColor.black16, offSet: CGSize(width: 0, height: 0), opacity: 1, radius: 6)
        monthMusicalButton.dropShadow(color: UIColor.black16, offSet: CGSize(width: 0, height: 0), opacity: 1, radius: 6)
        searchButton.makeRounded(cornerRadius: 20)
        searchButton.dropShadow(color: UIColor.black16, offSet: CGSize(width: 0, height: 0), opacity: 1, radius: 3)

        // 응모한 공연이 있는 경우 이 뷰 보이지 않도록
        noLotteryHere.isHidden = true
        noLotteryView.isHidden = true
        
        // 응모가능한 공연이 없는 경우
        self.noShow.isHidden = true
        
        // 모든 공연 보여주는 컬렉션 뷰 보이지 않도록
        self.allShowView.isHidden = true
        
        //self.allShowView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 250, right: 0)
        
        
    } // viewDidLoad
    
    
    // 화면이 새로 뜨면 회원 정보 새로 불러오기
    override func viewWillAppear(_ animated: Bool) {
        
        // 수정한 회원 정보의 이름일 수도 있다.
        let user = UserDefaults.standard
        self.userName.text = user.string(forKey: "name")
        self.setShowData()
        self.setTimeLabel()
        self.setShowAll()
    }
    
    // 클릭한 버튼에 따른 공연 뷰 바꿔주기.
    @IBAction func todayButtonClick(_ sender: Any) {
        todayBtn.setTitleColor(UIColor.maize, for: .normal)
        todayUnder.backgroundColor = UIColor.maize
        allBtn.setTitleColor(UIColor.veryLightPink, for: .normal)
        allUnder.backgroundColor = UIColor.veryLightPink
        allShowView.isHidden = true
        
        infoLabel.text = "오늘 저녁 이런 공연 어때요?"
        
        scrollView.isScrollEnabled = true
    }
    
    @IBAction func allButtonClick(_ sender: Any) {
        todayBtn.setTitleColor(UIColor.veryLightPink, for: .normal)
        todayUnder.backgroundColor = UIColor.veryLightPink
        allBtn.setTitleColor(UIColor.maize, for: .normal)
        allUnder.backgroundColor = UIColor.maize
        allShowView.isHidden = false
        
        infoLabel.text = "모든 공연은 이렇게 있어요!"
        
        scrollView.isScrollEnabled = false
        
        allShowView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 296, right: 0)
        allShowView.scrollIndicatorInsets = allShowView.contentInset
    }
    
    
    // 응모한 공연이 있을 시 남은 시간을 보여주는 뷰에 팔요한 시간 계산기, timer
    func timeCalculator(dateFormat: String, endTime: String, startTime: Date = Date()) -> DateComponents {
        
        formatter.dateFormat = dateFormat
        let _startTime = startTime
        let _endTime = formatter.date(from: endTime)
        
        let timeDifference = userCalender.dateComponents(requestedComponent, from: _startTime, to: _endTime!)
        return timeDifference
        
    }
    
    //첫번째 응모한 공연에 대한 시간 프린터
    @objc func timePrinter1() -> Void {
        // 시간 보여주기
        if timeList.count != 0 {
            let time = timeCalculator(dateFormat: "MM/dd/yyyy hh:mm:ss a", endTime : lotteryTime1)  //endTime 에 timeLabel 이런식으로 변수 넣어주기
            // "07/07/2019 04:30:30"
            let sec = time.second!
            let min = time.minute!
            let h = time.hour!
            
            var second = "\(time.second!)"
            var minute = "\(time.minute!)"
            var hour = "\(time.hour!)"
            
            if sec < 10 {
                second = "0" + second
            } else {}
            if min < 10 {
                minute = "0" + minute
            } else {
                
            }
            if h < 10 {
                hour = "0" + hour
            }
            
            firstTimeLabel.text = hour + " : " + minute + " : " + second
            
            if sec <= 0 && min <= 0 && sec <= 0 {
                firstLotteryCheckButton.isHidden = false    // 당첨확인!
                firstTimeLabel.isHidden = true              // 타이머 숨기기
            }
        }
    }
    
    //두번째 응모한 공연에 대한 시간 프린터
    @objc func timePrinter2() -> Void {
        if timeList.count == 2 {
            // 시간 보여주기
            let time = timeCalculator(dateFormat: "MM/dd/yyyy hh:mm:ss a", endTime : lotteryTime2)
           
            let sec = time.second!
            let min = time.minute!
            let h = time.hour!
            
            var second = "\(time.second!)"
            var minute = "\(time.minute!)"
            var hour = "\(time.hour!)"
            
            if sec < 10 {
                second = "0" + second
            } else {}
            if min < 10 {
                minute = "0" + minute
            } else {
                
            }
            if h < 10 {
                hour = "0" + hour
            }
            
            secondTimeLabel.text = hour + " : " + minute + " : " + second
            
            if sec <= 0 && min <= 0 && sec <= 0 {
                secondLotteryCheckButton.isHidden = false
                secondTimeLabel.isHidden = true
            }
        }
    }
    
    // 왼쪽 버튼 클릭시 뷰 이동
    @IBAction func leftButton(_ sender: Any) {
        let visibleItems: NSArray = self.lotteryCollectionView.indexPathsForVisibleItems as NSArray
        
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for itr in visibleItems {
            
            if minItem.row > (itr as AnyObject).row {
                minItem = itr as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row - 1, section: 0)
        self.lotteryCollectionView.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
        
        lotteryLeftButton.isHidden = true
        lotteryRightButton.isHidden = false
        
        secondLotteryView.isHidden = true
        firstLotteryView.isHidden = false
    }
    
    // 오른쪽 버튼 누를 시 오늘 뷰 이동
    @IBAction func rightButton(_ sender: Any) {
        let visibleItems: NSArray = self.lotteryCollectionView.indexPathsForVisibleItems as NSArray
        
        var minItem: NSIndexPath = visibleItems.object(at: 0) as! NSIndexPath
        for itr in visibleItems {
            
            if minItem.row > (itr as AnyObject).row {
                minItem = itr as! NSIndexPath
            }
        }
        
        let nextItem = NSIndexPath(row: minItem.row + 1, section: 0)
        self.lotteryCollectionView.scrollToItem(at: nextItem as IndexPath, at: .left, animated: true)
        
        lotteryLeftButton.isHidden = false
        lotteryRightButton.isHidden = true
        
        firstLotteryView.isHidden = true
        secondLotteryView.isHidden = false
    }
    
    
    // 티켓 버튼 누를 시 당첨된 티켓
    // 여부에 따라 분기 처리
    @IBAction func showTicket(_ sender: Any) {
        
        let storyboardNone = UIStoryboard.init(name: "NoTicket", bundle: nil)
        let dvcN = storyboardNone.instantiateViewController(withIdentifier: "NoTicket")
        present(dvcN, animated: true)
    }
    
    @IBAction func onClickSearchButton(_ sender: Any) {
        let storyboardSearch = UIStoryboard.init(name: "Search", bundle: nil)
        guard let dvc = storyboardSearch.instantiateViewController(withIdentifier: "SearchVC") as? SearchVC else {
            return
        }
        present(dvc, animated: true)
    }
    
    
    @IBAction func lotteryCheckOne(_ sender: Any) {
        // 당첨이 안됐을 때
        let storyboardLose = UIStoryboard.init(name: "Lose", bundle: nil)
        let lose = storyboardLose.instantiateViewController(withIdentifier: "loseVC")
                        
        self.present(lose, animated: true)
    }
    
    @IBAction func lotteryCheckTwo(_ sender: Any) {
        // 당첨 됐을 때
        let storyboardWin = UIStoryboard.init(name: "Win", bundle: nil)
        let win = storyboardWin.instantiateViewController(withIdentifier: "winVC")
                    
        self.present(win, animated: true)
    }
    

    
    // side Menu bar 의 제스쳐를 지정해주는 함수.
    func setupSideMenu() {
        
        // Side Menu 의 애니메이션을 지정
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        
        // Side Menu 의 이펙트를 지정
        SideMenuManager.default.menuBlurEffectStyle = nil
        
        // Side Menu 가 보일 때 기존 ViewController 의 투명도
        SideMenuManager.default.menuAnimationFadeStrength = 0.5
        // Side Menu 의 투명도
        SideMenuManager.default.menuShadowOpacity = 0.3
        // Side Menu 가 보일 때 기존 ViewController 의 크기
        SideMenuManager.default.menuAnimationTransformScaleFactor = 1
        // Side Menu 의 Width
        SideMenuManager.default.menuWidth = 311
        // Side Menu 의 Status Bar 에 대한 침범 여부를 결정
        SideMenuManager.default.menuFadeStatusBar = false
        
    }
    
    
    @IBAction func monthShow(_ sender: Any) {
        
        let storyboardContent = UIStoryboard.init(name: "Contents", bundle: nil)
        let dvc = storyboardContent.instantiateViewController(withIdentifier: "contentsVC")
        present(dvc, animated: true)
    }
    
    @IBAction func monthMusical(_ sender: Any) {
        
        let storyboardContent = UIStoryboard.init(name: "Contents", bundle: nil)
        let dvc = storyboardContent.instantiateViewController(withIdentifier: "contents2")
        present(dvc, animated: true)
    }
}

extension MainVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.showCollectionView {
            return showList.count
        }
        // nil 값이 들어오지 않도록 setTimeLabel 먼저 호출해주고 timeList 반환된 상태에서 접근할 수 있도록 한다.
        // setTimeLabel()
        else if collectionView == self.allShowView {
            return showAllList.count
        }
        return timeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.showCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainShowCell", for: indexPath) as! MainShowCell
            
            let show = showList[indexPath.row]
            
            // kingfisher로 url 통해서 이미지 불러오기
            // cell.MainShowCell의 아웃렛 이름 = show(모델).swift.서버 이름
            cell.showIndex = show.show_idx
            cell.showImage.imageFromUrl(show.image_url, defaultImgPath: "https://sopt24server.s3.ap-northeast-2.amazonaws.com/1562055837775.jpg")
            cell.showLocation.text = show.location
            cell.showTime.text = show.running_time
            cell.showTitle.text = show.name
            
            return cell
        }
        else if collectionView == self.allShowView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "allShowCell", for: indexPath) as! MainShowAllCell
            
            let show = showAllList[indexPath.row]
            
            // kingfisher로 url 통해서 이미지 불러오기
            // cell.MainShowCell의 아웃렛 이름 = show(모델).swift.서버 이름
            cell.showImg.imageFromUrl(show.image_url, defaultImgPath: "https://sopt24server.s3.ap-northeast-2.amazonaws.com/1562055837775.jpg")
            cell.showIndex = show.show_idx

            // 셀 corner radius, drop shadow 설정해주기.
            cell.contentView.layer.cornerRadius = 20
            cell.contentView.layer.masksToBounds = true
            cell.layer.shadowColor = UIColor.black16.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.layer.shadowOpacity = 1
            cell.layer.shadowRadius = 3
            cell.layer.masksToBounds = false
            
            return cell
        }
        else {
            let lotteryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "lotteryCell", for: indexPath) as! LotteryCheckCell
            
            let label = labelList[indexPath.row]
            
            lotteryCell.lotteryShowTitle.text = label.name
            lotteryCell.lotteryShowIdx = label.lottery_idx  // 셀에 응모한 공연 인덱스 넣기
            
            if labelList.count == 1 {
                self.ticketIdx1 = labelList[0].lottery_idx
            }
            else if labelList.count == 2 {
                self.ticketIdx2 = labelList[0].lottery_idx
                self.ticketIdx2 = labelList[1].lottery_idx
            }
            return lotteryCell
        }
    }
}

extension MainVC : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let dvc = self.storyboard?.instantiateViewController(withIdentifier: "ShowDetailVC") as! ShowDetailVC

        let show = showList[indexPath.row]
        dvc.showIdx = show.show_idx
        
        self.present(dvc, animated: true)
    }
}

//전체추가
//extension MainVC : UICollectionViewDelegateFlowLayout
//{
//    // Collection View Cell 의 width, height 를 지정할 수 있습니다.
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//    {
//        let width : CGFloat =
//        let height : CGFloat
//        if collectionView == self.allShowView {
//            let width: CGFloat = (view.frame.width - 21) / 2
//            let height: CGFloat = 236
//
//            return CGSize(width: width, height: height)
//        }
//        return CGSize(width: width, height: height)
//    }
//}

// 통신 데이터 세팅.
extension MainVC {
    
    func setShowData() {
        
        ShowService.shared.showHome() {
            [weak self]
            data in
            
            guard let `self` = self else { return }
            
            switch data {
                
            // 매개변수에 어떤 값을 가져올 것인지
            case .success(let res):
                
                self.showList = res as! [Show]
                self.showCollectionView.reloadData()
                
                if self.showList.count == 0 {
                    //우선 오늘 응모가능한 공연이 없는 경우
                    self.noShow.isHidden = false
                }
                
            case .requestErr(let message):
                self.simpleAlert(title: "메인 공연 조회 실패", message: "\(message)")
                
            case .pathErr:
                print(".pathErr")
            case .serverErr:
                print(".serverErr")
                
            case .networkFail:
                self.simpleAlert(title: "메인 공연 조회 실패", message: "네트워크 상태를 확인해주세요.")
            }
        }
    }
    
    //전체추가
    func setShowAll() {
        
        ShowService.shared.showAll() {
            [weak self]
            data in
            
            guard let `self` = self else { return }
            
            switch data {
                
            // 매개변수에 어떤 값을 가져올 것인지
            case .success(let res):
                
                self.showAllList = res as! [ShowAll]
                self.allShowView.reloadData()
                
            case .requestErr(let message):
                self.simpleAlert(title: "전체 공연 조회 실패", message: "\(message)")
                
            case .pathErr:
                print(".pathErr")
            case .serverErr:
                print(".serverErr")
                
            case .networkFail:
                self.simpleAlert(title: "전체 공연 조회 실패", message: "네트워크 상태를 확인해주세요.")
            }
        }
    }
    
    // 응모한 공연시간 정보 setting 해주기.
    
    func setTimeLabel() {
        
        // count down timer에 필요한 함수들
        let timer1 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timePrinter1), userInfo: nil, repeats: true)
        let timer2 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timePrinter2), userInfo: nil, repeats: true)
        
        LotteryService.shared.lotteryList() {
            [weak self]
            data in
            
            guard let `self` = self else { return }
            
            switch data {
                
            // 매개변수에 어떤 값을 가져올 것인지
            case .success(let res):
                // print("타임 조회 성공")
                let response = res as! ResponseArray<LotteryList>
                
                self.timeList = response.data as! [LotteryList]
                self.labelList = response.data as! [LotteryList]
                self.lotteryCollectionView.reloadData()
                
                if self.timeList.count == 1 {
                    // 응모한 공연이 1개
                    self.lotteryRightButton.isHidden = true
                    self.lotteryTime1 = self.timeList[0].start_time     // 응모한 공연 1
                    timer2.fire()
                }
                else if self.timeList.count == 2 {
                    // 응모한 공연이 2개
                    self.lotteryTime1 = self.timeList[0].start_time     // 응모한 공연 1
                    self.lotteryTime2 = self.timeList[1].start_time     // 응모한 공연 2
                    // print("lotteryTime1 \(self.lotteryTime1!)")
                    // print("lotteryTime2 \(self.lotteryTime2!)")
                    
                    timer1.fire()
                    timer2.fire()
                }
                else {
                    // 응모한 공연이 없음
                    self.noLottery = true
                    self.noLotteryHere.isHidden = false
                    self.noLotteryView.isHidden = false
                }
                
                
            case .requestErr(let message):
                self.simpleAlert(title: "시간 조회 실패", message: "\(message)")
                
            case .pathErr:
                print(".pathErr")
                
            case .serverErr:
                print(".serverErr")
                
            case .networkFail:
                self.simpleAlert(title: "시간 조회 실패", message: "네트워크 상태를 확인해주세요.")
            }
        }
    }
}
