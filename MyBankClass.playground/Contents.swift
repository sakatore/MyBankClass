//: Playground - noun: a place where people can play

// 銀行の取引明細からデータをグラフ化するツールを作成
// MyBankクラスによって取引内容を記録する

import UIKit
import Foundation

/*
// 取引日を取得したい

let nowDate = Date()
print(nowDate)

let formatter = DateFormatter()
formatter.dateFormat = "yyyy/MM/dd"

let formattedDate = formatter.string(from: nowDate as Date)
print(formattedDate)

let date = formatter.date(from: "2016/08/26")
print(date)

//let dateFormatter = DateFormatter()
//dateFormatter.dateStyle = .mediumStyle
//dateFormatter.timeStyle = .noStyle
//
//let date = Date(timeIntervalSinceReferenceDate: 118800)
//// Japanese Locale (ja_JP)
formatter.locale = Locale(identifier: "ja_JP")
print(formatter.string(from: date!)) // 2001/01/02
*/

//var ary = [10, 20, 30 , 40, 50]
//for i in ary.reversed() {
//    print(i)
//}


//var ary = [28, 4, 21, 59, 36, 24, 44]
//let sortAry = ary.sorted()
//ary.insert(3, at: 0)


//
//let formatter = DateFormatter()
//formatter.dateFormat = "yyyy/MM/dd"
//
//let testDate = [
//formatter.date(from: "2016/09/30"),
//formatter.date(from: "2016/07/30"),
//formatter.date(from: "2016/02/22"),
//formatter.date(from: "2016/10/04"),
//formatter.date(from: "2016/03/03"),]
//
//let sortDate = testDate.sorted{
//    switch ($0, $1) {
//    case let (.error(aCode), .error(bCode)):
//        return aCode < bCode
//        
//    case (.ok, .ok): return false
//        
//    case (.error, .ok): return true
//    case (.ok, .error): return false
//    }
//}


//let ary = [1, 2 ,3 ,4 ,5, 6]
//ary.first
//
//var ary2: [Int] = []
//ary2.first
//
//var ary3: [Int] = [1, 2, nil, 4, 5].flatMap{ $0 }
//ary3
//let a: [Int] = ary3.flatMap{ $0 }
//a


// MARK: - Bankクラス

class Bank {
    // 銀行名
    let bankName: String
    // 初期残高を記録
    let firstBalance: Int
    // 残高
    var balance: Int
    // 入出金データ
    var bankStatement: [BankingData] = []
    
    
    init(name: String, firstBalance: Int) {
        bankName = name
        self.firstBalance = firstBalance
        balance = self.firstBalance
    }
    
    // 取引を追加し、入出金データに格納
    func addBanking(date: Date?, banking: BankingData.Banking, amount: Int?) {
        guard let date = date, let amount = amount else {
            return
        }
        
        let data = BankingData(date: date, banking: banking, amount: amount)
        
        // 日付順にデータを並び替えて格納する
        // 配列が空でなければ
        if bankStatement.isEmpty {
            bankStatement.append(data)
            
        } else {
            let count = bankStatement.count
            var loop = 1
            
            while date < bankStatement[count - loop].date {
                
                loop += 1
                
                if count < loop {
                    break
                }
            }
            
            bankStatement.insert(data, at: count - loop + 1)
            
        }
        
        // 残高を求める
        if case .payment = banking {
            balance += amount
        } else {
            balance -= amount
        }
    }
    
    // 過去全ての取引を計算する
    func getTotalBalance() -> Int {
        return bankStatement.reduce(0) { totalBalance, data in
            switch data.banking {
            case .payment:      return totalBalance + data.amount
            case .withdrawal:   return totalBalance - data.amount
            }
        }
    }
    
    // 指定した期間の取引を計算する
    func getTotalBalance(fromDate: Date?, toDate: Date?) -> Int? {
        guard let fromDate = fromDate, let toDate = toDate else {
            return nil
        }
        
        guard fromDate < toDate else {
            print("期間設定に誤りがあります。")
            return nil
        }
        
        return bankStatement.filter { data in
            fromDate < data.date && data.date < toDate
            }.reduce(0) { totalBalance, data in
                switch data.banking {
                case .payment:      return totalBalance! + data.amount
                case .withdrawal:   return totalBalance! - data.amount
                }
        }
        
    }
    
    // 取引明細を一覧で表示
    func printBankStatement() {
        bankStatement.forEach { data in
            print("\(data.date), \(data.banking), \(data.amount)")
        }
    }
    
    // 指定した日にちの取引のみを表示
    func printBankStatement(fromDate: Date?) {
        guard let fromDate = fromDate else {
            return
        }
        
        bankStatement.forEach { data in
            if data.date == fromDate {
                print("\(data.date), \(data.banking), \(data.amount)")
            }
        }
    }
    
    // 指定した期間の取引のみを表示
    func printBankStatement(fromDate: Date?, toDate: Date?) {
        guard let fromDate = fromDate, let toDate = toDate else {
            return
        }
        
        // fromData < toDateでなかった場合は強制終了
        guard fromDate < toDate else {
            print("期間設定に誤りがあります。")
            return
        }
        
        bankStatement.filter { data in
            fromDate < data.date && data.date < toDate
            }.forEach { data in
                print("\(data.date), \(data.banking), \(data.amount)")
        }
        
    }
    
    // 取引日の最新を得る
    var newDate: Date? {
        if bankStatement.isEmpty {
            return nil
        } else {
            return bankStatement.last?.date
        }
    }
    
    // 取引日の最古を得る
    var oldDate: Date? {
        if bankStatement.isEmpty {
            return nil
        } else {
            return bankStatement.first?.date
        }
    }
    
    // 指定した期間内での外部からの収入を得る
    func getIncome(fromDate: Date?, toDate: Date?) -> Int? {
        guard let fromDate = fromDate, let toDate = toDate else {
            return nil
        }
        
        // fromDate < toDateでなかった場合は強制終了
        guard fromDate < toDate else {
            print("期間設定に誤りがあります。")
            return nil
        }
        
        return bankStatement.filter { data in
            fromDate < data.date && data.date < toDate
            }.reduce(0) { income, data in
                guard let income = income else { return nil }
                
                if data.isIncome {
                    return income + data.amount
                } else {
                    return income
                }
        }
    }
}


// 銀行取引の詳細をまとめたデータ
class BankingData {
    let date: Date
    let banking: Banking
    let amount: Int
    // 外部からの入金かどうか
    var isIncome = false
    
    init(date: Date, banking: Banking, amount: Int) {
        self.date = date
        self.banking = banking
        self.amount = amount
    }
    
    func setIncome() {
        if case .payment = banking {
            isIncome = true
            print("\(date),\(amount)を\(isIncome)")
        }
    }
    
    // 銀行取引の種類
    enum Banking {
        // 入金、出金
        case payment, withdrawal
    }
}


// MARK: - Bankクラスをまとめて扱うクラス

class BankManager {
    var banks: [Bank] = []
    var totalBalance = 0
    
    // 取引期間の最新の日付
    var mostNewDate: Date? {
        return datePeriod.last
    }
    // 取引期間の最古の日付
    var mostOldDate: Date? {
        return datePeriod.first
    }
    
    
    init(banks: [Bank]) {
        self.banks = banks
        totalBalance = getSumTotalBalance()
    }
    
    // 銀行を追加
    func addBank(bank: Bank) {
        banks.append(bank)
        totalBalance = getSumTotalBalance()
    }
    
    // 合計残高を算出
    func getSumTotalBalance() -> Int {
        return banks.reduce(0) { total, bank in
            total + bank.getTotalBalance()
        }
    }
    
    // 指定期間の収支バランスを求める
    func getSumTotalBalance(fromDate: Date?, toDate: Date?) -> Int? {
        guard let fromDate = fromDate, let toDate = toDate else {
            return nil
        }
        
        return banks.flatMap { $0.getTotalBalance(fromDate: fromDate, toDate: toDate) }.reduce(0, +)
    }
    
    // 全ての取引期間の最新値と最古値の候補を返す
    var datePeriod: [Date] {
        // 要素にnilが入り得る
        var period: [Date?] = []
        
        // 各Bankの最新値と最古値を格納
        banks.forEach { bank in
            period.append(bank.oldDate)
            period.append(bank.newDate)
        }
        
        // nilを除いたDate配列を作る
        let datePeriod: [Date] = period.flatMap { $0 }
        
        // 日付順に並び替える
        let sortPeriod = datePeriod.sorted(by: { (date1: Date, date2: Date) -> Bool in
            return date1 < date2
        })
        
        return sortPeriod
    }
    
    // 指定した期間内での外部からの収入を得る
    func getTotalIncome(fromDate: Date?, toDate: Date?) -> Int? {
        guard let fromDate = fromDate, let toDate = toDate else {
            return nil
        }
        
        return banks.flatMap { $0.getIncome(fromDate: fromDate, toDate: toDate) }.reduce(0, +)
        
//        return banks.reduce(0) { income, bank in
//            income + bank.getIncome(fromDate: fromDate, toDate: toDate)
//        }
    }
    
}


// 銀行を追加
let myBank1 = Bank(name: "みずほ銀行", firstBalance: 100000)
let myBank2 = Bank(name: "三菱東京UFJ銀行", firstBalance: 200000)
let myBank3 = Bank(name: "多摩信用金庫", firstBalance: 1200000)

// StringをDateに変換するためのFormatterを用意
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy/MM/dd"

// 取引を追加
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/04"), banking: .withdrawal, amount: 24000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/10"), banking: .payment, amount: 30000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/20"), banking: .withdrawal, amount: 15000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/25"), banking: .withdrawal, amount: 10000)

myBank1.addBanking(date: dateFormatter.date(from: "2016/09/04"), banking: .withdrawal, amount: 27000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/09/10"), banking: .payment, amount: 30000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/09/23"), banking: .withdrawal, amount: 5000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/09/30"), banking: .withdrawal, amount: 10000)

myBank1.addBanking(date: dateFormatter.date(from: "2016/07/06"), banking: .withdrawal, amount: 10000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/10/06"), banking: .withdrawal, amount: 20000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/08/15"), banking: .withdrawal, amount: 10000)
myBank1.addBanking(date: dateFormatter.date(from: "2016/03/03"), banking: .withdrawal, amount: 10000)

for month in 1...12 {
    myBank2.addBanking(date: dateFormatter.date(from: "2016/\(month)/04"), banking: .payment, amount: 80000)
}

//myBank2.addBanking(date: dateFormatter.date(from: "2016/08/04"), banking: .Payment, amount: 80000)  // 外部からの収入
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/10"), banking: .withdrawal, amount: 50000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/13"), banking: .withdrawal, amount: 20000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/17"), banking: .withdrawal, amount: 10000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/08/22"), banking: .withdrawal, amount: 20000)

//myBank2.addBanking(date: dateFormatter.date(from: "2016/09/04"), banking: .Payment, amount: 80000)  // 外部からの収入
myBank2.addBanking(date: dateFormatter.date(from: "2016/09/11"), banking: .withdrawal, amount: 30000)
myBank2.addBanking(date: dateFormatter.date(from: "2016/09/21"), banking: .withdrawal, amount: 20000)

myBank3.addBanking(date: dateFormatter.date(from: "2016/08/05"), banking: .withdrawal, amount: 10000)

myBank3.addBanking(date: dateFormatter.date(from: "2016/09/09"), banking: .withdrawal, amount: 13000)
myBank3.addBanking(date: dateFormatter.date(from: "2016/09/21"), banking: .withdrawal, amount: 29000)



// 残高と取引明細を表示
print("残高：\(myBank2.balance)")
// dateをprintした場合、日付がずれる
myBank2.printBankStatement()
print()
myBank1.printBankStatement(fromDate: dateFormatter.date(from: "2016/09/02"))
print()
myBank1.printBankStatement(fromDate: dateFormatter.date(from: "2016/09/02"), toDate: dateFormatter.date(from: "2016/09/13"))


print()
print("残高：\(myBank1.balance)")
print("残高：\(myBank2.balance)")
print("残高：\(myBank3.balance)")



// 全ての銀行を管理
let superBank = BankManager(banks: [myBank1, myBank2, myBank3])
print("合計残高：\(superBank.totalBalance)")

print()
print(myBank1.getTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))
print(myBank2.getTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))
print(myBank3.getTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))

print()
print("8月の収支：\(superBank.getSumTotalBalance(fromDate: dateFormatter.date(from: "2016/08/01"), toDate: dateFormatter.date(from: "2016/09/01")))")
print("9月の収支：\(superBank.getSumTotalBalance(fromDate: dateFormatter.date(from: "2016/09/01"), toDate: dateFormatter.date(from: "2016/10/01")))")



// 機能追加
//myBank2.oldDate
//myBank2.newDate
//
//let myBank4 = Bank(name: "西内銀行", firstBalance: 30000)
//superBank.addBank(bank: myBank4)
//
//myBank4.bankStatement
//myBank4.bankStatement.first
//myBank4.bankStatement.last
//
//myBank4.oldDate
//
//superBank.mostOldDate
//superBank.mostNewDate


// 外部からの入金を設定
myBank2.bankStatement[5].setIncome()
// 指定期間の収入を得る
myBank2.getIncome(fromDate: dateFormatter.date(from: "2016/06/01"), toDate: dateFormatter.date(from: "2016/07/01"))

superBank.getTotalIncome(fromDate: dateFormatter.date(from: "2016/06/01"), toDate: dateFormatter.date(from: "2016/07/01"))









