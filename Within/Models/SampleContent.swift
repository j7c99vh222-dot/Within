import Foundation

enum SampleContent {
    static let quotes: [(text: String, author: String)] = [
        ("You have power over your mind, not outside events.", "Marcus Aurelius"),
        ("No person is free who is not master of himself.", "Epictetus"),
        ("Peace comes from within. Do not seek it without.", "Dhammapada"),
        ("The obstacle in the path becomes the path.", "Marcus Aurelius"),
        ("A journey of a thousand miles begins beneath one's feet.", "Laozi"),
        ("What you are is what you have been. What you will be is what you do now.", "Early Buddhist teaching"),
        ("The mind is its own place, and in itself can make a heaven of hell.", "John Milton"),
        ("Waste no more time arguing what a good person should be. Be one.", "Marcus Aurelius"),
        ("When anger rises, think of the consequences.", "Confucius"),
        ("First say to yourself what you would be; then do what you have to do.", "Epictetus"),
        ("Nothing can bring you peace but yourself.", "Ralph Waldo Emerson"),
        ("The secret of getting ahead is getting started.", "Often attributed to Mark Twain")
    ]

    static let facts: [String] = [
        "Slower breathing can increase heart-rate variability for many people, but comfort matters more than hitting a perfect count.",
        "Dietary fiber is fermented by gut microbes into compounds that help support the intestinal barrier.",
        "Regular sleep and wake times strengthen the body's circadian timing system.",
        "Brief movement can interrupt rumination even when motivation has not arrived first.",
        "Naming an emotion precisely can make it easier to choose an appropriate response.",
        "Protein and fiber generally improve meal satisfaction more than relying on willpower alone.",
        "Mindfulness can help some people relate differently to distress; it is a skill, not a cure-all.",
        "An urge usually changes in intensity over time. Delaying action creates room for another choice."
    ]

    static let focusCards: [FocusArea: [LessonCard]] = [
        .anxiety: [
            LessonCard(title: "The alarm is not always the danger", body: "Anxiety can activate a real protective response even when the present situation is not an emergency. Arguing with the feeling often adds a second struggle.", practice: "Name five neutral details around you, then lengthen the exhale without forcing it.", sourceLabel: "NIMH anxiety overview", sourceURL: URL(string: "https://www.nimh.nih.gov/health/topics/anxiety-disorders")!),
            LessonCard(title: "Avoidance teaches fear to stay", body: "Avoidance brings short-term relief, which can reinforce the belief that the situation was unsafe. Gradual, supported approach practice can update that learning.", practice: "Choose the smallest safe version of something you have been avoiding.", sourceLabel: "APA clinical guidance", sourceURL: URL(string: "https://www.apa.org/topics/anxiety")!),
            LessonCard(title: "Make the thought more accurate", body: "CBT does not demand positive thinking. It asks whether a thought is complete, useful, and supported by the available evidence.", practice: "Write the feared prediction, the evidence for it, and one equally credible alternative.", sourceLabel: "NHS CBT overview", sourceURL: URL(string: "https://www.nhs.uk/mental-health/talking-therapies-medicine-treatments/talking-therapies-and-counselling/cognitive-behavioural-therapy-cbt/overview/")!)
        ],
        .depression: [
            LessonCard(title: "Action can come before motivation", body: "Low mood often reduces activity, reward, and connection. Behavioral activation starts with small scheduled actions instead of waiting to feel ready.", practice: "Pick one five-minute action tied to care, mastery, or connection.", sourceLabel: "NICE depression guidance", sourceURL: URL(string: "https://www.nice.org.uk/guidance/ng222")!),
            LessonCard(title: "A hard day is not a verdict", body: "Depression can make temporary states feel global and permanent. Tracking exceptions helps restore a more complete picture.", practice: "Record one moment that was even slightly less heavy and what was different.", sourceLabel: "NIMH depression overview", sourceURL: URL(string: "https://www.nimh.nih.gov/health/topics/depression")!)
        ],
        .addiction: [
            LessonCard(title: "An urge is a wave, not an order", body: "Cravings rise, peak, and change. Creating time and distance can reduce automatic behavior without requiring the urge to vanish.", practice: "Delay ten minutes, change rooms, and contact one safe person.", sourceLabel: "SAMHSA recovery resources", sourceURL: URL(string: "https://www.samhsa.gov/find-support")!),
            LessonCard(title: "Change the environment", body: "Recovery is not only a test of character. Access, cues, stress, sleep, and social context all shape behavior.", practice: "Remove one cue and make one helpful action easier to reach.", sourceLabel: "NIDA treatment principles", sourceURL: URL(string: "https://nida.nih.gov/publications/principles-drug-addiction-treatment-research-based-guide-third-edition/principles-effective-treatment")!)
        ],
        .relationships: [
            LessonCard(title: "Regulate before repair", body: "When the nervous system is highly activated, listening and flexible thinking become harder. A pause can protect the conversation.", practice: "Say: I care about this, and I need twenty minutes before I can answer well.", sourceLabel: "APA relationship resources", sourceURL: URL(string: "https://www.apa.org/topics/relationships")!)
        ],
        .growth: [
            LessonCard(title: "Identity follows repeated evidence", body: "Large declarations fade quickly. Small actions repeated in context provide believable evidence about who you are becoming.", practice: "Choose a promise that takes under ten minutes and keep it today.", sourceLabel: "Behavior change overview", sourceURL: URL(string: "https://www.apa.org/topics/behavioral-health")!)
        ],
        .health: [
            LessonCard(title: "Build the boring foundation", body: "Regular meals, sufficient sleep, movement, protein, fiber, and medical care are not glamorous, but they influence energy and resilience together.", practice: "Add one minimally processed plant food to the next meal.", sourceLabel: "Dietary Guidelines", sourceURL: URL(string: "https://www.dietaryguidelines.gov/")!)
        ]
    ]

    static let meditations: [MeditationPreset] = [
        MeditationPreset(id: "anxiety", title: "Steady the alarm", purpose: "Anxiety and panic", duration: 6, symbol: "wind", cues: ["Find a place where your body can be supported.", "Let your eyes rest on one ordinary object.", "Breathe in gently. Let the exhale take a little longer.", "Notice the ground holding you. You do not have to solve every thought.", "Name what is here without turning it into a verdict.", "Return to the room slowly. Choose one safe next action."]),
        MeditationPreset(id: "sleep", title: "Release the day", purpose: "Sleep preparation", duration: 10, symbol: "moon.stars", cues: ["Let the day be finished for now.", "Soften the jaw, shoulders, hands, and belly.", "Allow the breath to happen without managing it.", "Thoughts can pass without becoming assignments.", "Rest attention on the feeling of support beneath you."]),
        MeditationPreset(id: "urge", title: "Ride the urge", purpose: "Cravings and impulses", duration: 8, symbol: "water.waves", cues: ["Move away from anything you could act on automatically.", "Feel where the urge appears in the body.", "Notice its edges, temperature, and movement.", "An urge is information, not an instruction.", "Let this wave change while you contact someone safe."]),
        MeditationPreset(id: "spiritual", title: "Witness consciousness", purpose: "Contemplative practice", duration: 12, symbol: "sparkles", cues: ["Sit with dignity and ease.", "Let sensations, thoughts, and feelings come and go.", "Notice that awareness is present before each thought and after it passes.", "Practice non-grasping: nothing to chase, nothing to push away.", "Carry this wider attention into one act of compassion."])
    ]

    static let books: [WithinBook] = [
        WithinBook(id: "meditations", title: "Meditations", author: "Marcus Aurelius", year: "c. 170–180", category: "Stoicism", symbol: "column", overview: "Private philosophical notes from a Roman emperor practicing attention, responsibility, mortality, and service. The text is not a polished system; it is a record of repeatedly returning to principles under pressure.", sourceURL: URL(string: "https://www.gutenberg.org/ebooks/2680")!, lessons: [
            BookLesson(title: "Guard the ruling mind", summary: "Marcus distinguishes events from the judgments added to them. Freedom begins in the interval where interpretation can be examined.", quotation: "You have power over your mind, not outside events.", interpretation: "This is not a claim that circumstances do not matter. It is a reminder to place effort where agency remains.", practice: "Write the event in one sentence, then write the judgment separately."),
            BookLesson(title: "Work for the common good", summary: "Stoic discipline is social, not merely private calm. Character is expressed through fairness, patience, and useful action toward other people.", quotation: "What is not good for the swarm is not good for the bee.", interpretation: "Self-improvement becomes incomplete when it ignores responsibility and community.", practice: "Choose one useful action that benefits someone besides you."),
            BookLesson(title: "Remember impermanence", summary: "Mortality appears throughout the notes as a reason to become present and stop postponing honorable action.", quotation: "You could leave life right now.", interpretation: "The point is not fear. It is clarity about what deserves today's limited attention.", practice: "Remove one trivial resentment from today's schedule.")
        ]),
        WithinBook(id: "art-of-war", title: "The Art of War", author: "Sun Tzu", year: "c. 5th century BCE", category: "Strategy", symbol: "shield", overview: "A compact work on preparation, intelligence, positioning, leadership, and avoiding needless conflict. Its most useful modern lessons concern systems and judgment, not treating ordinary life as warfare.", sourceURL: URL(string: "https://www.gutenberg.org/ebooks/132")!, lessons: [
            BookLesson(title: "Win before the conflict", summary: "Preparation, accurate information, and favorable conditions matter more than dramatic effort after a crisis begins.", quotation: "Victorious warriors win first and then go to war.", interpretation: "Build environments where the better action is easier before willpower is tested.", practice: "Prepare tomorrow's first helpful action tonight."),
            BookLesson(title: "Strength without force", summary: "The highest strategy avoids expensive confrontation. Flexibility and understanding can accomplish more than direct pressure.", quotation: "Supreme excellence consists in breaking resistance without fighting.", interpretation: "In personal change, reducing triggers can outperform repeatedly battling them.", practice: "Change one condition instead of arguing with yourself."),
            BookLesson(title: "Know the terrain", summary: "Action must fit the actual environment. Plans fail when they ignore timing, resources, limits, and feedback.", quotation: "Know the enemy and know yourself.", interpretation: "Treat the difficulty as a pattern to understand, not a moral defect.", practice: "List the time, place, emotion, and cue that usually precede the behavior.")
        ]),
        WithinBook(id: "dhammapada", title: "The Dhammapada", author: "Early Buddhist verses", year: "c. 3rd century BCE", category: "Buddhism", symbol: "leaf", overview: "A collection of concise verses about mind, conduct, craving, compassion, vigilance, and liberation. Traditions interpret the verses within a larger ethical and contemplative path.", sourceURL: URL(string: "https://www.gutenberg.org/ebooks/2017")!, lessons: [
            BookLesson(title: "Mind precedes action", summary: "Attention and intention shape how experience unfolds, but this is not a claim that suffering is deserved or imagined.", quotation: "All that we are is the result of what we have thought.", interpretation: "Repeated mental habits influence behavior and perception; they can be trained with patience.", practice: "Notice one thought without calling it true or false for three breaths."),
            BookLesson(title: "Hatred does not end hatred", summary: "Retaliation keeps hostility moving. Non-hatred interrupts the cycle while still allowing boundaries and protection.", quotation: "Hatred ceases not by hatred.", interpretation: "Compassion is not passive permission. It can include distance, truth, and refusal to harm.", practice: "Replace one rehearsed attack with a clear boundary sentence.")
        ]),
        WithinBook(id: "gita", title: "Bhagavad Gita", author: "Anonymous Sanskrit tradition", year: "c. 2nd century BCE", category: "Indian philosophy", symbol: "sparkles", overview: "A dialogue on action, duty, knowledge, devotion, discipline, and liberation. It belongs to a living religious tradition and deserves context beyond isolated motivational quotations.", sourceURL: URL(string: "https://www.gutenberg.org/ebooks/2388")!, lessons: [
            BookLesson(title: "Act without clinging", summary: "The Gita distinguishes committed action from attachment to controlling every result.", quotation: "Your right is to action alone, never to its fruits.", interpretation: "Care deeply about the work while accepting that outcomes involve conditions beyond one person's control.", practice: "Name the action that is yours and the outcome that is not fully yours."),
            BookLesson(title: "A steady mind", summary: "Equanimity is trained through practice, discernment, and less compulsive grasping at praise or avoidance of discomfort.", quotation: "Yoga is steadiness of mind.", interpretation: "Steadiness is responsive balance, not emotional numbness.", practice: "Pause before one habitual reaction and choose the next action deliberately.")
        ]),
        WithinBook(id: "walden", title: "Walden", author: "Henry David Thoreau", year: "1854", category: "Simple living", symbol: "tree", overview: "A literary experiment in deliberate living, attention, economy, nature, and independence. Its insights are valuable alongside honest awareness of Thoreau's social position and support network.", sourceURL: URL(string: "https://www.gutenberg.org/ebooks/205")!, lessons: [
            BookLesson(title: "Live deliberately", summary: "Thoreau asks what remains when inherited expectations and needless consumption are examined.", quotation: "I went to the woods because I wished to live deliberately.", interpretation: "Simplicity is a method for seeing priorities, not an aesthetic competition.", practice: "Remove one obligation that does not serve a real value."),
            BookLesson(title: "The cost is life", summary: "The price of an object includes the time and attention exchanged for it, not only money.", quotation: "The cost of a thing is the amount of life required to be exchanged for it.", interpretation: "Consumption decisions are also decisions about time.", practice: "Before one purchase, calculate the hours of work it represents.")
        ]),
        WithinBook(id: "time", title: "How to Live on 24 Hours a Day", author: "Arnold Bennett", year: "1910", category: "Self-development", symbol: "clock", overview: "A practical public-domain essay about reclaiming a modest portion of ordinary life for deliberate reading, reflection, and growth without pretending every hour can be optimized.", sourceURL: URL(string: "https://www.gutenberg.org/ebooks/2274")!, lessons: [
            BookLesson(title: "The daily allotment", summary: "Everyone receives the same twenty-four hours, but Bennett's useful point is not comparison. It is that a protected sliver can be reclaimed from automatic routine.", quotation: "You have to live on this twenty-four hours of daily time.", interpretation: "Consistency can begin with a small boundary rather than a complete life overhaul.", practice: "Protect twenty minutes for one chosen practice tomorrow."),
            BookLesson(title: "Begin without drama", summary: "Overambitious schedules often collapse. Bennett recommends an experiment small enough to survive ordinary life.", quotation: "Beware of undertaking too much at the start.", interpretation: "A sustainable beginning is more serious than an impressive beginning.", practice: "Cut your proposed habit in half and repeat it for seven days.")
        ])
    ] + additionalBooks
}
