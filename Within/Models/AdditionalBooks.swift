import Foundation

extension SampleContent {
    static let additionalBooks: [WithinBook] = [
        WithinBook(
            id: "enchiridion",
            title: "The Enchiridion",
            author: "Epictetus · T. W. Higginson translation",
            year: "c. 125 CE",
            category: "Stoicism",
            symbol: "scope",
            overview: "A compact handbook on judgment, agency, desire, role, and freedom. Its central distinction separates what answers to our choices from what does not. Read with care: Stoic responsibility is not a reason to deny material conditions, trauma, illness, or injustice.",
            sourceURL: URL(string: "https://www.gutenberg.org/ebooks/45109")!,
            lessons: [
                BookLesson(title: "What is within your power", summary: "Epictetus begins by sorting experience into choices that answer to us and conditions that do not. The exercise redirects effort without pretending that outside events are unimportant.", quotation: "There are things which are within our power, and there are things which are beyond our power.", interpretation: "Agency becomes clearer when facts, other people's decisions, and outcomes are separated from the response you can choose now.", practice: "Make two columns: mine to influence, and not mine to command."),
                BookLesson(title: "Judgment adds the second wound", summary: "The handbook repeatedly distinguishes an event from the conclusion built around it. The goal is not emotional numbness but a more accurate pause before action.", quotation: "Men are disturbed, not by things, but by the principles and notions which they form concerning things.", interpretation: "A painful event can matter deeply while one catastrophic interpretation remains open to examination.", practice: "Write one fact and one interpretation as separate sentences."),
                BookLesson(title: "Practice without display", summary: "Epictetus mistrusts philosophy used as performance. Principles become credible through conduct under ordinary pressure.", quotation: "Never call yourself a philosopher, nor talk a great deal among the unlearned about theorems.", interpretation: "Quiet repetition often changes character more reliably than announcing an identity.", practice: "Keep one value-aligned promise today without posting about it."),
            ]
        ),
        WithinBook(
            id: "tao-te-ching",
            title: "Tao Te Ching",
            author: "Laozi · James Legge translation",
            year: "ancient text",
            category: "Taoism",
            symbol: "water.waves",
            overview: "Eighty-one brief chapters about the Way, virtue, non-forcing, leadership, desire, simplicity, and the strength of yielding. James Legge's nineteenth-century translation is public domain but reflects its period; modern translations may read key terms differently.",
            sourceURL: URL(string: "https://www.gutenberg.org/ebooks/216")!,
            lessons: [
                BookLesson(title: "The usefulness of yielding", summary: "Water is a recurring image for responsiveness: it supports life, moves around obstacles, and does not need rigid display to remain powerful.", quotation: "The highest excellence is like that of water.", interpretation: "Flexibility is not surrender. It is the ability to preserve direction while adapting form.", practice: "Find one conflict where a smaller, calmer response would carry more force."),
                BookLesson(title: "Knowing yourself", summary: "The text contrasts knowledge of others with the harder work of seeing one's own motives, limits, and habits clearly.", quotation: "He who knows other men is discerning; he who knows himself is intelligent.", interpretation: "Self-knowledge becomes useful when it guides conduct rather than becoming endless self-analysis.", practice: "Name one reliable trigger and one response you want to rehearse."),
                BookLesson(title: "Complete the work, release the claim", summary: "Several chapters praise action that does not cling to ownership, applause, or permanent status.", quotation: "The work is accomplished, and there is no resting in it (as an achievement).", interpretation: "Let a completed action become part of life instead of proof that must be defended forever.", practice: "Finish one useful task and resist checking for recognition."),
            ]
        ),
        WithinBook(
            id: "as-a-man-thinketh",
            title: "As a Man Thinketh",
            author: "James Allen",
            year: "1903",
            category: "Character",
            symbol: "brain.head.profile",
            overview: "A short work about thought, habit, purpose, and serenity. Its strongest lesson is that repeated attention can influence conduct. Its weakest passages overstate personal control and can imply that hardship is deserved; social conditions, illness, and chance remain real.",
            sourceURL: URL(string: "https://www.gutenberg.org/ebooks/4507")!,
            lessons: [
                BookLesson(title: "Thought and character", summary: "Allen argues that repeated thought leaves traces in action and character. That claim is most useful when applied to trainable habits, not used to blame people for every condition.", quotation: "A man is literally what he thinks, his character being the complete sum of all his thoughts.", interpretation: "Attention influences choices, but no person mentally creates every hardship that reaches them.", practice: "Choose one recurring thought to answer with a more accurate sentence."),
                BookLesson(title: "Purpose organizes attention", summary: "A chosen direction reduces the number of impulses competing for the same time and energy.", quotation: "Until thought is linked with purpose there is no intelligent accomplishment.", interpretation: "Purpose does not guarantee an outcome. It gives the next decision a reference point.", practice: "Write one purpose for this season and one action that expresses it today."),
                BookLesson(title: "Calm as trained conduct", summary: "The closing essay treats serenity as a result of patient self-observation rather than passive temperament.", quotation: "Calmness of mind is one of the beautiful jewels of wisdom.", interpretation: "Steadiness grows through many ordinary pauses and repairs, not one dramatic insight.", practice: "Delay one reactive message for ten minutes and revise it once."),
            ]
        ),
        WithinBook(
            id: "analects",
            title: "The Analects",
            author: "Confucius · James Legge translation",
            year: "ancient text",
            category: "Ethics",
            symbol: "person.2",
            overview: "A layered collection of sayings and conversations about learning, ethical conduct, friendship, family, ritual, leadership, and character. It was compiled across generations; the voice is not one modern self-help system, and its historical social hierarchy deserves context.",
            sourceURL: URL(string: "https://www.gutenberg.org/ebooks/3330")!,
            lessons: [
                BookLesson(title: "Learning by returning", summary: "The opening connects learning with perseverance, practice, and the pleasure of sharing inquiry with others.", quotation: "Is it not pleasant to learn with a constant perseverance and application?", interpretation: "Knowledge becomes character when it is revisited and applied under changing conditions.", practice: "Review yesterday's lesson and write one way it changed your action."),
                BookLesson(title: "Examine conduct", summary: "The text repeatedly turns ethics into daily review: trustworthiness, sincerity, and whether teaching was actually practiced.", quotation: "I daily examine myself on three points.", interpretation: "Reflection is useful when it is specific enough to guide repair, not a ritual of self-attack.", practice: "Ask: Where was I sincere, where did I avoid, and what needs repair?"),
                BookLesson(title: "Character in relationship", summary: "Confucian cultivation is social. Virtue becomes visible in reliability, respect, reciprocity, and the way power is used.", quotation: "The superior man bends his attention to what is radical.", interpretation: "Work on the root behavior that shapes many interactions instead of polishing one appearance.", practice: "Choose one relationship where reliability matters and keep one clear promise."),
            ]
        ),
        WithinBook(
            id: "emerson-essays",
            title: "Essays — First Series",
            author: "Ralph Waldo Emerson",
            year: "1841",
            category: "Transcendentalism",
            symbol: "bolt",
            overview: "Essays on history, self-reliance, compensation, spiritual laws, friendship, prudence, heroism, intellect, and art. Emerson's language can be electrifying and excessive at once. Read self-reliance as examined judgment, not isolation from support or responsibility.",
            sourceURL: URL(string: "https://www.gutenberg.org/ebooks/2944")!,
            lessons: [
                BookLesson(title: "Trust examined judgment", summary: "Self-reliance asks the reader to stop replacing direct thought with automatic conformity. It does not make every impulse wise.", quotation: "Trust thyself: every heart vibrates to that iron string.", interpretation: "Trust grows alongside evidence, correction, and accountability rather than in opposition to them.", practice: "Name one belief you hold from examination and one you have only inherited."),
                BookLesson(title: "Consistency can become a cage", summary: "Emerson challenges the demand to perform an old identity after new evidence has arrived.", quotation: "A foolish consistency is the hobgoblin of little minds.", interpretation: "Integrity includes the ability to revise a view honestly and explain what changed.", practice: "Update one outdated rule you still follow only to look consistent."),
                BookLesson(title: "Friendship requires truth and tenderness", summary: "The friendship essay values both affection and the independence that lets people meet without performance.", quotation: "A friend is a person with whom I may be sincere.", interpretation: "Closeness grows when honesty is paired with care rather than used as permission for cruelty.", practice: "Tell one trusted person something true, specific, and kind."),
            ]
        ),
        WithinBook(
            id: "republic",
            title: "The Republic",
            author: "Plato · Benjamin Jowett translation",
            year: "c. 375 BCE",
            category: "Philosophy",
            symbol: "building.columns",
            overview: "A long dialogue about justice, education, power, knowledge, desire, political order, and the formation of character. Its arguments should be studied, not treated as a modern blueprint; several political proposals are authoritarian and historically distant from contemporary rights.",
            sourceURL: URL(string: "https://www.gutenberg.org/ebooks/1497")!,
            lessons: [
                BookLesson(title: "Justice within the person", summary: "The dialogue links public justice to the organization of appetite, ambition, and judgment within a life.", quotation: "The just man does not permit the several elements within him to interfere with one another.", interpretation: "A workable life coordinates needs and values rather than letting the loudest impulse rule every decision.", practice: "Name what appetite wants, what status wants, and what considered judgment recommends."),
                BookLesson(title: "Education turns attention", summary: "The cave image presents learning as a difficult reorientation from familiar appearances toward clearer understanding.", quotation: "The power and capacity of learning exists in the soul already.", interpretation: "Education is not only adding facts. It changes what the mind is prepared to notice and question.", practice: "Find one source that challenges a comfortable assumption and summarize it fairly."),
                BookLesson(title: "Beginnings shape formation", summary: "The education discussion emphasizes that early repeated stories and habits influence character.", quotation: "The beginning is the most important part of any work.", interpretation: "The opening conditions matter, but they do not make later revision impossible.", practice: "Prepare the first two minutes of tomorrow's most important practice tonight."),
            ]
        ),
    ]
}
