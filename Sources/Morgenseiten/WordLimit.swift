/// Word counting and clamping for the fixed-length page.
enum WordLimit {
    /// The number of words a finished page has. No more, no less.
    static let target = 750

    /// Counts whitespace-separated words.
    static func count(_ text: String) -> Int {
        text.split(whereSeparator: \.isWhitespace).count
    }

    /// Returns `text` cut off right before the word that would exceed `limit`.
    /// Text at or below the limit is returned unchanged.
    static func clamp(_ text: String, to limit: Int = target) -> String {
        var words = 0
        var insideWord = false
        for index in text.indices {
            if text[index].isWhitespace {
                insideWord = false
            } else if !insideWord {
                if words == limit {
                    return String(text[..<index])
                }
                words += 1
                insideWord = true
            }
        }
        return text
    }
}
