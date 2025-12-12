'use client'

import { Logo } from './Logo'
import { NAV_LINKS } from '@/lib/constants'

export function Header() {
  return (
    <header className="sticky top-0 z-20 backdrop-blur-xl bg-[rgba(255,253,247,0.96)] border-b border-dashed border-accent-yellow/70">
      <nav className="max-w-[1120px] mx-auto px-4 py-2.5 flex items-center justify-between gap-4">
        <Logo />
        <div className="flex gap-2.5 items-center text-xs text-ink-soft flex-wrap">
          {NAV_LINKS.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="no-underline text-inherit px-2.5 py-1.5 rounded-full bg-white/70 border border-dashed border-ink-muted/40 transition-all duration-150 hover:-translate-y-0.5 hover:shadow-md hover:bg-white"
            >
              {link.label}
            </a>
          ))}
        </div>
      </nav>
    </header>
  )
}
