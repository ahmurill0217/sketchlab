import { cn } from '@/lib/utils'

interface BadgeProps {
  children: React.ReactNode
  variant?: 'default' | 'pill' | 'hero'
  className?: string
}

export function Badge({ children, variant = 'default', className }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center gap-1.5 text-xs',
        {
          'px-2.5 py-1.5 rounded-full border border-dashed border-ink-muted/70 bg-white/90 text-ink-soft':
            variant === 'default' || variant === 'hero',
          'px-2.5 py-1 rounded-full bg-accent-yellow text-ink text-[10px] tracking-[0.16em] uppercase font-bold':
            variant === 'pill',
        },
        className
      )}
    >
      {children}
    </span>
  )
}
