/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
  ],

  theme: {
    extend: {
      /* ================================
         ALOGYAN DESIGN SYSTEM
         Primary: Poppins (headings)
         Secondary: Inter (body)
         Brand Color: #C91F26 (Alogyan Red)
      ================================ */
      fontFamily: {
        // Primary font - for headings, buttons, section titles
        poppins: ["var(--font-poppins)", "Poppins", "sans-serif"],
        heading: ["var(--font-poppins)", "Poppins", "sans-serif"],
        // Secondary font - for body text, paragraphs, forms
        inter: ["var(--font-inter)", "Inter", "sans-serif"],
        body: ["var(--font-inter)", "Inter", "sans-serif"],
        sans: ["var(--font-inter)", "Inter", "sans-serif"],
      },

      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
        // Premium brand gradient using Alogyan Red
        "brand-gradient":
          "linear-gradient(135deg, #C91F26 0%, #A81920 50%, #8B1419 100%)",
        "brand-gradient-hover":
          "linear-gradient(135deg, #A81920 0%, #8B1419 50%, #6B1014 100%)",
        // Subtle hero gradient
        "hero-gradient":
          "linear-gradient(135deg, #FFFFFF 0%, #F9FAFB 50%, #F3F4F6 100%)",
      },

      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },

      colors: {
        /* --------------------------------
           ALOGYAN BRAND PALETTE
           Usage Ratio: 70% white, 20% text, 7% red, 3% accents
        -------------------------------- */
        alogyan: {
          // Primary Brand Color - Use sparingly (7%)
          red: "#C91F26",
          "red-hover": "#A81920",
          "red-dark": "#8B1419",
          // Background Colors (70%)
          white: "#FFFFFF",
          surface: "#F9FAFB",
          "surface-alt": "#F3F4F6",
          // Text Colors (20%)
          "text-primary": "#111827",
          "text-secondary": "#374151",
          muted: "#6B7280",
          // Accent Colors (3%)
          blue: "#2563EB",
          "blue-hover": "#1D4ED8",
          success: "#16A34A",
          "success-hover": "#15803D",
        },

        // Legacy brand colors (for backward compatibility)
        brand: {
          coral: "#C91F26", // Updated to Alogyan Red
          red: "#C91F26",
          crimson: "#A81920",
          purple: "#B53471",
          indigo: "#6B5B95",
          blue: "#2563EB", // Updated to Tech Blue
          lightBlue: "#1E90FF",
        },

        // Semantic colors (shadcn compatible)
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",

        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },

        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },

        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
        },

        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },

        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },

        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },

        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },

        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",

        chart: {
          "1": "hsl(var(--chart-1))",
          "2": "hsl(var(--chart-2))",
          "3": "hsl(var(--chart-3))",
          "4": "hsl(var(--chart-4))",
          "5": "hsl(var(--chart-5))",
        },
      },

      keyframes: {
        "accordion-down": {
          from: { height: "0" },
          to: { height: "var(--radix-accordion-content-height)" },
        },
        "accordion-up": {
          from: { height: "var(--radix-accordion-content-height)" },
          to: { height: "0" },
        },
      },

      animation: {
        "accordion-down": "accordion-down 0.2s ease-out",
        "accordion-up": "accordion-up 0.2s ease-out",
      },
    },
  },

  plugins: [],
};
