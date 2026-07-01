import type { Config } from "tailwindcss";

export default {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        canvas: "var(--bg)",
        canvas2: "var(--bg2)",
        nav: "var(--nav)",
        surface: "var(--surface)",
        solid: "var(--solid)",
        edge: "var(--border)",
        head: "var(--head)",
        body: "var(--text)",
        muted: "var(--muted)",
        faint: "var(--faint)",
        teal: "var(--teal)",
        "teal-soft": "var(--teal-soft)",
        indigo: "var(--indigo)",
        "indigo-soft": "var(--indigo-soft)",
        amber: "var(--amber)",
        track: "var(--track)",
        "on-teal": "var(--on-teal)",
      },
      fontFamily: {
        display: ["Fredoka", "system-ui", "sans-serif"],
        sans: ["Nunito", "system-ui", "sans-serif"],
      },
      boxShadow: {
        card: "var(--shadow)",
      },
      borderRadius: {
        xl2: "18px",
      },
    },
  },
  plugins: [],
} satisfies Config;
