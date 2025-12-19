import WidgetKit
import SwiftUI

// Basic WidgetKit entry for Todos. To activate:
// - Add a WidgetKit target to the Runner workspace
// - Add this file to the Widget extension target
// - Use an App Group and read values from UserDefaults(suiteName: <your app group>)

struct TodoEntry: TimelineEntry {
    let date: Date
    let count: Int
}

struct TodosProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), count: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> Void) {
        completion(TodoEntry(date: Date(), count: 0))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> Void) {
        // Read stored data from shared UserDefaults (App Group)
        let suiteName = "group.com.example.students_app" // replace with your app group
        let defaults = UserDefaults(suiteName: suiteName)
        var count = 0
        if let json = defaults?.string(forKey: "todos") {
            if json.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("[") {
                // crude parsing
                count = json.components(separatedBy: "},").count
            }
        } else if let countString = defaults?.string(forKey: "todos_count"), let n = Int(countString) {
            count = n
        }

        let entry = TodoEntry(date: Date(), count: count)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct TodosWidgetEntryView: View {
    var entry: TodoEntry

    var body: some View {
        ZStack {
            Color("WidgetBackground")
            VStack(alignment: .leading) {
                Text("Tasks")
                    .font(.headline)
                Text("\(entry.count)")
                    .font(.largeTitle)
                    .bold()
            }
            .padding()
            .foregroundColor(.white)
        }
    }
}

@main
struct TodosWidget: Widget {
    let kind: String = "TodosWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodosProvider()) { entry in
            TodosWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Todos")
        .description("Shows number of open tasks from the app")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
