import type { Config } from "tailwindcss";

export default {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        ink: "#0f1115",
        panel: "#171a21",
        edge: "#242833",
        muted: "#8b93a7",
        accent: "#7c5cff",
      },
    },
  },
  plugins: [],
} satisfies Config;
