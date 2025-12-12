import Link from 'next/link'

export function Logo() {
  return (
    <Link href="/" className="inline-flex items-center gap-2.5">
      <div className="w-8 h-8 rounded-full gradient-logo flex items-center justify-center shadow-pink text-[#fefce8] font-extrabold text-lg">
        S
      </div>
      <div>
        <div className="font-bold tracking-wide text-[17px]">Sketch Labs</div>
        <div className="text-[10px] tracking-[0.18em] uppercase text-ink-muted">
          Draw It In 6 Steps
        </div>
      </div>
    </Link>
  )
}
