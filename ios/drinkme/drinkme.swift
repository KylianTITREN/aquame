//
//  drinkme.swift
//  drinkme
//
//  Created by Kylian Titren on 06/06/2024.
//

import WidgetKit
import SwiftUI

struct WidgetData: Decodable {
   var glasses: String
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), glasses: "Placeholder")
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, glasses: "0 verre")
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
      var entries: [SimpleEntry] = []
             
             let userDefaults = UserDefaults(suiteName: "group.drinkme")
             let entryDate = Date()
             
             if let savedData = userDefaults?.string(forKey: "drinked") {
                 let decoder = JSONDecoder()
                 if let data = savedData.data(using: .utf8), let parsedData = try? decoder.decode(WidgetData.self, from: data) {
                     let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: entryDate)!
                     let entry = SimpleEntry(date: nextRefresh, configuration: ConfigurationAppIntent(), glasses: parsedData.glasses)
                     entries.append(entry)
                 } else {
                     print("Could not parse data")
                 }
             } else {
                 let nextRefresh = Calendar.current.date(byAdding: .minute, value: 5, to: entryDate)!
                 let entry = SimpleEntry(date: nextRefresh, configuration: ConfigurationAppIntent(), glasses: "Aucun verre trouvé")
                 entries.append(entry)
             }
             
             return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let glasses: String
}

struct drinkmeEntryView : View {
    var entry: Provider.Entry

  var body: some View {
        HStack {
          VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
              Image("splash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
                .padding(.trailing, 10)
              Text(entry.glasses)
                .foregroundColor(Color(red: 1.00, green: 0.59, blue: 0.00))
                .font(Font.system(size: 21, weight: .bold, design: .rounded))
                .padding(.leading, -8.0)
            }
            .padding(.top, 10.0)
            .frame(maxWidth: .infinity)
            Text("Ajoute un verre !")
              .foregroundColor(Color(red: 0.69, green: 0.69, blue: 0.69))
              .font(Font.system(size: 14))
              .frame(maxWidth: .infinity)
            Image("bubbles")
              .renderingMode(.original)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: .infinity)
            
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
}

struct drinkme: Widget {
    let kind: String = "drinkme"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            drinkmeEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

extension ConfigurationAppIntent {
  fileprivate static var smiley: ConfigurationAppIntent {
          let intent = ConfigurationAppIntent()
          intent.favoriteEmoji = "🥱"
          return intent
      }
      
      fileprivate static var starEyes: ConfigurationAppIntent {
          let intent = ConfigurationAppIntent()
          intent.favoriteEmoji = "😴"
          return intent
      }
}

#Preview(as: .systemSmall) {
    drinkme()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, glasses: "Widget preview")
    SimpleEntry(date: .now, configuration: .starEyes, glasses: "Widget preview")
}
