import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: TaskStore
    @State private var showingAddTask = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(TaskCategory.allCases, id: \.self) { category in
                    let categoryTasks = store.tasks.filter { $0.category == category }
                    if !categoryTasks.isEmpty {
                        Section(header: Text(category.rawValue)) {
                            ForEach(categoryTasks) { task in
                                TaskRow(task: task)
                            }
                            .onDelete { offsets in
                                let indices = offsets.map { index in
                                    store.tasks.firstIndex(where: { $0.id == categoryTasks[index].id })!
                                }
                                store.remove(at: IndexSet(indices))
                            }
                        }
                    }
                }
            }
            .navigationTitle("HomeKeeper")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .overlay {
                if store.tasks.isEmpty {
                    ContentUnavailableView(
                        "タスクがありません",
                        systemImage: "house",
                        description: Text("+ ボタンからタスクを追加してください")
                    )
                }
            }
        }
    }
}

struct TaskRow: View {
    @EnvironmentObject var store: TaskStore
    let task: HouseholdTask

    var body: some View {
        HStack {
            Button(action: { store.toggleComplete(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if task.notificationEnabled {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}
