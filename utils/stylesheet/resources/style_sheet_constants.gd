class_name StyleSheetConstants
extends Resource

enum StyleBoxPresets {
	DEFAULT,
	BUTTON_PRIMARY,
	BUTTON_SUCCESS
}

const STYLEBOX_PRESETS = {
	StyleBoxPresets.DEFAULT: "",
	StyleBoxPresets.BUTTON_PRIMARY: "bg_blue_600 border_blue_500 bg-opacity_90 border-opacity_80",
	StyleBoxPresets.BUTTON_SUCCESS: "bg_emerald_600 bg-opacity_90 border_emerald_500 border-opacity_80 border-width_3_1_1_2",
}

enum FontPresets {
	DEFAULT,
	BUTTON_PRIMARY,
	BUTTON_SUCCESS
}

const FONT_PRESETS = {
	FontPresets.DEFAULT: "",
	FontPresets.BUTTON_PRIMARY: "color_blue_200 extra_bold",
	FontPresets.BUTTON_SUCCESS: "color_emerald_100 extra_bold",
}

const SIZES := {
	xxs = 3,
	xs = 5,
	sm = 8,
	md = 15,
	lg = 30,
	xl = 50
}

const FONTS := {
	black = preload("res://static/fonts/Nunito/Nunito-Black.ttf"),
	black_italic = preload("res://static/fonts/Nunito/Nunito-BlackItalic.ttf"),
	bold = preload("res://static/fonts/Nunito/Nunito-Bold.ttf"),
	bold_italic = preload("res://static/fonts/Nunito/Nunito-BoldItalic.ttf"),
	extra_bold = preload("res://static/fonts/Nunito/Nunito-ExtraBold.ttf"),
	extra_bold_italic = preload("res://static/fonts/Nunito/Nunito-ExtraBoldItalic.ttf"),
	extra_light = preload("res://static/fonts/Nunito/Nunito-ExtraLight.ttf"),
	extra_light_italic = preload("res://static/fonts/Nunito/Nunito-ExtraLightItalic.ttf"),
	italic = preload("res://static/fonts/Nunito/Nunito-Italic.ttf"),
	light = preload("res://static/fonts/Nunito/Nunito-Light.ttf"),
	light_italic = preload("res://static/fonts/Nunito/Nunito-LightItalic.ttf"),
	medium = preload("res://static/fonts/Nunito/Nunito-Medium.ttf"),
	medium_italic = preload("res://static/fonts/Nunito/Nunito-MediumItalic.ttf"),
	regular = preload("res://static/fonts/Nunito/Nunito-Regular.ttf"),
	semibold = preload("res://static/fonts/Nunito/Nunito-SemiBold.ttf"),
	semibold_italic = preload("res://static/fonts/Nunito/Nunito-SemiBoldItalic.ttf")
}

const FONT_SIZES := {
	xs = 18,
	sm = 24,
	md = 32,
	lg = 40,
	xl = 56
}

const PALETTE := {
	slate = {
		50: Color("#f8fafc"),
		100: Color("#f1f5f9"),
		200: Color("#e2e8f0"),
		300: Color("#cbd5e1"),
		400: Color("#94a3b8"),
		500: Color("#64748b"),
		600: Color("#475569"),
		700: Color("#334155"),
		800: Color("#1e293b"),
		900: Color("#0f172a")
	},
	gray = {
		50: Color("#f9fafb"),
		100: Color("#f3f4f6"),
		200: Color("#e5e7eb"),
		300: Color("#d1d5db"),
		400: Color("#9ca3af"),
		500: Color("#6b7280"),
		600: Color("#4b5563"),
		700: Color("#374151"),
		800: Color("#1f2937"),
		900: Color("#111827"),
	},
	zinc = {
		50: Color("#fafafa"),
		100: Color("#f4f4f5"),
		200: Color("#e4e4e7"),
		300: Color("#d4d4d8"),
		400: Color("#a1a1aa"),
		500: Color("#71717a"),
		600: Color("#52525b"),
		700: Color("#3f3f46"),
		800: Color("#27272a"),
		900: Color("#18181b"),
	},
	neutral = {
		50: Color("#fafafa"),
		100: Color("#f5f5f5"),
		200: Color("#e5e5e5"),
		300: Color("#d4d4d4"),
		400: Color("#a3a3a3"),
		500: Color("#737373"),
		600: Color("#525252"),
		700: Color("#404040"),
		800: Color("#262626"),
		900: Color("#171717"),
	},
	stone = {
		50: Color("#fafaf9"),
		100: Color("#f5f5f4"),
		200: Color("#e7e5e4"),
		300: Color("#d6d3d1"),
		400: Color("#a8a29e"),
		500: Color("#78716c"),
		600: Color("#57534e"),
		700: Color("#44403c"),
		800: Color("#292524"),
		900: Color("#1c1917"),
	},
	red = {
		50: Color("#fef2f2"),
		100: Color("#fee2e2"),
		200: Color("#fecaca"),
		300: Color("#fca5a5"),
		400: Color("#f87171"),
		500: Color("#ef4444"),
		600: Color("#dc2626"),
		700: Color("#b91c1c"),
		800: Color("#991b1b"),
		900: Color("#7f1d1d"),
	},
	orange = {
		50: Color("#fff7ed"),
		100: Color("#ffedd5"),
		200: Color("#fed7aa"),
		300: Color("#fdba74"),
		400: Color("#fb923c"),
		500: Color("#f97316"),
		600: Color("#ea580c"),
		700: Color("#c2410c"),
		800: Color("#9a3412"),
		900: Color("#7c2d12"),
	},
	amber = {
		50: Color("#fffbeb"),
		100: Color("#fef3c7"),
		200: Color("#fde68a"),
		300: Color("#fcd34d"),
		400: Color("#fbbf24"),
		500: Color("#f59e0b"),
		600: Color("#d97706"),
		700: Color("#b45309"),
		800: Color("#92400e"),
		900: Color("#78350f")
	},
	yellow = {
		50: Color("#fefce8"),
		100: Color("#fef9c3"),
		200: Color("#fef08a"),
		300: Color("#fde047"),
		400: Color("#facc15"),
		500: Color("#eab308"),
		600: Color("#ca8a04"),
		700: Color("#a16207"),
		800: Color("#854d0e"),
		900: Color("#713f12")
	},
	lime = {
		50: Color("#f7fee7"),
		100: Color("#ecfccb"),
		200: Color("#d9f99d"),
		300: Color("#bef264"),
		400: Color("#a3e635"),
		500: Color("#84cc16"),
		600: Color("#65a30d"),
		700: Color("#4d7c0f"),
		800: Color("#3f6212"),
		900: Color("#365314"),
	},
	green = {
		50: Color("#f0fdf4"),
		100: Color("#dcfce7"),
		200: Color("#bbf7d0"),
		300: Color("#86efac"),
		400: Color("#4ade80"),
		500: Color("#22c55e"),
		600: Color("#16a34a"),
		700: Color("#15803d"),
		800: Color("#166534"),
		900: Color("#14532d"),
	},
	emerald = {
		50: Color("#ecfdf5"),
		100: Color("#d1fae5"),
		200: Color("#a7f3d0"),
		300: Color("#6ee7b7"),
		400: Color("#34d399"),
		500: Color("#10b981"),
		600: Color("#059669"),
		700: Color("#047857"),
		800: Color("#065f46"),
		900: Color("#064e3b"),
	},
	teal = {
		50: Color("#f0fdfa"),
		100: Color("#ccfbf1"),
		200: Color("#99f6e4"),
		300: Color("#5eead4"),
		400: Color("#2dd4bf"),
		500: Color("#14b8a6"),
		600: Color("#0d9488"),
		700: Color("#0f766e"),
		800: Color("#115e59"),
		900: Color("#134e4a"),
	},
	cyan = {
		50: Color("#ecfeff"),
		100: Color("#cffafe"),
		200: Color("#a5f3fc"),
		300: Color("#67e8f9"),
		400: Color("#22d3ee"),
		500: Color("#06b6d4"),
		600: Color("#0891b2"),
		700: Color("#0e7490"),
		800: Color("#155e75"),
		900: Color("#164e63"),
	},
	sky = {
		50: Color("#f0f9ff"),
		100: Color("#e0f2fe"),
		200: Color("#bae6fd"),
		300: Color("#7dd3fc"),
		400: Color("#38bdf8"),
		500: Color("#0ea5e9"),
		600: Color("#0284c7"),
		700: Color("#0369a1"),
		800: Color("#075985"),
		900: Color("#0c4a6e"),
	},
	blue = {
		50: Color("#eff6ff"),
		100: Color("#dbeafe"),
		200: Color("#bfdbfe"),
		300: Color("#93c5fd"),
		400: Color("#60a5fa"),
		500: Color("#3b82f6"),
		600: Color("#2563eb"),
		700: Color("#1d4ed8"),
		800: Color("#1e40af"),
		900: Color("#1e3a8a"),
	},
	indigo = {
		50: Color("#eef2ff"),
		100: Color("#e0e7ff"),
		200: Color("#c7d2fe"),
		300: Color("#a5b4fc"),
		400: Color("#818cf8"),
		500: Color("#6366f1"),
		600: Color("#4f46e5"),
		700: Color("#4338ca"),
		800: Color("#3730a3"),
		900: Color("#312e81"),
	},
	violet = {
		50: Color("#f5f3ff"),
		100: Color("#ede9fe"),
		200: Color("#ddd6fe"),
		300: Color("#c4b5fd"),
		400: Color("#a78bfa"),
		500: Color("#8b5cf6"),
		600: Color("#7c3aed"),
		700: Color("#6d28d9"),
		800: Color("#5b21b6"),
		900: Color("#4c1d95"),
	},
	purple = {
		50: Color("#faf5ff"),
		100: Color("#f3e8ff"),
		200: Color("#e9d5ff"),
		300: Color("#d8b4fe"),
		400: Color("#c084fc"),
		500: Color("#a855f7"),
		600: Color("#9333ea"),
		700: Color("#7e22ce"),
		800: Color("#6b21a8"),
		900: Color("#581c87"),
	},
	fuschia = {
		50: Color("#fdf4ff"),
		100: Color("#fae8ff"),
		200: Color("#f5d0fe"),
		300: Color("#f0abfc"),
		400: Color("#e879f9"),
		500: Color("#d946ef"),
		600: Color("#c026d3"),
		700: Color("#a21caf"),
		800: Color("#86198f"),
		900: Color("#701a75"),
	},
	pink = {
		50: Color("#fdf2f8"),
		100: Color("#fce7f3"),
		200: Color("#fbcfe8"),
		300: Color("#f9a8d4"),
		400: Color("#f472b6"),
		500: Color("#ec4899"),
		600: Color("#db2777"),
		700: Color("#be185d"),
		800: Color("#9d174d"),
		900: Color("#831843"),
	},
	rose = {
		50: Color("#fff1f2"),
		100: Color("#ffe4e6"),
		200: Color("#fecdd3"),
		300: Color("#fda4af"),
		400: Color("#fb7185"),
		500: Color("#f43f5e"),
		600: Color("#e11d48"),
		700: Color("#be123c"),
		800: Color("#9f1239"),
		900: Color("#881337"),
	}
}
