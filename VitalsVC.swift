//
//  VitalsVC.swift
//  VitalApp
//
//  Created by Ninehertz.   on 26/03/22.
//

import UIKit
import HealthKit
import Charts

class VitalsVC: UIViewController ,ChartViewDelegate{
    
    
    
    @IBOutlet weak var tblVitals: UITableView!
    @IBOutlet weak var viewCalender:CalenderView!
    @IBOutlet weak var lblData:UILabel!
    @IBOutlet weak var viewGraph: UIView!
    @IBOutlet weak var LineGraph: LineChartView!
    @IBOutlet weak var lblgraphTitle: UILabel!
    
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?
    
    var shouldHideData: Bool = false
    var arrChart = [0.0,300.0,50.0,500.0,70.0,240.0,102.0,0.0,300.0,50.0,500.0,70.0,40.0,302.0]
    
    var arr = [TrackingDatum]()
    var arrGraphData = [TrackingDatum]()
    var arrHeartModel = [HeartRateModel]()
    let vitalItems = HealthKitManager().getAllVitals()
    let arrTime = ["12 AM","03 AM","06 AM","09 AM","12 PM","03 PM","06 PM","09 PM"]
    // MARK: - Variables
    var dateValue: Int = Int()
    var strSelectDate: Date = Date(){
        didSet{
            getHealthKit { flag in
                if flag {
                    self.getHeartData()
                }
            }
        }
    }
    
    lazy var myDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Vitals"
        tblVitals.register(UINib(nibName: "VitalsTableCell", bundle: nil), forCellReuseIdentifier: "VitalsTableCell")
        arrHeartModel.removeAll()
        setCalenderUI()
        
        
    }
    
    @IBAction func btnCloseGraph(_ sender: Any) {
        viewGraph.removeFromSuperview()
    }
    
    
    
    func getOnebyOne(_ completion: @escaping (_ success: Bool) -> Void) {
        getDateofVital(name: self.vitalItems[0].name!, quantityType: self.vitalItems[0].quantityType!){ flag in
            self.getDateofVital(name: self.vitalItems[1].name!, quantityType: self.vitalItems[1].quantityType!){ flag in
                self.getDateofVital(name: self.vitalItems[2].name!, quantityType: self.vitalItems[2].quantityType!){ flag in
                    self.getDateofVital(name: self.vitalItems[3].name!, quantityType: self.vitalItems[3].quantityType!){ flag in
                        self.getDateofVital(name: self.vitalItems[4].name!, quantityType: self.vitalItems[4].quantityType!){ flag in
                            self.getDateofVital(name: self.vitalItems[5].name!, quantityType: self.vitalItems[5].quantityType!){ flag in
                                self.getDateofVital(name: self.vitalItems[6].name!, quantityType: self.vitalItems[6].quantityType!){ flag in
                                    self.getDateofVital(name: self.vitalItems[7].name!, quantityType: self.vitalItems[7].quantityType!){ flag in
                                        self.getDateofVital(name: self.vitalItems[8].name!, quantityType: self.vitalItems[8].quantityType!){ flag in
                                            self.getDateofVital(name: self.vitalItems[9].name!, quantityType: self.vitalItems[9].quantityType!){ flag in
                                                self.getDateofVital(name: self.vitalItems[10].name!, quantityType: self.vitalItems[10].quantityType!){ flag in
                                                    self.getDateofVital(name: self.vitalItems[11].name!, quantityType: self.vitalItems[11].quantityType!){ flag in
                                                        if #available(iOS 14.0, *) {
                                                            self.getDateofVitalOfCEG(name: self.vitalItems[12].name!, quantityType: self.vitalItems[12].objectType!){ flag in
                                                                print("Papa code: ",self.arrHeartModel)
                                                                guard !self.arrHeartModel.isEmpty else {
                                                                    completion(true)
                                                                    return
                                                                }
                                                                print("End ALL 14*")
                                                                self.uploadData(mod: self.arrHeartModel){flag in
                                                                    completion(true)
                                                                }
                                                            }
                                                        }else{
                                                            print("Papa code: ",self.arrHeartModel)
                                                            guard !self.arrHeartModel.isEmpty else {
                                                                completion(true)
                                                                return
                                                            }
                                                            print("End ALL")
                                                            self.uploadData(mod: self.arrHeartModel){flag in
                                                                completion(true)
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func getTotalData()  {
        
    }
    func getHealthKit(_ completion: @escaping (_ success: Bool) -> Void){
        HealthKitManager().authorizationRequestHealthKit { [self] success, error in
            if (success && error==nil) {
                self.arrHeartModel.removeAll()
                getOnebyOne{flag in
                    completion(true)
                }
            }
        }
    }
    
    
    
    
    func setCalenderUI() {
        viewCalender.designCalenderView(startDate: Date())
        self.assignCurrentDatetoCalendar()
        let value: String = Date().monthNameAsString() + ". " + Date().yearAsString()
        print("value",value)
        self.viewCalender.lblMonth.text = value
        viewCalender.callBack = {(tempDate) -> Void in
            self.strSelectDate = tempDate.getDateString(tempDate: tempDate)
            self.viewCalender.lblMonth.text = tempDate.monthNameAsString() + ". " + tempDate.yearAsString()
        }
        viewCalender.rightArrowAction = {
            self.dateValue += 1
            let nextMonth = Calendar.current.date(byAdding: .month, value: self.dateValue, to: Date())
            self.viewCalender.designCalenderViewFromChangeMonth(startDate: nextMonth ?? Date())
            self.viewCalender.lblMonth.text = value
            if let month = nextMonth?.monthNameAsString()  {
                if let year = nextMonth?.yearAsString()  {
                    self.viewCalender.lblMonth.text = month + ". " + year
                }
            }
        }
        viewCalender.leftArrowAction = {
            self.dateValue -= 1
            let previousMonth = Calendar.current.date(byAdding: .month, value: self.dateValue, to: Date())
            self.viewCalender.designCalenderViewFromChangeMonth(startDate: previousMonth ?? Date())
            if let month = previousMonth?.monthNameAsString()  {
                if let year = previousMonth?.yearAsString()  {
                    self.viewCalender.lblMonth.text = month + ". " + year
                }
            }
        }
    }
    
    func assignCurrentDatetoCalendar() {
        self.strSelectDate = Date().getDateString(tempDate: Date())
    }
    
    func getDateofVitalOfCEG(name:String,quantityType:HKObjectType ,_ completion: @escaping(_ success: Bool) -> Void) {
        if #available(iOS 14.0, *) {
            let calendar = Calendar.current
            let startDate = strSelectDate//calendar.startOfDay(for: strSelectDate)
            let endDate = calendar.date(byAdding: .minute, value: 1439, to: startDate)!
            
            // HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
            
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])
            
            //descriptor
            
            let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
                heartRateQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
                guard error == nil else { print("error"); return }
                print("ECG>>>>",results!)
                if results?.count ?? 0 > 0 {
                    print("strSelectDate",self.strSelectDate)
                    print("startDate",startDate)
                    print("endDate",endDate)
                }
                
                self.printHeartRateInfoECG(name: name, results: results){flag in
                    completion(true)
                }
            })
            
            health.execute(heartRateQuery!)
        }
        
    }
    
//    func fetchECGvital() {
//        if #available(iOS 14.0, *) {
//            let calendar = Calendar.current
//            let startDate = strSelectDate//calendar.startOfDay(for: strSelectDate)
//            let endDate = calendar.date(byAdding: .minute, value: 1439, to: startDate)!
//
//            // HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
//
//
//            let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])
//
//                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
//                let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]){ (query, samples, error) in
//                    guard let samples = samples,
//                        let mostRecentSample = samples.first as? HKElectrocardiogram else {
//                        return
//                    }
//                    print(mostRecentSample.averageHeartRate)
//                    print(mostRecentSample)
//                }
//            self.health.execute(ecgQuery)
//            } else {
//                // Fallback on earlier versions
//            }
//    }
    
    func getDateofVital(name:String,quantityType:HKQuantityType ,_ completion: @escaping(_ success: Bool) -> Void) {
        
        let calendar = Calendar.current
        let startDate = strSelectDate//calendar.startOfDay(for: strSelectDate)
        let endDate = calendar.date(byAdding: .minute, value: 1439, to: startDate)!
        
        // HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate as Date, end: endDate as Date?, options: [])
        
        //descriptor
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        heartRateQuery = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard error == nil else { print("error"); return }
            print("Heart Rate>>>>",results!)
            if results?.count ?? 0 > 0 {
                print("strSelectDate",self.strSelectDate)
                print("startDate",startDate)
                print("endDate",endDate)
            }
            
            self.printHeartRateInfo(name: name, quantityType: quantityType, results: results){flag in
                completion(true)
            }
        })
        
        health.execute(heartRateQuery!)
    }
    
    /*used only for testing, prints heart rate info */
    private func printHeartRateInfo(name:String,quantityType:HKQuantityType? = nil, results:[HKSample]?,_ completion: @escaping(_ success: Bool) -> Void){
        for (_, sample) in results!.enumerated() {
            guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
            let split = "\(currData.quantity)".components(separatedBy: " ").last ?? ""
            let value = (currData.quantity.doubleValue(for: HKUnit(from: split))).rounded(toPlaces: 1)
            
            let model = HeartRateModel.init(dataType: name.uppercased(), dataTypeUnit: split, dataTypeValue: "\(value)", dataTypeValueTimeStamp: currData.endDate.timeIntervalSince1970)
            arrHeartModel.append(model)
        }
        completion(true)
        
    }
    
    private func printHeartRateInfoECG(name:String,quantityType:HKQuantityType? = nil, results:[HKSample]?,_ completion: @escaping(_ success: Bool) -> Void){
        if #available(iOS 14.0, *) {
            for (_, sample) in results!.enumerated() {
                print("love",sample)
                let mostRecentSample = sample as? HKElectrocardiogram
                let split = "BPM"
                let value = (mostRecentSample?.averageHeartRate?.doubleValue(for: HKUnit(from: "count/min")))
                
                let model = HeartRateModel.init(dataType: name.uppercased(), dataTypeUnit: split, dataTypeValue: "\(value ?? 0.0)", dataTypeValueTimeStamp: mostRecentSample?.endDate.timeIntervalSince1970 ?? 0.0)
                arrHeartModel.append(model)
            }
        } else {
            // Fallback on earlier versions
        }
        completion(true)
        
    }
    
    //Upload data to server
    func uploadData(mod:[HeartRateModel],_ completion:@escaping (_ success: Bool) -> Void) {
        
        guard Reachability.isConnectedToNetwork() else {
            self.showMessageToUser(title: AppConstant, msg: "Internet is not connected.")
            return
        }
        
        var requestedParams = [[String:Any]]()
        for dat in mod {
            var orderDict = [String:Any]()
            orderDict["dataType"] = dat.dataType
            orderDict["dataTypeUnit"] = dat.dataTypeUnit
            orderDict["dataTypeValue"] = dat.dataTypeValue
            orderDict["dataTypeValueTimeStamp"] = dat.dataTypeValueTimeStamp
            orderDict["timeZone"] = dat.timeZone
            requestedParams.append(orderDict)
        }
        print("The Heart rate date :\(mod)")
        WebService.uploadDataToServer(urlString: "\(BASE_URL)users/tracking_val", dataToUpload: requestedParams) { (response, error, httpResponseCode) in
            
            guard response != nil else {
                self.showMessageToUser(title: AppConstant, msg: serverError)
                return
            }
            
            let responseJSON = response?.value as! [String : Any]
            let json: NSDictionary = responseJSON as NSDictionary
            
            if json ["success"] as! Bool {
                self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
                completion(true)
            }
            else {
                completion(true)
                self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
            }
            
        }
    }
    
    //get Heart Data
    func getHeartData()  {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.init(identifier: "UTC")
        let str = df.string(from: strSelectDate)
        print("apistrSelectDate",strSelectDate)
        print("apistr",str)
        guard Reachability.isConnectedToNetwork() else {
            self.showMessageToUser(title: AppConstant, msg: "Internet is not connected.")
            return
        }
        WebService.performGetApiList(isShowHud: true, urlString: "\(BASE_URL)users/tracking_val?dataFormat=\(str)&timeZone=\(TimeZone.current.identifier)") { response, error in
            
            let responseJSON = response?.value as! [String : Any]
            let json: NSDictionary = responseJSON as NSDictionary
            print("Dictionary:\(json)")
            
            if json ["success"] as! Bool {
                if  (json.value(forKey: "TrackingData") as! NSArray).count == 0 {
                    self.tblVitals.isHidden = true
                    self.lblData.isHidden = false
                }
                else {
                    let dic = Helper.jsonToData(json: (json.value(forKey: "TrackingData") as! NSArray))
                    do {
                        let decoder = JSONDecoder()
                        self.arr = try decoder.decode([TrackingDatum].self, from: dic!)
                        DispatchQueue.main.async {
                            self.lblData.isHidden = true
                            self.tblVitals.isHidden = false
                            self.tblVitals.reloadData()
                        }
                        //self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
                        
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                    
                }
            }
            else {
                self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
            }
        }
    }
    
    
    //get Heart Data
    func getGraphData(type:String)  {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone.init(identifier: "UTC")
        let str = df.string(from: strSelectDate)
        print("apistrSelectDate",strSelectDate)
        
        guard Reachability.isConnectedToNetwork() else {
            self.showMessageToUser(title: AppConstant, msg: "Internet is not connected.")
            return
        }
        WebService.performGetApiList(isShowHud: true, urlString: "\(BASE_URL)users/graph?dataFormat=\(str)&dataType=\(type)") { response, error in
            
            let responseJSON = response?.value as! [String : Any]
            let json: NSDictionary = responseJSON as NSDictionary
            print("Dictionary:\(json)")
            
            if json ["success"] as! Bool {
                if  (json.value(forKey: "TrackingData") as! NSArray).count == 0 {
                    
                }
                else {
                    let dic = Helper.jsonToData(json: (json.value(forKey: "TrackingData") as! NSArray))
                    do {
                        let decoder = JSONDecoder()
                        self.arrGraphData = try decoder.decode([TrackingDatum].self, from: dic!)
                        DispatchQueue.main.async {
                            self.viewGraph.frame = CGRect.init(x: 0, y: 0, width:kSceneDelegate.window?.frame.size.width ?? 0.0 , height: kSceneDelegate.window?.frame.size.height ?? 0.0)
                            kSceneDelegate.window?.addSubview(self.viewGraph)
                            self.lblgraphTitle.text = type.capitalized
                            self.setUpChart()
                        }
                        //self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
                        
                    } catch let parsingError {
                        print("Error", parsingError)
                    }
                    
                }
            }
            else {
                self.showMessageToUser(title: AppConstant, msg: json["message"] as! String)
            }
        }
    }
    
    
    
    // MARK: - Chart Functions
    func setUpChart() {
        
        LineGraph.delegate = self
        
        LineGraph.chartDescription.enabled = true
        LineGraph.dragEnabled = true
        LineGraph.setScaleEnabled(false)
        LineGraph.pinchZoomEnabled = false
        
        
        let l = LineGraph.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        
        let rightAxisFormatter = NumberFormatter()
        
        let leftAxis = LineGraph.leftAxis
        rightAxisFormatter.positivePrefix = ""
        leftAxis.removeAllLimitLines()
        
        var maxValue = Double()
        var minValue = Double()
        
        maxValue  = Double(arrHeartModel.map { Double($0.dataTypeValue) ?? 0 }.max() ?? 0)
        minValue = 0
        
        
        leftAxis.axisMaximum = maxValue + 100//((dictCharts.object(forKey: "overview_data") as? NSDictionary ?? NSDictionary()).object(forKey: "revenue") as? String ?? "0.0").toDouble() ?? 0.0
        leftAxis.axisMinimum = minValue
        
        leftAxis.setLabelCount(8, force: true)
        
        //leftAxis.gridLineDashLengths = [1, 1]
        leftAxis.labelTextColor = UIColor.black
        LineGraph.rightAxis.enabled = false
        LineGraph.leftAxis.enabled = true
        LineGraph.xAxis.labelPosition = .bottom
        LineGraph.xAxis.labelTextColor = UIColor.black
        leftAxis.drawGridLinesEnabled = false
        LineGraph.xAxis.drawGridLinesEnabled = false
        LineGraph.xAxis.valueFormatter = self
        LineGraph.xAxis.enabled = true
        LineGraph.xAxis.setLabelCount(5, force: true)
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: rightAxisFormatter)
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 12),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = LineGraph
        marker.minimumSize = CGSize(width: 40, height: 40)
        LineGraph.marker = marker
        updateChartData()
    }
    
    
    
    func updateChartData() {
        if self.shouldHideData {
            LineGraph.data = nil
            return
        }
        
        setDataCount()
        LineGraph.animate(xAxisDuration: 1.0)
    }
    
    func setDataCount() {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<arrGraphData.count {
            let y = Double(arrGraphData[i].dataTypeValue) ?? 0.0
            let dataEntry = ChartDataEntry.init(x: Double(i), y: y )
            dataEntries.append(dataEntry)
        }
        
        print(dataEntries)
        let set1 = LineChartDataSet(entries: dataEntries, label: "Last 24 Hours data")
        set1.drawIconsEnabled = false
        //set1.axisDependency = .right
        set1.valueFont = .systemFont(ofSize: 9)
        set1.drawValuesEnabled = false
        
        set1.drawCirclesEnabled = false
        set1.colors =  [NSUIColor.init(cgColor: UIColor.systemRed.cgColor)]//ChartColorTemplates.material()
        set1.highlightColor = UIColor.systemRed
        set1.lineWidth = 3.0
        let data = LineChartData(dataSet: set1)
        
        // setLabel(7)
        // barChart.xAxis.valueFormatter = self
        //LineGraph.xAxis.axisMaximum = Double(arrTime.count)-1
        LineGraph.data = data
        //optionTapped(.toggleCubic)
        let marker = XYMarkerView.init(color: UIColor.black, font: UIFont.systemFont(ofSize: 15.0), textColor: UIColor.white, insets: UIEdgeInsets(top:0, left: 0, bottom: 0, right: 0), xAxisValueFormatter:LineGraph.xAxis.valueFormatter!)
        marker.chartView = LineGraph
        marker.minimumSize = CGSize(width: 60, height: 50)
        LineGraph.marker = marker
    }
    
    func setLabel(_ count: Int)  {
        LineGraph.xAxis.labelPosition = .bottom
        LineGraph.xAxis.granularityEnabled = false
        LineGraph.xAxis.granularity = 1
        LineGraph.xAxis.setLabelCount(count, force: true)
        LineGraph.xAxis.centerAxisLabelsEnabled = true
    }
}


extension VitalsVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblVitals.dequeueReusableCell(withIdentifier: "VitalsTableCell", for: indexPath) as! VitalsTableCell
        
        
        if arr[indexPath.row].dataType == "ECG" {
            cell.lblTitle.text = (arr[indexPath.row].dataType).uppercased()
        }else{
            cell.lblTitle.text = (arr[indexPath.row].dataType).capitalized
        }
        cell.lblMeasure.text = arr[indexPath.row].dataTypeUnit.uppercased()
        cell.lblValue.text = arr[indexPath.row].dataTypeValue
        
        let today = Date().getDateString(tempDate: Date())
        if today == self.strSelectDate{
            let split = (arr[indexPath.row].dataTypeValueTimeStamp).components(separatedBy: " ")
            if split.count == 3 {
                cell.lblDate.text = "Today \(split[1]) \(split[2])"
            }else{
                cell.lblDate.text = "Today"
            }
            
        }else{
            
            cell.lblDate.text = convertDateFormat(stringDate: arr[indexPath.row].dataTypeValueTimeStamp, stringDateFormat: "yyyy-MM-dd hh:mm a", stringRequriedDateFormat: "MM-dd-yyyy hh:mm a")
            
          
          //  cell.lblDate.text = arr[indexPath.row].dataTypeValueTimeStamp
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // getGraphData(type: arr[indexPath.row].dataType.uppercased())
        let vc = kMainStoryboard.instantiateViewController(identifier: "vitalGraphVC")as! vitalGraphVC
        vc.strSelectDate = strSelectDate
        vc.type = arr[indexPath.row].dataType.uppercased()
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func convertDateFormat(stringDate: String, stringDateFormat: String, stringRequriedDateFormat: String) -> String {
        myDateFormatter.dateFormat = stringDateFormat
        myDateFormatter.timeZone = NSTimeZone.local
        let date = myDateFormatter.date(from: stringDate)
        myDateFormatter.dateFormat = stringRequriedDateFormat
        myDateFormatter.timeZone = NSTimeZone.local
        if date != nil {
            return myDateFormatter.string(from: date!)
        } else {
            return myDateFormatter.string(from: Date())
        }
    }
    
    
}


//MARK:- Charts
extension VitalsVC: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return  ""//arrTime[Int(round(value)) % arrTime.count]
    }
}
