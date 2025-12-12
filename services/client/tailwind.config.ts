import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: ['class'],
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        ink: {
          DEFAULT: 'hsl(var(--ink))',
          soft: 'hsl(var(--ink-soft))',
          muted: 'hsl(var(--ink-muted))',
        },
        accent: {
          pink: 'hsl(var(--accent-pink))',
          blue: 'hsl(var(--accent-blue))',
          lime: 'hsl(var(--accent-lime))',
          yellow: 'hsl(var(--accent-yellow))',
          orange: 'hsl(var(--accent-orange))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
      },
      borderRadius: {
        sm: 'var(--radius-sm)',
        md: 'var(--radius-md)',
        lg: 'var(--radius-lg)',
        xl: 'var(--radius-xl)',
        full: 'var(--radius-full)',
      },
      boxShadow: {
        soft: 'var(--shadow-soft)',
        pink: 'var(--shadow-pink)',
        dark: 'var(--shadow-dark)',
        orange: 'var(--shadow-orange)',
      },
      keyframes: {
        'step-highlight': {
          '0%': { transform: 'translateY(0)', boxShadow: 'none' },
          '100%': { transform: 'translateY(-2px)', boxShadow: '0 8px 18px rgba(248, 113, 113, 0.6)' },
        },
      },
      animation: {
        'step-highlight': 'step-highlight 0.2s ease forwards',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}
export default config
