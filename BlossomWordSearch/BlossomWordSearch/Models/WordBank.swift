import Foundation

enum AppLanguage: String, Codable, CaseIterable {
    case en, tr

    /// The device / per-app language chosen in iOS Settings.
    static var system: AppLanguage {
        Locale.preferredLanguages.first?.hasPrefix("tr") == true ? .tr : .en
    }

    var flag: String { self == .tr ? "🇹🇷" : "🇬🇧" }
    var code: String { rawValue.uppercased() }

    func t(_ en: String, _ tr: String) -> String { self == .tr ? tr : en }
}

struct WordTheme {
    let title: String
    let words: [String]
}

/// All word content lives here — swap or extend these lists to change the game's vocabulary.
enum WordBank {
    static func themes(_ lang: AppLanguage) -> [WordTheme] { lang == .tr ? themesTR : themesEN }
    static func opposites(_ lang: AppLanguage) -> [(String, String)] { lang == .tr ? oppositesTR : oppositesEN }
    static func hiddenWords(_ lang: AppLanguage) -> [String] { lang == .tr ? hiddenWordsTR : hiddenWordsEN }

    /// Letters used to fill the empty cells.
    static func alphabet(_ lang: AppLanguage) -> [Character] {
        Array(lang == .tr ? "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ" : "ABCDEFGHIJKLMNOPRSTUVWY")
    }

    // MARK: English

    private static let themesEN: [WordTheme] = [
        WordTheme(title: "Flowers", words: ["ROSE", "TULIP", "LILY", "DAISY", "ORCHID", "IRIS", "LOTUS", "POPPY", "PEONY", "VIOLET", "JASMINE", "LILAC", "DAHLIA", "ASTER"]),
        WordTheme(title: "In the Garden", words: ["SEED", "SOIL", "RAKE", "HOSE", "SHOVEL", "BLOOM", "PETAL", "STEM", "ROOT", "LEAF", "WEED", "MULCH", "POT", "FENCE"]),
        WordTheme(title: "Fruits", words: ["APPLE", "PEAR", "MANGO", "GRAPE", "LEMON", "PEACH", "PLUM", "CHERRY", "BERRY", "KIWI", "MELON", "FIG", "LIME", "PAPAYA"]),
        WordTheme(title: "Animals", words: ["TIGER", "HORSE", "RABBIT", "EAGLE", "ZEBRA", "PANDA", "MOUSE", "SHEEP", "OTTER", "WHALE", "CAMEL", "LION", "BEAR", "WOLF"]),
        WordTheme(title: "Ocean", words: ["WAVE", "CORAL", "SHELL", "SHARK", "TIDE", "REEF", "SAND", "CRAB", "PEARL", "SQUID", "KELP", "SALT", "FISH", "BOAT"]),
        WordTheme(title: "Weather", words: ["RAIN", "SNOW", "CLOUD", "STORM", "WIND", "SUNNY", "FOG", "HAIL", "FROST", "MIST", "THUNDER", "BREEZE"]),
        WordTheme(title: "Kitchen", words: ["SPOON", "FORK", "KNIFE", "PLATE", "BOWL", "OVEN", "STOVE", "KETTLE", "PAN", "CUP", "MUG", "TOASTER"]),
        WordTheme(title: "Colors", words: ["RED", "BLUE", "GREEN", "YELLOW", "PURPLE", "ORANGE", "PINK", "BROWN", "BLACK", "WHITE", "GRAY", "TEAL", "AMBER"]),
        WordTheme(title: "Music", words: ["PIANO", "GUITAR", "DRUM", "FLUTE", "VIOLIN", "HARP", "SONG", "NOTE", "BEAT", "TEMPO", "CHORD", "MELODY"]),
        WordTheme(title: "Sports", words: ["SOCCER", "TENNIS", "GOLF", "RUGBY", "HOCKEY", "BOXING", "SKATE", "SKI", "SWIM", "POLO", "JUDO", "ARCHERY"]),
        WordTheme(title: "Space", words: ["STAR", "MOON", "PLANET", "COMET", "ORBIT", "GALAXY", "ROCKET", "MARS", "VENUS", "SATURN", "NEBULA", "ASTEROID"]),
        WordTheme(title: "Birds", words: ["ROBIN", "SPARROW", "OWL", "HAWK", "CROW", "DOVE", "PARROT", "SWAN", "FINCH", "CRANE", "HERON", "PIGEON"]),
        WordTheme(title: "Springtime", words: ["SPRING", "BLOSSOM", "NEST", "SUNSHINE", "MEADOW", "BUTTERFLY", "BEE", "HONEY", "GRASS", "POLLEN", "DEW", "SPROUT"]),
        WordTheme(title: "Trees", words: ["OAK", "PINE", "MAPLE", "BIRCH", "WILLOW", "CEDAR", "PALM", "ELM", "ASH", "FIR", "SPRUCE", "BAMBOO"]),
        WordTheme(title: "Tea Time", words: ["TEA", "CAKE", "SCONE", "SUGAR", "MILK", "CREAM", "COOKIE", "BISCUIT", "PASTRY", "JAM", "SAUCER", "KETTLE"]),
        WordTheme(title: "Good Feelings", words: ["HAPPY", "CALM", "JOY", "LOVE", "PEACE", "HOPE", "SMILE", "CHEER", "BLISS", "GRACE", "KIND", "GLAD"]),
    ]

    /// Twister levels: the clue is shown, its opposite is hidden in the grid.
    private static let oppositesEN: [(String, String)] = [
        ("HOT", "COLD"), ("DAY", "NIGHT"), ("UP", "DOWN"), ("BIG", "SMALL"), ("FAST", "SLOW"),
        ("OPEN", "CLOSED"), ("HAPPY", "SAD"), ("LIGHT", "DARK"), ("WET", "DRY"), ("YES", "NO"),
        ("OLD", "NEW"), ("NEAR", "FAR"), ("HARD", "SOFT"), ("HIGH", "LOW"), ("FULL", "EMPTY"),
        ("RICH", "POOR"), ("LOUD", "QUIET"), ("WIN", "LOSE"), ("TOP", "BOTTOM"), ("LEFT", "RIGHT"),
        ("EARLY", "LATE"), ("STRONG", "WEAK"), ("SWEET", "SOUR"), ("LOVE", "HATE"), ("PUSH", "PULL"),
        ("TALL", "SHORT"), ("THICK", "THIN"), ("CLEAN", "DIRTY"), ("FIRST", "LAST"), ("BEGIN", "END"),
        ("BUY", "SELL"), ("GIVE", "TAKE"), ("ASK", "ANSWER"), ("SUMMER", "WINTER"), ("NORTH", "SOUTH"),
        ("EAST", "WEST"), ("ENTER", "EXIT"), ("LAUGH", "CRY"), ("FRONT", "BACK"), ("INSIDE", "OUTSIDE"),
    ]

    /// Bonus levels: each found word reveals letters of one of these.
    private static let hiddenWordsEN: [String] = [
        "BLOOM", "PETAL", "GARDEN", "SPRING", "NECTAR", "POLLEN", "FLORA", "SUNNY", "BREEZE", "MEADOW",
    ]

    // MARK: Türkçe

    private static let themesTR: [WordTheme] = [
        WordTheme(title: "Çiçekler", words: ["GÜL", "LALE", "ZAMBAK", "PAPATYA", "ORKİDE", "SÜSEN", "NERGİS", "MENEKŞE", "YASEMİN", "LEYLAK", "KARANFİL", "SÜMBÜL", "GELİNCİK", "MANOLYA"]),
        WordTheme(title: "Bahçede", words: ["TOHUM", "TOPRAK", "TIRMIK", "HORTUM", "KÜREK", "ÇİÇEK", "YAPRAK", "SAP", "KÖK", "SAKSI", "ÇİT", "FİDAN", "TOMURCUK", "SULAMA"]),
        WordTheme(title: "Meyveler", words: ["ELMA", "ARMUT", "MANGO", "ÜZÜM", "LİMON", "ŞEFTALİ", "ERİK", "KİRAZ", "KAYISI", "KİVİ", "KAVUN", "İNCİR", "KARPUZ", "MUZ"]),
        WordTheme(title: "Hayvanlar", words: ["KAPLAN", "TAVŞAN", "KARTAL", "ZEBRA", "PANDA", "FARE", "KOYUN", "BALİNA", "DEVE", "ASLAN", "AYI", "KURT", "TİLKİ", "SİNCAP"]),
        WordTheme(title: "Deniz", words: ["DALGA", "MERCAN", "KABUK", "RESİF", "KUM", "YENGEÇ", "İNCİ", "AHTAPOT", "YOSUN", "TUZ", "BALIK", "TEKNE", "MARTI", "LİMAN"]),
        WordTheme(title: "Hava Durumu", words: ["YAĞMUR", "KAR", "BULUT", "FIRTINA", "RÜZGAR", "GÜNEŞ", "SİS", "DOLU", "AYAZ", "ŞİMŞEK", "GÖKKUŞAĞI", "ESİNTİ"]),
        WordTheme(title: "Mutfak", words: ["KAŞIK", "ÇATAL", "BIÇAK", "TABAK", "KASE", "FIRIN", "OCAK", "ÇAYDANLIK", "TAVA", "FİNCAN", "KUPA", "TENCERE"]),
        WordTheme(title: "Renkler", words: ["KIRMIZI", "MAVİ", "YEŞİL", "SARI", "MOR", "TURUNCU", "PEMBE", "KAHVE", "SİYAH", "BEYAZ", "GRİ", "LACİVERT", "BORDO"]),
        WordTheme(title: "Müzik", words: ["PİYANO", "GİTAR", "DAVUL", "FLÜT", "KEMAN", "ARP", "ŞARKI", "NOTA", "RİTİM", "BAĞLAMA", "AKOR", "MELODİ"]),
        WordTheme(title: "Spor", words: ["FUTBOL", "TENİS", "GOLF", "RAGBİ", "HOKEY", "BOKS", "KAYAK", "YÜZME", "JUDO", "OKÇULUK", "VOLEYBOL", "GÜREŞ"]),
        WordTheme(title: "Uzay", words: ["YILDIZ", "GEZEGEN", "YÖRÜNGE", "GALAKSİ", "ROKET", "MARS", "VENÜS", "SATÜRN", "NEBULA", "ASTEROİT", "UYDU", "METEOR"]),
        WordTheme(title: "Kuşlar", words: ["KUMRU", "SERÇE", "BAYKUŞ", "ŞAHİN", "KARGA", "GÜVERCİN", "PAPAĞAN", "KUĞU", "İSPİNOZ", "TURNA", "BALIKÇIL", "LEYLEK"]),
        WordTheme(title: "Bahar", words: ["BAHAR", "TOMURCUK", "YUVA", "GÜNEŞ", "ÇAYIR", "KELEBEK", "ARI", "BAL", "ÇİMEN", "POLEN", "ÇİY", "FİLİZ"]),
        WordTheme(title: "Ağaçlar", words: ["MEŞE", "ÇAM", "AKÇAAĞAÇ", "HUŞ", "SÖĞÜT", "SEDİR", "PALMİYE", "KARAAĞAÇ", "DİŞBUDAK", "KAVAK", "ÇINAR", "BAMBU"]),
        WordTheme(title: "Çay Saati", words: ["ÇAY", "PASTA", "KURABİYE", "ŞEKER", "SÜT", "KREMA", "BİSKÜVİ", "POĞAÇA", "REÇEL", "SİMİT", "BARDAK", "TABAK"]),
        WordTheme(title: "Güzel Duygular", words: ["MUTLU", "HUZUR", "NEŞE", "SEVGİ", "BARIŞ", "UMUT", "GÜLÜMSE", "SEVİNÇ", "ŞÜKÜR", "ZARAFET", "NAZİK", "KEYİF"]),
    ]

    private static let oppositesTR: [(String, String)] = [
        ("SICAK", "SOĞUK"), ("GECE", "GÜNDÜZ"), ("YUKARI", "AŞAĞI"), ("BÜYÜK", "KÜÇÜK"), ("HIZLI", "YAVAŞ"),
        ("AÇIK", "KAPALI"), ("MUTLU", "ÜZGÜN"), ("AYDINLIK", "KARANLIK"), ("ISLAK", "KURU"), ("EVET", "HAYIR"),
        ("ESKİ", "YENİ"), ("YAKIN", "UZAK"), ("SERT", "YUMUŞAK"), ("YÜKSEK", "ALÇAK"), ("DOLU", "BOŞ"),
        ("ZENGİN", "FAKİR"), ("SESLİ", "SESSİZ"), ("KAZAN", "KAYBET"), ("ÜST", "ALT"), ("SAĞ", "SOL"),
        ("ERKEN", "GEÇ"), ("GÜÇLÜ", "ZAYIF"), ("TATLI", "EKŞİ"), ("İT", "ÇEK"), ("UZUN", "KISA"),
        ("KALIN", "İNCE"), ("TEMİZ", "KİRLİ"), ("İLK", "SON"), ("BAŞLA", "BİTİR"), ("AL", "SAT"),
        ("SORU", "CEVAP"), ("YAZ", "KIŞ"), ("KUZEY", "GÜNEY"), ("DOĞU", "BATI"), ("GİRİŞ", "ÇIKIŞ"),
        ("GÜL", "AĞLA"), ("ÖN", "ARKA"), ("İÇ", "DIŞ"), ("AĞIR", "HAFİF"), ("ZOR", "KOLAY"), ("DOĞRU", "YANLIŞ"),
    ]

    private static let hiddenWordsTR: [String] = [
        "ÇİÇEK", "BAHAR", "BAHÇE", "NEKTAR", "POLEN", "LALE", "GÜNEŞ", "ESİNTİ", "ÇAYIR", "FİLİZ",
    ]
}
