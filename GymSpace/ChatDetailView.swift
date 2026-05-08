// ChatDetailView.swift

import SwiftUI
import PhotosUI

struct ChatDetailView: View {
    @Environment(AppState.self) private var appState
    let otherUser: GymUser

    @State private var messageText  = ""
    @State private var longPressId: String? = nil
    @State private var showSchedule = false
    @State private var scheduleDate = Date().addingTimeInterval(86400)
    @State private var scheduleDone = false

    private var messages: [ChatMessage] {
        appState.getMessages(for: otherUser.id)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(groupedItems, id: \.id) { item in
                            switch item.kind {
                            case .dateSeparator(let label):
                                DateSeparator(label: label)
                                    .padding(.vertical, 6)
                            case .message(let msg):
                                if let sid = msg.sessionId {
                                    SessionProposalCard(sessionId: sid)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .id(msg.id)
                                } else if let imagePath = msg.imagePath, !imagePath.isEmpty {
                                    let isSent = msg.senderId == appState.currentUserId
                                    ImageBubbleView(imagePath: imagePath, isSent: isSent, timestamp: msg.timestamp)
                                        .id(msg.id)
                                } else {
                                    let isSent = msg.senderId == appState.currentUserId
                                    MessageBubbleView(
                                        message: msg,
                                        isSent: isSent,
                                        onLongPress: { longPressId = msg.id }
                                    )
                                    .id(msg.id)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                .onAppear {
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            InputBar(text: $messageText, onSend: sendMessage, onImageData: sendImage)
        }
        .navigationTitle(otherUser.username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSchedule = true } label: {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
        .confirmationDialog("Message Options", isPresented: Binding(
            get: { longPressId != nil },
            set: { if !$0 { longPressId = nil } }
        )) {
            if let id = longPressId,
               let msg = messages.first(where: { $0.id == id }),
               msg.senderId == appState.currentUserId {
                Button("Delete Message", role: .destructive) {
                    appState.deleteMessage(id: id)
                    longPressId = nil
                }
            }
            Button("Cancel", role: .cancel) { longPressId = nil }
        }
        .sheet(isPresented: $showSchedule) {
            ScheduleSheet(otherUser: otherUser, isPresented: $showSchedule)
        }
    }

    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        appState.sendMessage(to: otherUser.id, text: trimmed)
        messageText = ""
    }

    private func sendImage(_ data: Data) {
        appState.sendImageMessage(to: otherUser.id, imageData: data)
    }

    private struct GroupedItem: Identifiable {
        let id: String
        let kind: Kind
        enum Kind {
            case dateSeparator(String)
            case message(ChatMessage)
        }
    }

    private var groupedItems: [GroupedItem] {
        var result: [GroupedItem] = []
        var lastDate = ""
        for msg in messages {
            let dateLabel = msg.timestamp.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
            if dateLabel != lastDate {
                result.append(GroupedItem(id: "date_\(dateLabel)", kind: .dateSeparator(dateLabel)))
                lastDate = dateLabel
            }
            result.append(GroupedItem(id: msg.id, kind: .message(msg)))
        }
        return result
    }
}

private struct ImageBubbleView: View {
    @Environment(AppState.self) private var appState
    let imagePath: String
    let isSent: Bool
    let timestamp: Date

    private var imageData: Data? {
        appState.loadImageData(filename: imagePath)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isSent { Spacer(minLength: 60) }

            VStack(alignment: isSent ? .trailing : .leading, spacing: 3) {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.65)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 160, height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        )
                }
                Text(timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isSent { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

private struct MessageBubbleView: View {
    let message: ChatMessage
    let isSent: Bool
    let onLongPress: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isSent { Spacer(minLength: 60) }

            VStack(alignment: isSent ? .trailing : .leading, spacing: 3) {
                Text(message.isDeleted ? "Message deleted" : message.text)
                    .font(.body)
                    .foregroundColor(isSent ? .white : .primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isSent ? Color(hex: "#00D47A") : Color(.secondarySystemBackground))
                    .clipShape(
                        BubbleShape(isSent: isSent)
                    )
                    .frame(
                        maxWidth: UIScreen.main.bounds.width * 0.72,
                        alignment: isSent ? .trailing : .leading
                    )

                Text(message.timestamp.formatted(.dateTime.hour().minute()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            .contentShape(Rectangle())
            .onLongPressGesture { onLongPress() }

            if !isSent { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 1)
    }
}

private struct BubbleShape: Shape {
    let isSent: Bool
    private let r: CGFloat = 18

    func path(in rect: CGRect) -> Path {
        let (minX, maxX, minY, maxY) = (rect.minX, rect.maxX, rect.minY, rect.maxY)
        let tlr: CGFloat = r
        let trr: CGFloat = r
        let blr: CGFloat = isSent ? r : 4
        let brr: CGFloat = isSent ? 4 : r

        var p = Path()
        p.move(to: CGPoint(x: minX + tlr, y: minY))
        p.addLine(to: CGPoint(x: maxX - trr, y: minY))
        p.addArc(center: CGPoint(x: maxX - trr, y: minY + trr), radius: trr,
                 startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: maxX, y: maxY - brr))
        p.addArc(center: CGPoint(x: maxX - brr, y: maxY - brr), radius: brr,
                 startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: minX + blr, y: maxY))
        p.addArc(center: CGPoint(x: minX + blr, y: maxY - blr), radius: blr,
                 startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: minX, y: minY + tlr))
        p.addArc(center: CGPoint(x: minX + tlr, y: minY + tlr), radius: tlr,
                 startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}

private struct DateSeparator: View {
    let label: String
    var body: some View {
        Text(label)
            .font(.caption2).foregroundStyle(.secondary)
            .padding(.horizontal, 12).padding(.vertical, 4)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}

private struct InputBar: View {
    @Binding var text: String
    let onSend: () -> Void
    let onImageData: (Data) -> Void

    @State private var photoItem: PhotosPickerItem? = nil

    var body: some View {
        HStack(spacing: 10) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
            }
            .onChange(of: photoItem) { _, newItem in
                guard let item = newItem else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        await MainActor.run { onImageData(data) }
                    }
                    await MainActor.run { photoItem = nil }
                }
            }

            TextField("Message…", text: $text, axis: .vertical)
                .lineLimit(1...5)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))

            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.secondary : Color(hex: "#00D47A"))
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

private struct SessionProposalCard: View {
    @Environment(AppState.self) private var appState
    let sessionId: String

    private var session: GymSession? {
        appState.sessions.first { $0.id == sessionId }
    }
    private var isSender: Bool {
        session?.createdBy == appState.currentUserId
    }

    var body: some View {
        if let session = session {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color(hex: "#00D47A"))
                        .font(.system(size: 18, weight: .semibold))
                    Text("Gym Session Proposal")
                        .font(.subheadline).fontWeight(.semibold)
                    Spacer()
                    StatusPill(status: session.status)
                }
                .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 10)

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.dateTime.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .font(.subheadline).fontWeight(.medium)
                        Text(session.dateTime.formatted(.dateTime.hour().minute()))
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)

                if session.status == "pending" && !isSender {
                    Divider()
                    HStack(spacing: 0) {
                        Button {
                            appState.declineSession(id: sessionId)
                        } label: {
                            Text("Decline")
                                .font(.subheadline).fontWeight(.semibold)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)

                        Divider().frame(height: 44)

                        Button {
                            appState.confirmSession(id: sessionId)
                        } label: {
                            Text("Accept")
                                .font(.subheadline).fontWeight(.semibold)
                                .frame(maxWidth: .infinity).padding(.vertical, 12)
                                .foregroundStyle(Color(hex: "#00D47A"))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if session.status == "pending" && isSender {
                    Divider()
                    Text("Waiting for response…")
                        .font(.caption).foregroundStyle(.secondary)
                        .padding(.vertical, 10)
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct StatusPill: View {
    let status: String
    var body: some View {
        let (label, color): (String, Color) = switch status {
        case "confirmed": ("Accepted", Color(hex: "#00D47A"))
        case "declined":  ("Declined", .red)
        default:          ("Pending",  .orange)
        }
        Text(label)
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

private struct ScheduleSheet: View {
    @Environment(AppState.self) private var appState
    let otherUser: GymUser
    @Binding var isPresented: Bool
    @State private var date = Date().addingTimeInterval(86400)
    @State private var done = false

    var body: some View {
        NavigationStack {
            if done {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 56))
                        .foregroundStyle(Color(hex: "#00D47A"))
                    Text("Session Proposed!").font(.title2).bold()
                    Text("\(otherUser.username) will be notified.")
                        .foregroundStyle(.secondary).multilineTextAlignment(.center)
                    Button("Done") { isPresented = false }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(hex: "#00D47A"))
                }
                .padding()
            } else {
                Form {
                    Section("Pick a date & time") {
                        DatePicker("Session", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                    }
                    Section {
                        Button("Propose Session") {
                            appState.scheduleSession(with: otherUser.id, dateTime: date)
                            done = true
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color(hex: "#00D47A"))
                        .fontWeight(.semibold)
                    }
                }
                .navigationTitle("Schedule Session")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { isPresented = false }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
