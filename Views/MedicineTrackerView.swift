import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()
    var name: String
    var completed = false
}

class TaskList: ObservableObject {
    @Published var tasks: [Task] {
        didSet {
            if let encoded = try? JSONEncoder().encode(tasks) {
                UserDefaults.standard.set(encoded, forKey: "tasks")
            }
        }
    }
    @Published var newTask = ""
    
    init() {
        if let tasksData = UserDefaults.standard.data(forKey: "tasks") {
            if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
                self.tasks = decodedTasks
                return
            }
        }
        self.tasks = []
        createList()
    }

    func createList() {
        let item1 = Task(name: "Örnek ilaç")
        
        tasks.append(contentsOf: [item1])
    }
}

struct MedicineTrackerView: View {
    
    @StateObject var taskList: TaskList = TaskList()
    @State var isEditing: Bool = false
    
    var body: some View {
        
        NavigationView {
            List {
                
//                Adding tasks
                Section(header: Text("İlaç ekle")) {
                    HStack {
                        TextField("İlaç ismi", text: $taskList.newTask)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .submitLabel(.done)
                            .onSubmit {
                                addNewTask()
                            }

                        Button(action: {
                            addNewTask()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }

//                Tasks
                Section(header: Text("İlaçlarım")) {
                    ForEach(taskList.tasks) { task in
                        HStack {
                            Text(task.name)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button("Sil") {
                                        deleteItem(id: task.id)
                                    }
                                    .tint(.red)
                                    Button("İşaretle") {
                                        checkItem(id: task.id)
                                    }
                                    .tint(.green)
                                }
                                .submitLabel(.done)
                                .onSubmit {
                                    addNewTask()
                                }
                            Spacer()

                            if task.completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            checkItem(id: task.id)
                        }
                    }
                    .onMove(perform: { i, newOffset in
                        taskList.tasks.move(fromOffsets: i, toOffset: newOffset)
                    })
                    .onDelete(perform: { i in
                        taskList.tasks.remove(atOffsets: i)
                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("İlaç Listem")
            .environment(\.editMode, .constant(isEditing ? EditMode.active : EditMode.inactive))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Kaydet" : "Düzenle")
                    }
                }
            }
        }
        
    }
    
    func deleteItem(id: UUID) {
        if let index = taskList.tasks.firstIndex(where: { $0.id == id }) {
            taskList.tasks.remove(at: index)
        }
    }
    
    func checkItem(id: UUID) {
        if let index = taskList.tasks.firstIndex(where: { $0.id == id }) {
            taskList.tasks[index].completed.toggle()
        }
    }
    
    func addNewTask() {
            guard !taskList.newTask.isEmpty else { return }
            
            taskList.tasks.append(Task(name: taskList.newTask))
            taskList.newTask = ""
        }

}




struct MedicineTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        MedicineTrackerView()
    }
}
