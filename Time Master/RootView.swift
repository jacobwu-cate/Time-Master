//
//  ContentView.swift
//  Time Master
//
//  Created by Academia on 6/15/20.
//  Copyright © 2020 JW. All rights reserved.
//

import SwiftUI

class TimeManager: ObservableObject {
    struct LogItem: Identifiable, Hashable {
        var id = UUID()
        var start: String
        var end: String
        var duration: String
        var date: String
        var title: String
        var tag: String
    }
    
    @Published var entireLog: [LogItem] = [LogItem(start: "12:00 AM", end: "2:00 AM", duration: "120", date: "Jun 15, 2020", title: "Hello", tag: "World"), LogItem(start: "12:00 PM", end: "13:00 PM", duration: "60", date: "Jun 16, 2020", title: "Hola", tag: "Mundo")]
    @Published var tags: [String] = ["Mind", "Body", "Fun", "Community", "Other"]
    var todayLog: [LogItem] {
        entireLog.filter( {$0.date == todayDate()} )
    }
    
    func getLog(filterBy: (LogItem)->Bool) -> [LogItem] {
        return entireLog.filter( filterBy )
    }
    
    func totalMinutes() -> String {
        return String(entireLog.reduce(0, { $0 + Int($1.duration)!})) // TODO: Fix
    }
    
    func addEntry(start: String, end: String, duration: String, date: String, title: String, tag: String) {
        self.entireLog.append(LogItem(start: start, end: end, duration: duration, date: date, title: title, tag: tag))
    }
    
    func todayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        let date = formatter.string(from: Date())
        return date
    }
    
    func displayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E | MMM d, y"
        let date = formatter.string(from: Date())
        return date
    }
    
    func greetingMessage() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        let morningGreeting = formatter.string(from: Date()) == "AM"
        if morningGreeting {
            return "Good morning!"
        } else {
            return "Good afternoon!"
        }
    }
    
    func allDates() -> [String] {
        var dates: [String] = []
        for logItem in entireLog {
            if !dates.contains(logItem.date) {
                dates.append(logItem.date)
            }
        }
        return dates
    }
    
    func allTags() -> [String] {
        var tags: [String] = []
        for logItem in entireLog {
            if !tags.contains(logItem.tag) {
                tags.append(logItem.tag)
            }
        }
        return tags
    }
}

struct TodayView: View {
    @EnvironmentObject var timeManager: TimeManager
    
    var body: some View {
        VStack {
            HStack {
                Text(timeManager.greetingMessage()).bold()
                Spacer()
                Text("\(timeManager.totalMinutes()) min Logged total")
                Spacer()
            }.padding(.horizontal)
            List(timeManager.todayLog) { logItem in
                HStack {
                    Image(systemName: logItem.start[logItem.start.index(logItem.start.endIndex, offsetBy: -2)] == "A" ? "sun.max.fill": "moon.stars")
                    VStack {
                        Text(logItem.title).font(.title)
                        HStack {
                            Text("\(logItem.start) - \(logItem.end) (\(logItem.duration) min)") // TODO: Fix interval
                            Spacer()
                            Text(logItem.tag)
                        }
                    }.padding(.horizontal)
                }
            }
            Spacer()
        }
    }
}

struct ByDateView: View {
    @EnvironmentObject var timeManager: TimeManager
    var date: String
    
    var body: some View {
        VStack {
            HStack {
                Text(timeManager.greetingMessage()).bold()
                Spacer()
                Text("\(timeManager.totalMinutes()) min Logged total")
                Spacer()
            }.padding(.horizontal)
            List(timeManager.getLog {
                $0.date == date
            }) { logItem in
                HStack {
                    Image(systemName: logItem.start[logItem.start.index(logItem.start.endIndex, offsetBy: -2)] == "A" ? "sun.max.fill": "moon.stars")
                    VStack {
                        Text(logItem.title).font(.title)
                        HStack {
                            Text("\(logItem.start) - \(logItem.end) (\(logItem.duration) min)") // TODO: Fix interval
                            Spacer()
                            Text(logItem.tag)
                        }
                    }.padding(.horizontal)
                }
            }
            Spacer()
        }
    }
}

struct ByTagView: View {
    @EnvironmentObject var timeManager: TimeManager
    var tag: String
    
    var body: some View {
        VStack {
            HStack {
                Text(timeManager.greetingMessage()).bold()
                Spacer()
                Text("\(timeManager.totalMinutes()) min Logged total")
                Spacer()
            }.padding(.horizontal)
            List(timeManager.getLog {
                $0.tag == tag
            }) { logItem in
                HStack {
                    Image(systemName: logItem.start[logItem.start.index(logItem.start.endIndex, offsetBy: -2)] == "A" ? "sun.max.fill": "moon.stars")
                    VStack {
                        Text(logItem.title).font(.title)
                        HStack {
                            Text("\(logItem.start) - \(logItem.end) (\(logItem.duration) min)") // TODO: Fix interval
                            Spacer()
                            Text(logItem.tag)
                        }
                    }.padding(.horizontal)
                }
            }
            Spacer()
        }
    }
}


struct SearchView: View {
    @EnvironmentObject var timeManager: TimeManager
    @State var searchText: String = ""
    @State var showCancelButton: Bool = true
    @State var showingDetail = false
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("search", text: $searchText, onEditingChanged: { isEditing in
                        self.showCancelButton = true
                    }, onCommit: {
                        print("onCommit")
                    }).foregroundColor(.primary)
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                    }
                } // Search Bar
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                if showCancelButton {
                    Button("Cancel") {
                        UIApplication.shared.endEditing()
                        self.searchText = ""
                        self.showCancelButton = false
                    }
                    .foregroundColor(Color(.systemBlue))
                }
            } // Search Bar + Cancel Button
                .padding(.horizontal)
                .navigationBarHidden(true)
            List { ForEach(timeManager.entireLog.filter{$0.start.contains(searchText) || $0.end.contains(searchText) || $0.duration.contains(searchText) || $0.date.contains(searchText) || $0.title.contains(searchText) || $0.tag.contains(searchText) || searchText == ""}, id:\.self) { logItem in
                Button(action: {
                    self.showingDetail.toggle()
                }) {
                    HStack {
                        Image(systemName: logItem.start[logItem.start.index(logItem.start.endIndex, offsetBy: -2)] == "A" ? "sun.max.fill": "moon.stars")
                        VStack {
                            Text(logItem.title).font(.title)
                            HStack {
                                Text("\(logItem.start) - \(logItem.end) (\(logItem.duration) min)")
                                Spacer()
                                Text(logItem.tag)
                            }
                        }.padding(.horizontal)
                    }
                }.sheet(isPresented: self.$showingDetail) {
                    DetailLogView(logItem: logItem)
                }
                }
            }
        }
    }
}

struct DetailLogView: View {
    var logItem: TimeManager.LogItem
    
    var body: some View {
        HStack {
            Image(systemName: logItem.start[logItem.start.index(logItem.start.endIndex, offsetBy: -2)] == "A" ? "sun.max.fill": "moon.stars")
            VStack {
                Text(logItem.title).font(.title)
                HStack {
                    Text("\(logItem.start) - \(logItem.end) (\(logItem.duration) min)") // TODO: Fix interval
                    Spacer()
                    Text(logItem.tag)
                }
            }.padding(.horizontal)
        }
    }
}

struct PastView: View {
    @EnvironmentObject var timeManager: TimeManager
    @State var viewOption: String = ""
    let allOptions = ["By date", "By tag", "Search"]
    var body: some View {
        VStack {
            Text("History").font(.headline)
            HStack {
                Spacer()
                Picker("Tag", selection: self.$viewOption) {
                    ForEach(allOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Spacer()
            }
            Group {
                if viewOption == "By date" {
                    List(timeManager.allDates(), id: \.self) { date in
                        NavigationLink(destination: ByDateView(date: date)) {
                            Text(date)
                        }
                    }
                } else if viewOption == "By tag" {
                    List(timeManager.allTags(), id: \.self) { tag in
                        Text(tag)
                        NavigationLink(destination: ByTagView(tag: tag)) {
                            Text(tag)
                        }
                    }
                } else {
                    SearchView()
                }
            }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var timeManager: TimeManager
    var todayView = TodayView()
    var pastView = PastView()
    @State var showEntryView = false
    @State var tabSelection: Int = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $tabSelection) {
                todayView
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("Today")
                }
                .tag(0)
                pastView
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("History")
                }
                .tag(1)
            }
            .navigationBarItems(trailing:
                Button(action: { self.showEntryView.toggle() }) {
                    Text("Add Entry")
                }.sheet(isPresented: $showEntryView) {
                    EntryView().environmentObject(self.timeManager)
            })
                .navigationBarTitle(timeManager.displayDate())
                .navigationBarHidden(tabSelection == 1 ? true : false)
        }
    }
}

struct EntryView: View {
    @EnvironmentObject var timeManager: TimeManager
    @Environment(\.presentationMode) var presentationMode
    @State var startTime: Date = Date()
    @State var endTime: Date = Date()
    @State var title: String = ""
    @State var tag: String = ""
    @State var otherTag: String = ""
    var startTimeStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let time = formatter.string(from: startTime)
        return time
    }
    var endTimeStr: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let time = formatter.string(from: endTime)
        return time
    }
    var duration: String {
        let interval = endTime.timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate
        let intervalMinutes = Int( round( interval / 60 ) )
        return String(intervalMinutes)
    }
    var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        let date = formatter.string(from: Date())
        return date
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                HStack { // TODO: Tag multiline
                    Picker("Tag", selection: self.$tag) {
                        ForEach(timeManager.tags, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                Group {
                    if tag == "Other" {
                        TextField("Other", text: $otherTag)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                    }
                }
                HStack {
                    Text("Start Time")
                    DatePicker("Please enter a time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }.padding()
                HStack {
                    Text("End time")
                    DatePicker("Please enter a time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }.padding()
                Spacer()
            }.navigationBarTitle(Text("New Entry"), displayMode: .inline)
                .navigationBarItems(leading: Button("Cancel") {
                    self.presentationMode.wrappedValue.dismiss()
                    }, trailing: Button("Done") {
                        if self.title == "" {
                            self.title = "Untitled"
                        }
                        if self.tag == "" {
                            self.tag = "Untagged"
                        }
                        self.timeManager.addEntry(start: self.startTimeStr, end: self.endTimeStr, duration: self.duration, date: self.date, title: self.title, tag: self.tag)
                        self.presentationMode.wrappedValue.dismiss()
                } ) // TODO: Functionality
        } // TODO: Other tag
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    @EnvironmentObject var timeManager: TimeManager
    static var previews: some View {
        Group {
            RootView().environmentObject(TimeManager())
            EntryView().environmentObject(TimeManager())
        }
    }
}
