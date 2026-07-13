import SwiftUI

struct RecoveryView: View {
    @EnvironmentObject private var app: AppModel
    @State private var urge = 4.0
    @State private var showingPlan = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Eyebrow(text: "Recovery and accountability")
                    Text("Protect the next choice.")
                        .font(.system(size: 35, weight: .medium, design: .serif))
                    Text("Recovery is not a test of worth. Treatment, medication, peer support, medical care, and environmental change can all matter.")
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                }

                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Urge intensity")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(urge))/10")
                            .font(.system(.title2, design: .serif))
                    }
                    Slider(value: $urge, in: 0...10, step: 1)
                    Text(urgeGuidance)
                        .font(.subheadline)
                        .foregroundStyle(palette.secondaryText)
                        .lineSpacing(4)
                    Button {
                        showingPlan = true
                    } label: {
                        Label("Open my ten-minute protection plan", systemImage: "shield.fill")
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(18)
                .withinSurface()

                VStack(spacing: 0) {
                    action("1", "Move", "Leave the cue, put down access, and move near another person.")
                    Divider().overlay(palette.line)
                    action("2", "Delay", "Set ten minutes. The decision can wait while the wave changes.")
                    Divider().overlay(palette.line)
                    action("3", "Connect", "Call a safe person, sponsor, peer, clinician, or treatment service early.")
                    Divider().overlay(palette.line)
                    action("4", "Escalate care", "Overdose risk, severe withdrawal, or immediate danger needs emergency medical help.")
                }
                .withinSurface()

                VStack(alignment: .leading, spacing: 12) {
                    Eyebrow(text: "Evidence-based help")
                    resource("SAMHSA find support", "https://www.samhsa.gov/find-support")
                    resource("FindTreatment.gov", "https://findtreatment.gov/")
                    resource("NIDA treatment principles", "https://nida.nih.gov/publications/principles-drug-addiction-treatment-research-based-guide-third-edition/principles-effective-treatment")
                    resource("Naloxone information", "https://www.cdc.gov/stop-overdose/caring/naloxone.html")
                }
                .padding(18)
                .withinSurface()

                Link(destination: URL(string: "https://988lifeline.org/")!) {
                    Label("Immediate danger or thoughts of self-harm: contact 988 or emergency services", systemImage: "heart.text.square")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(palette.danger)
                }
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Recovery")
        .navigationBarTitleDisplayMode(.inline)
        .withinScreen()
        .sheet(isPresented: $showingPlan) {
            RecoveryPlanSheet(urge: Int(urge))
                .environmentObject(app)
                .presentationDetents([.medium, .large])
        }
    }

    private var urgeGuidance: String {
        if urge >= 8 { return "Bring in another person now. Leave the triggering place, remove access, and use urgent help when safety or overdose risk is present." }
        if urge >= 5 { return "Delay, move, and connect. Do not stay alone with easy access while debating the urge." }
        return "Notice the urge before reacting. Name the cue and watch for even a small shift over the next five minutes."
    }

    private func action(_ number: String, _ title: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Text(number)
                .font(.caption.monospacedDigit())
                .foregroundStyle(palette.accent)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.headline)
                Text(text).font(.caption).foregroundStyle(palette.secondaryText)
            }
        }
        .padding(16)
    }

    private func resource(_ title: String, _ url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var palette: WithinPalette { .palette(for: app.theme) }
}

private struct RecoveryPlanSheet: View {
    @EnvironmentObject private var app: AppModel
    @Environment(\.dismiss) private var dismiss
    let urge: Int

    var body: some View {
        let palette = WithinPalette.palette(for: app.theme)
        VStack(alignment: .leading, spacing: 17) {
            Eyebrow(text: "Urge \(urge)/10 · ten-minute plan")
            Text("No decision while the wave is high.")
                .font(.system(size: 30, weight: .medium, design: .serif))
            Label("Move away from access and toward another person.", systemImage: "figure.walk")
            Label("Set a ten-minute timer and drink water if safe.", systemImage: "timer")
            Label("Call the person or service already in your plan.", systemImage: "phone")
            Label("Use emergency help for overdose, dangerous withdrawal, or immediate danger.", systemImage: "cross.case")
            Spacer()
            Button("I have moved to a safer place") { dismiss() }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(WithinBackground())
        .foregroundStyle(palette.text)
    }
}
