import { NAV_LINKS } from '@/lib/constants'

export function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="max-w-[1120px] mx-auto px-4 py-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-sm text-ink-soft">
      <div>
        &copy; {currentYear} Sketch Labs. One picture, six steps.
      </div>
      <div className="flex gap-2">
        {NAV_LINKS.map((link, index) => (
          <span key={link.href}>
            <a
              href={link.href}
              className="hover:text-ink transition-colors"
            >
              {link.label}
            </a>
            {index < NAV_LINKS.length - 1 && <span className="ml-2">·</span>}
          </span>
        ))}
      </div>
    </footer>
  )
}
