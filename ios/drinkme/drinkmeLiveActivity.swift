//
//  drinkmeLiveActivity.swift
//  drinkme
//
//  Created by Kylian Titren on 06/06/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct drinkmeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct drinkmeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: drinkmeAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension drinkmeAttributes {
    fileprivate static var preview: drinkmeAttributes {
        drinkmeAttributes(name: "World")
    }
}

extension drinkmeAttributes.ContentState {
    fileprivate static var smiley: drinkmeAttributes.ContentState {
        drinkmeAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: drinkmeAttributes.ContentState {
         drinkmeAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: drinkmeAttributes.preview) {
   drinkmeLiveActivity()
} contentStates: {
    drinkmeAttributes.ContentState.smiley
    drinkmeAttributes.ContentState.starEyes
}
