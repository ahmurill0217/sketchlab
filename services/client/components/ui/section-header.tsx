import { cn } from '@/lib/utils'

interface SectionHeaderProps {
  kicker?: string
  title: string
  subtitle?: string
  className?: string
  centered?: boolean
}

export function SectionHeader({
  kicker,
  title,
  subtitle,
  className,
  centered = false,
}: SectionHeaderProps) {
  return (
    <div className={cn('max-w-[560px] mb-4', centered && 'mx-auto text-center', className)}>
      {kicker && (
        <div className="text-[11px] tracking-[0.18em] uppercase text-ink-muted mb-1">
          {kicker}
        </div>
      )}
      <h2 className="m-0 mb-1.5 text-[22px] tracking-tight font-semibold text-ink">
        {title}
      </h2>
      {subtitle && <p className="text-[13px] text-ink-soft m-0">{subtitle}</p>}
    </div>
  )
}
