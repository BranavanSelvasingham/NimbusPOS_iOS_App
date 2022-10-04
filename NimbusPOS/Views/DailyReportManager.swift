//
//  DailyReportManager.swift
//  NimbusPOS
//
//  Created by Branavan Selvasingham on 2018-05-20.
//  Copyright © 2018 Nimbus POS Inc. All rights reserved.
//

import Foundation
import MaterialComponents

class DailyReportManager: UIViewController{
    var reportDate = Date() {
        didSet {
            dailyReportValues = NIMBUS.Reports?.generatedDailyReportValues(reportDate: reportDate)
        }
    }
    
    var dailyReportValues = NIMBUS.Reports?.generatedDailyReportValues(reportDate: Date()) {
        didSet {
            refreshLabels()
        }
    }
    
    let headerView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.setDefaultElevation()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Daily Report"
        label.font = MDCTypography.headlineFont()
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        return label
    }()
    
    let printButton: MDCButton = {
        let button = MDCButton()
        button.setImage(UIImage(named: "ic_print"), for: .normal)
        button.addTarget(self, action: #selector(printReport), for: .touchUpInside)
        button.setBackgroundColor(UIColor.clear)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50)
        button.heightAnchor.constraint(equalToConstant: 50)
        return button
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.heightAnchor.constraint(equalToConstant: 50).isActive = true
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(newDateSet), for: .valueChanged)
        return datePicker
    }()
    
    var section0: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 75).isActive = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    var section1: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 150).isActive = true
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var section2: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var section3: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 120).isActive = true
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var section4: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 100).isActive = true
        view.backgroundColor = UIColor.clear
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let reportView: UIViewWithShadow = {
        let view = UIViewWithShadow()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background_paper_white_3")!)
        view.setDefaultElevation()
        return view
    }()
    
    let reportStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 5
        return stackView
    }()
    
    let columnHeaderStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let blank = UILabel()
        
        let totals = UILabel()
        totals.numberOfLines = 2
        totals.textColor = UIColor.gray
        totals.textAlignment = .center
        totals.lineBreakMode = .byWordWrapping
        totals.text = "Total Sales:   (incl. any taxes)"
        totals.font = MDCTypography.titleFont()
        totals.translatesAutoresizingMaskIntoConstraints = false
        
        let hst = UILabel()
        hst.numberOfLines = 2
        hst.textColor = UIColor.gray
        hst.textAlignment = .center
        hst.text = "HST:"
        hst.font = MDCTypography.titleFont()
        hst.translatesAutoresizingMaskIntoConstraints = false

        let gst = UILabel()
        gst.numberOfLines = 2
        gst.textColor = UIColor.gray
        gst.textAlignment = .center
        gst.text = "GST:"
        gst.font = MDCTypography.titleFont()
        gst.translatesAutoresizingMaskIntoConstraints = false

        let pst = UILabel()
        pst.numberOfLines = 2
        pst.textColor = UIColor.gray
        pst.textAlignment = .center
        pst.text = "PST:"
        pst.font = MDCTypography.titleFont()
        pst.translatesAutoresizingMaskIntoConstraints = false

        let count = UILabel()
        count.numberOfLines = 2
        count.textColor = UIColor.gray
        count.textAlignment = .center
        count.text = "Order Count:"
        count.font = MDCTypography.titleFont()
        count.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(blank)
        stackView.addArrangedSubview(totals)
        stackView.addArrangedSubview(hst)
        stackView.addArrangedSubview(gst)
        stackView.addArrangedSubview(pst)
        stackView.addArrangedSubview(count)

        return stackView
    }()
    
    let grandTotalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Grand Total:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        
        return stackView
    }()
    
    let cashTotalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Cash Payments:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        
        return stackView
    }()
    
    let cardTotalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Card Payments:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        
        return stackView
    }()
    
    let giftCardTotalStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.text = "Monetary Gift Card Redemptions:"
        label.font = MDCTypography.subheadFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        
        return stackView
    }()
    
    var dailyGrandTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Grand Total:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dailyHSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "HST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dailyGSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "GST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dailyPSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "PST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dailyOrdersCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Orders:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cashGrandTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Grand Total:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cashHSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "HST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cashGSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "GST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cashPSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "PST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cashOrdersCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Orders:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardGrandTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Grand Total:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardHSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "HST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardGSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "GST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardPSTTotalLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "PST:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var cardOrdersCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Orders:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var giftCardRedemptionValueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Redemption Value:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var giftCardRedemptionCountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.text = "Redemption Count:"
        label.font = MDCTypography.titleFont()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        self.view.addSubview(headerView)
        headerView.addSubview(printButton)
        headerView.addSubview(headerLabel)
        headerView.addSubview(datePicker)
        
        datePicker.maximumDate = Date()
        datePicker.minimumDate = Calendar.current.date(byAdding: .day, value: -5, to: datePicker.maximumDate!)!
        
        self.view.addSubview(reportView)
        reportView.addSubview(reportStack)
        reportStack.addArrangedSubview(section0)
        reportStack.addArrangedSubview(section1)
        reportStack.addArrangedSubview(section2)
        reportStack.addArrangedSubview(section3)
        reportStack.addArrangedSubview(section4)
        
        section0.addSubview(columnHeaderStack)
        section1.addSubview(grandTotalStack)
        section2.addSubview(cashTotalStack)
        section3.addSubview(cardTotalStack)
        section4.addSubview(giftCardTotalStack)
        
        grandTotalStack.addArrangedSubview(dailyGrandTotalLabel)
        grandTotalStack.addArrangedSubview(dailyHSTTotalLabel)
        grandTotalStack.addArrangedSubview(dailyGSTTotalLabel)
        grandTotalStack.addArrangedSubview(dailyPSTTotalLabel)
        grandTotalStack.addArrangedSubview(dailyOrdersCountLabel)
        
        cashTotalStack.addArrangedSubview(cashGrandTotalLabel)
        cashTotalStack.addArrangedSubview(cashHSTTotalLabel)
        cashTotalStack.addArrangedSubview(cashGSTTotalLabel)
        cashTotalStack.addArrangedSubview(cashPSTTotalLabel)
        cashTotalStack.addArrangedSubview(cashOrdersCountLabel)
        
        cardTotalStack.addArrangedSubview(cardGrandTotalLabel)
        cardTotalStack.addArrangedSubview(cardHSTTotalLabel)
        cardTotalStack.addArrangedSubview(cardGSTTotalLabel)
        cardTotalStack.addArrangedSubview(cardPSTTotalLabel)
        cardTotalStack.addArrangedSubview(cardOrdersCountLabel)

        giftCardTotalStack.addArrangedSubview(giftCardRedemptionValueLabel)
        giftCardTotalStack.addArrangedSubview(UILabel())
        giftCardTotalStack.addArrangedSubview(UILabel())
        giftCardTotalStack.addArrangedSubview(UILabel())
        giftCardTotalStack.addArrangedSubview(giftCardRedemptionCountLabel)
        
        refreshLabels()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: headerLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: headerLabel, attribute: .leading, relatedBy: .equal, toItem: headerView, attribute: .leading, multiplier: 1, constant: 100).isActive = true
        
        NSLayoutConstraint(item: printButton, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: printButton, attribute: .trailing, relatedBy: .equal, toItem: headerView, attribute: .trailing, multiplier: 1, constant: -20).isActive = true
        
        NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: datePicker, attribute: .centerX, relatedBy: .equal, toItem: headerView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: reportView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: reportView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 35).isActive = true
        NSLayoutConstraint(item: reportView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.9, constant: 0).isActive = true
        NSLayoutConstraint(item: reportView, attribute: .top, relatedBy: .equal, toItem: reportStack, attribute: .top, multiplier: 1, constant: -10).isActive = true
        NSLayoutConstraint(item: reportView, attribute: .bottom, relatedBy: .equal, toItem: reportStack, attribute: .bottom, multiplier: 1, constant: 10).isActive = true
        
        NSLayoutConstraint(item: reportStack, attribute: .leading, relatedBy: .equal, toItem: reportView, attribute: .leading, multiplier: 1, constant: 10).isActive = true
        NSLayoutConstraint(item: reportStack, attribute: .trailing, relatedBy: .equal, toItem: reportView, attribute: .trailing, multiplier: 1, constant: -10).isActive = true
        
        NSLayoutConstraint(item: columnHeaderStack, attribute: .top, relatedBy: .equal, toItem: section0, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: columnHeaderStack, attribute: .leading, relatedBy: .equal, toItem: section0, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: columnHeaderStack, attribute: .trailing, relatedBy: .equal, toItem: section0, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: columnHeaderStack, attribute: .bottom, relatedBy: .equal, toItem: section0, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: grandTotalStack, attribute: .top, relatedBy: .equal, toItem: section1, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: grandTotalStack, attribute: .leading, relatedBy: .equal, toItem: section1, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: grandTotalStack, attribute: .trailing, relatedBy: .equal, toItem: section1, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: grandTotalStack, attribute: .bottom, relatedBy: .equal, toItem: section1, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: cashTotalStack, attribute: .top, relatedBy: .equal, toItem: section2, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cashTotalStack, attribute: .leading, relatedBy: .equal, toItem: section2, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cashTotalStack, attribute: .trailing, relatedBy: .equal, toItem: section2, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cashTotalStack, attribute: .bottom, relatedBy: .equal, toItem: section2, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: cardTotalStack, attribute: .top, relatedBy: .equal, toItem: section3, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardTotalStack, attribute: .leading, relatedBy: .equal, toItem: section3, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardTotalStack, attribute: .trailing, relatedBy: .equal, toItem: section3, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: cardTotalStack, attribute: .bottom, relatedBy: .equal, toItem: section3, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint(item: giftCardTotalStack, attribute: .top, relatedBy: .equal, toItem: section4, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: giftCardTotalStack, attribute: .leading, relatedBy: .equal, toItem: section4, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: giftCardTotalStack, attribute: .trailing, relatedBy: .equal, toItem: section4, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: giftCardTotalStack, attribute: .bottom, relatedBy: .equal, toItem: section4, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        newDateSet()
    }
    
    func printReport() {
        NIMBUS.Print?.printDailyReport(reportDate: reportDate)
    }
    
    func emailReport() {
        
    }
    
    func newDateSet(){
        reportDate = datePicker.date
    }
    
    func refreshLabels(){
        dailyGrandTotalLabel.text = dailyReportValues?.fullSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2)
        dailyHSTTotalLabel.text = dailyReportValues?.fullSummary?.taxes.hst?.toString(asMoney: true, toDecimalPlaces: 2)
        dailyGSTTotalLabel.text = dailyReportValues?.fullSummary?.taxes.gst?.toString(asMoney: true, toDecimalPlaces: 2)
        dailyPSTTotalLabel.text =  dailyReportValues?.fullSummary?.taxes.pst?.toString(asMoney: true, toDecimalPlaces: 2)
        dailyOrdersCountLabel.text = "x" + String(describing: dailyReportValues?.fullSummary?.ordersCount ?? 0)
        
        cashGrandTotalLabel.text = dailyReportValues?.cashSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2)
        cashHSTTotalLabel.text = dailyReportValues?.cashSummary?.taxes.hst?.toString(asMoney: true, toDecimalPlaces: 2)
        cashGSTTotalLabel.text = dailyReportValues?.cashSummary?.taxes.gst?.toString(asMoney: true, toDecimalPlaces: 2)
        cashPSTTotalLabel.text =  dailyReportValues?.cashSummary?.taxes.pst?.toString(asMoney: true, toDecimalPlaces: 2)
        cashOrdersCountLabel.text = "x" + String(describing: dailyReportValues?.cashSummary?.ordersCount ?? 0)
        
        cardGrandTotalLabel.text = dailyReportValues?.creditDebitCardSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2)
        cardHSTTotalLabel.text = dailyReportValues?.creditDebitCardSummary?.taxes.hst?.toString(asMoney: true, toDecimalPlaces: 2)
        cardGSTTotalLabel.text = dailyReportValues?.creditDebitCardSummary?.taxes.gst?.toString(asMoney: true, toDecimalPlaces: 2)
        cardPSTTotalLabel.text =  dailyReportValues?.creditDebitCardSummary?.taxes.pst?.toString(asMoney: true, toDecimalPlaces: 2)
        cardOrdersCountLabel.text = "x" + String(describing: dailyReportValues?.creditDebitCardSummary?.ordersCount ?? 0)
        
        giftCardRedemptionValueLabel.text = dailyReportValues?.giftCardSummary?.grandTotal.toString(asMoney: true, toDecimalPlaces: 2)
        giftCardRedemptionCountLabel.text = "x" + String(describing: dailyReportValues?.giftCardSummary?.ordersCount ?? 0)
    }

}
