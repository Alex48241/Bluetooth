//
//  vitalGraphVC.swift
//  VitalApp
//
//  Created by Ninehertz.
//

import UIKit
import Charts

class cell_vital: UITableViewCell {
    @IBOutlet weak var btnvalue: UIButton!
    @IBOutlet weak var btndate: UIButton!
    
}
class vitalGraphVC: UIViewController,ChartViewDelegate {

    @IBOutlet weak var LineGraph: LineChartView!
    var arrGraphData = [TrackingDatum]()
    var strSelectDate: Date = Date()
    var shouldHideData: Bool = false
    var type = ""
    @IBOutlet weak var tbl_list: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = type.capitalized
        
       getGraphData(type: type)
        // Do any additional setup after loading the view.
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
                
        maxValue  = Double(arrGraphData.map { Double($0.dataTypeValue) ?? 0 }.max() ?? 0)
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
    
    //get Heart Data
    func getGraphData(type:String)  {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let str = df.string(from: strSelectDate)
        
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
                        self.tbl_list.reloadData()
                        DispatchQueue.main.async {
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
}
//MARK:- Charts
extension vitalGraphVC: AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return  ""//arrTime[Int(round(value)) % arrTime.count]
    }
}

extension vitalGraphVC:UITableViewDelegate,UITableViewDataSource {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrGraphData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_vital", for: indexPath) as! cell_vital
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone.init(identifier: "UTC")
        let str = df.date(from: "\(arrGraphData[indexPath.row].dataFormat)")
        
        df.dateFormat = "MM/dd/yyyy hh:mm a"
        
        cell.btndate.setTitleColor(UIColor.black, for: .normal)
        cell.btnvalue.setTitleColor(UIColor.black, for: .normal)
        
        cell.btnvalue.setTitle("    \(arrGraphData[indexPath.row].dataTypeValue)", for: .normal)
        cell.btndate.setTitle("\(df.string(from: str ?? Date()))  ", for: .normal)
        return cell
    }
    
}
